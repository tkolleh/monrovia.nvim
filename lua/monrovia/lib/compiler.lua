local config = require("monrovia.config")
local util = require("monrovia.util")
local parse_styles = require("monrovia.lib.highlight").parse_style
local fmt = string.format

local M = {}

local function inspect(t)
  local list = {}
  for k, v in pairs(t) do
    local q = type(v) == "string" and [["]] or ""
    table.insert(list, fmt([[%s = %s%s%s]], k, q, v, q))
  end

  table.sort(list)
  return fmt([[{ %s }]], table.concat(list, ", "))
end

local function should_link(link)
  return link and link ~= ""
end

function M.compile(opts)
  opts = opts or {}
  local style = opts.style or config.fox
  local spec = require("monrovia.spec").load(style)
  local groups = require("monrovia.group").from(spec)
  local background = spec.palette.meta.light and "light" or "dark"

  local lines = {
    fmt(
      [[
return string.dump(function()
local h = vim.api.nvim_set_hl
if vim.g.colors_name then vim.cmd("hi clear") end
vim.g.colors_name = "%s"
vim.o.background = "%s"
    ]],
      style,
      background
    ),
  }

  if config.options.terminal_colors then
    local terminal = require("monrovia.group.terminal").get(spec)
    for k, v in pairs(terminal) do
      table.insert(lines, fmt([[vim.g.%s = "%s"]], k, v))
    end
  end

  for name, values in pairs(groups) do
    if should_link(values.link) then
      table.insert(lines, fmt([[h(0, "%s", { link = "%s" })]], name, values.link))
    else
      local op = parse_styles(values.style)
      op.bg = values.bg
      op.fg = values.fg
      op.sp = values.sp
      op.blend = values.blend
      table.insert(lines, fmt([[h(0, "%s", %s)]], name, inspect(op)))
    end
  end

  table.insert(lines, "end)")

  opts.name = style
  local output_path, output_file = config.get_compiled_info(opts)
  util.ensure_dir(output_path)

  local source = table.concat(lines, "\n")
  local log = require("monrovia.lib.log")

  if vim.g.monrovia_debug then
    local debug_file = io.open(output_file .. ".lua", "wb")
    if debug_file then
      debug_file:write(source)
      debug_file:close()
    end
  end

  -- Compile before touching the cache. Opening the output first would truncate a
  -- previously good blob, turning a config error into a silently colourless session.
  local f, load_err = load(source, "=")
  if not f then
    local tmpfile = util.join_paths(util.get_tmp_dir(), "monrovia_error.lua")
    local efile = io.open(tmpfile, "wb")
    if efile then
      efile:write(source)
      efile:close()
    end

    log.error(fmt(
      [[There is an error in your monrovia config.
You can open '%s' for debugging.

If you think this is a bug, kindly open an issue and attach the '%s' file.
Below is the error message:

%s]],
      tmpfile,
      tmpfile,
      load_err
    ))
    return
  end

  -- Write to a sibling temp path and rename into place. Rename is atomic, so a
  -- concurrent reader never observes a half-written blob, and a failed write
  -- leaves the existing cache untouched.
  local temp_file = output_file .. ".tmp"
  local file, err = io.open(temp_file, "wb")
  if not file then
    log.error(fmt(
      [[Couldn't open %s: %s.

Check that %s is accessible for the current user.
You could try deleting %s to reset permissions]],
      temp_file,
      err,
      temp_file,
      output_path
    ))
    return
  end

  file:write(f())
  file:close()

  local renamed, rename_err = vim.uv.fs_rename(temp_file, output_file)
  if not renamed then
    log.error(fmt("Couldn't move %s into place at %s: %s", temp_file, output_file, rename_err))
  end
end

return M
