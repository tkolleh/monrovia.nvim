local config = require("monrovia.config")

local function read_file(filepath)
  local file = io.open(filepath, "r")
  if file then
    local content = file:read()
    file:close()
    return content
  end
end

local function write_file(filepath, content)
  local file = io.open(filepath, "wb")
  if file then
    file:write(content)
    file:close()
  end
end

local M = {}

function M.compile()
  require("monrovia.lib.log").clear()

  local compiler = require("monrovia.lib.compiler")
  local themes = require("monrovia.palette").themes
  for _, style in ipairs(themes) do
    compiler.compile({ style = style })
  end
end

function M.reset()
  require("monrovia.config").reset()
  require("monrovia.override").reset()
end

-- Avold g:colors_name reloading
local lock = false
local did_setup = false

-- Register runtime-only module hooks (autocmds, etc.). Unlike the static
-- highlight tables, these cannot live in the compiled blob, so they must be
-- (re-)registered on every load. Module setup functions are idempotent.
local function register_runtime()
  local cfg = require("monrovia.config")
  local opts = cfg.options
  local default_enable = opts.module_default
  for _, name in ipairs(cfg.module_names) do
    local value = opts.modules[name]
    local enabled = type(value) == "boolean" and value
      or type(value) == "table" and (value.enable == nil and default_enable or value.enable)
      or default_enable
    if enabled then
      local ok, mod = pcall(require, "monrovia.group.modules." .. name)
      if ok and type(mod.setup) == "function" then
        pcall(mod.setup)
      end
    end
  end
end

function M.load(opts)
  if lock then
    return
  end

  if not did_setup then
    M.setup()
  end

  opts = opts or {}

  local _, compiled_file = config.get_compiled_info(opts)
  lock = true

  local f = loadfile(compiled_file)
  if not f then
    M.compile()
    f = loadfile(compiled_file)
  end

  ---@diagnostic disable-next-line: need-check-nil
  f()

  -- Register runtime hooks after the compiled blob has set its highlight groups.
  register_runtime()

  lock = false
end

function M.setup(opts)
  did_setup = true
  opts = opts or {}

  local override = require("monrovia.override")

  if opts.options then
    config.set_options(opts.options)
  end

  if opts.palettes then
    override.palettes = opts.palettes
  end

  if opts.specs then
    override.specs = opts.specs
  end

  if opts.groups then
    override.groups = opts.groups
  end

  local util = require("monrovia.util")
  util.ensure_dir(config.options.compile_path)

  local cached_path = util.join_paths(config.options.compile_path, "cache")
  local cached = read_file(cached_path)

  local git_path = util.join_paths(debug.getinfo(1).source:sub(2, -23), ".git")
  local git = vim.fn.getftime(git_path)
  local hash = require("monrovia.lib.hash")(opts) .. (git == -1 and git_path or git)

  if cached ~= hash then
    M.compile()
    write_file(cached_path, hash)
  end
end

return M
