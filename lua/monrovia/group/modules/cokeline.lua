-- https://github.com/willothy/nvim-cokeline

local M = {}

--- Dynamically applies per-filetype icon highlight groups for cokeline.
--- cokeline builds highlight groups at render time (`Cokeline_<bufnr>_<index>`)
--- rather than stable per-filetype names, so a plugin config must reference
--- named groups explicitly (via each component's `highlight` field) to get
--- colorscheme-aware icon backgrounds. This autocmd maintains those named
--- groups, re-applying correct bg (selected/unselected) + real icon fg color
--- whenever a new buffer is entered or the colorscheme reloads.
---
--- NOTE: This must be registered at *load* time, not compile time. The compiled
--- colorscheme blob never re-runs the group builders, so the spec is resolved
--- fresh from `vim.g.colors_name` on each event rather than captured here. One
--- registration therefore serves every variant correctly across day/night switches.
function M.setup()
  -- `clear = true` makes re-registration idempotent (load may run more than once).
  local augroup = vim.api.nvim_create_augroup("MonroviaCokelineIcons", { clear = true })

  vim.api.nvim_create_autocmd({ "ColorScheme", "BufEnter" }, {
    group = augroup,
    pattern = "*",
    callback = function(ev)
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if not ok then
        return
      end

      -- Resolve the spec for the active variant at event time. Falls back to the
      -- configured default if `colors_name` is not one of monrovia's variants.
      local name = vim.g.colors_name or require("monrovia.config").fox
      local spec_ok, spec = pcall(require("monrovia.spec").load, name)
      if not spec_ok or not spec or not spec.bg0 then
        return
      end

      -- ColorScheme must repaint every known icon type; BufEnter only needs the entering buffer.
      local bufs = ev.event == "ColorScheme" and vim.api.nvim_list_bufs() or { ev.buf }

      for _, buf in ipairs(bufs) do
        pcall(function()
          local bname = vim.api.nvim_buf_get_name(buf)
          if bname == "" then
            return
          end
          local fname = vim.fn.fnamemodify(bname, ":t")
          local ext = vim.fn.fnamemodify(bname, ":e")
          local _, hl_name = devicons.get_icon(fname, ext, { default = true })
          local _, icon_color = devicons.get_icon_color(fname, ext, { default = true })

          if not hl_name then
            return
          end

          vim.api.nvim_set_hl(0, "Cokeline" .. hl_name .. "Selected", { bg = spec.bg1, fg = icon_color })
          vim.api.nvim_set_hl(0, "Cokeline" .. hl_name, { bg = spec.bg0, fg = icon_color })
        end)
      end
    end,
  })
end

function M.get(spec, config, opts)
  -- stylua: ignore
  return {
    -- Fill area (empty space in tabline)
    CokelineFill             = { bg = spec.bg0 },

    -- Unselected buffer cell
    CokelineBuffer           = { fg = spec.fg2, bg = spec.bg0 },
    CokelineCloseButton      = { fg = spec.fg3, bg = spec.bg0 },
    CokelineModified         = { fg = spec.diag.warn, bg = spec.bg0 },

    -- Selected/active buffer — bg1 blends with the editor content area
    CokelineBufferSelected      = { fg = spec.fg1, bg = spec.bg1, bold = true },
    CokelineCloseButtonSelected = { fg = spec.diag.error, bg = spec.bg1 },
    CokelineModifiedSelected    = { fg = spec.diag.warn, bg = spec.bg1, bold = true },

    -- Dev icons — fallback only; per-filetype colors applied dynamically by M.setup().
    CokelineDevIconDefault         = { fg = spec.fg2, bg = spec.bg0 },
    CokelineDevIconDefaultSelected = { fg = spec.fg1, bg = spec.bg1 },
  }
end

return M
