local M = {
  _list = { { "monrovia.nvim\n", "Question" }, { "The following has been " }, { "Deprecated:\n", "WarningMsg" } },
  _has_registered = false,
}

function M.write(...)
  for _, e in ipairs({ ... }) do
    table.insert(M._list, type(e) == "string" and { e } or e)
  end

  M._list[#M._list][1] = M._list[#M._list][1] .. "\n"

  if not M._has_registered then
    local augroup = vim.api.nvim_create_augroup("MonroviadeprecationMessage", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
      group = augroup,
      once = true,
      callback = function()
        require("monrovia.lib.deprecation").flush()
      end,
    })
    M._has_registered = true
  end
end

function M.flush()
  M.write("See ", { "https://github.com/EdenEast/monrovia.nvim ", "Title" }, "for more information.")
  vim.api.nvim_echo(M._list, true, {})
end

return M
