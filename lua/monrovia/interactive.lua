local util = require("monrovia.util")
local cmd = vim.cmd
local fmt = string.format

local M = {}

local function get_filetype()
  return vim.bo.filetype
end

function M.attach()
  vim.g.monrovia_debug = true
  cmd([[
    augroup MonroviaInteractiveAugroup
      autocmd!
      autocmd BufWritePost <buffer> lua require("monrovia.interactive").execute()
    augroup END
  ]])
end

function M.execute()
  local source_method = get_filetype() == "lua" and "luafile" or "source"
  local name = vim.g.colors_name

  require("monrovia.config").reset()
  require("monrovia.override").reset()
  cmd(fmt(
    [[
      %s %%
      colorscheme %s
      doautoall ColorScheme
    ]],
    source_method,
    name
  ))
end

return M
