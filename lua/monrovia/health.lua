local M = {}

M.check = function()
  vim.health.start("monrovia.nvim")

  -- Check Neovim version
  if vim.fn.has("nvim-0.10") == 0 then
    vim.health.error("monrovia.nvim requires Neovim 0.10+")
  else
    vim.health.ok("Using Neovim 0.10+")
  end

  -- Check vim.uv availability
  if vim.uv then
    vim.health.ok("vim.uv available (Neovim 0.10+)")
  else
    vim.health.warn("vim.uv not available")
  end

  -- Check compilation cache
  local config = require("monrovia.config")
  local util = require("monrovia.util")
  local path, file = config.get_compiled_info()

  if util.exists(file) then
    vim.health.ok("Compiled colorscheme cache exists")
  else
    vim.health.warn("No compiled cache yet - run :MonroviaCompile after upgrade")
  end
end

return M
