-- https://github.com/akinsho/bufferline.nvim

local M = {}

--- Dynamically applies per-filetype icon highlight groups for bufferline.
--- bufferline generates group names like BufferLineDevIconTsx at runtime by
--- querying nvim-web-devicons, so static highlight tables cannot cover them.
--- This autocmd re-applies correct bg (active/inactive) + real icon fg color
--- whenever a new buffer is entered or the colorscheme reloads.
function M.setup(spec)
  local augroup = vim.api.nvim_create_augroup("MonroviaBufferlineIcons", { clear = true })

  vim.api.nvim_create_autocmd({ "ColorScheme", "BufEnter" }, {
    group = augroup,
    pattern = "*",
    callback = function()
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if not ok then
        return
      end

      local seen = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        pcall(function()
          local name = vim.api.nvim_buf_get_name(buf)
          if name == "" then
            return
          end
          local fname = vim.fn.fnamemodify(name, ":t")
          local ext = vim.fn.fnamemodify(name, ":e")
          local _, hl_name = devicons.get_icon(fname, ext, { default = true })
          local _, icon_color = devicons.get_icon_color(fname, ext, { default = true })

          if not hl_name or seen[hl_name] then
            return
          end
          seen[hl_name] = true

          vim.api.nvim_set_hl(0, "BufferLine" .. hl_name .. "Selected", { bg = spec.bg1, fg = icon_color })
          vim.api.nvim_set_hl(0, "BufferLine" .. hl_name,               { bg = spec.bg0, fg = icon_color })
          vim.api.nvim_set_hl(0, "BufferLine" .. hl_name .. "Inactive", { bg = spec.bg0, fg = icon_color })
        end)
      end
    end,
  })
end

function M.get(spec, config, opts)
  -- stylua: ignore
  return {
    -- Fill area (empty space in tabline)
    BufferLineFill               = { bg = spec.bg0 },

    -- Background buffers (not visible) - darkest background
    BufferLineBackground         = { fg = spec.syntax.comment, bg = spec.bg0 },

    -- Visible but not active buffers - use bg0 (darker)
    BufferLineBufferVisible      = { fg = spec.fg2, bg = spec.bg0 },
    BufferLineCloseButtonVisible = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineModifiedVisible    = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineIndicatorVisible   = { fg = spec.diag.info, bg = spec.bg0 },

    -- Selected/active buffer - use bg1 (main editor background color)
    -- This makes the active tab blend with the editor content area
    BufferLineBufferSelected     = { fg = spec.fg1, bg = spec.bg1, style = "bold" },
    BufferLineCloseButtonSelected = { fg = spec.diag.error, bg = spec.bg1 },
    BufferLineModifiedSelected   = { fg = spec.diag.warn, bg = spec.bg1, style = "bold" },
    BufferLineIndicatorSelected  = { fg = spec.diag.info, bg = spec.bg1 },

    -- Separators for slant style:
    -- For proper slant rendering, fg = the color we want the diagonal to show
    -- bg = the color of the current tab
    -- 
    -- When an active tab (bg1) is next to fill (bg0), we want the diagonal
    -- to show bg0 on the outside, with bg=bg1 matching the active tab
    BufferLineSeparator          = { fg = spec.bg0, bg = spec.bg0 },
    BufferLineSeparatorVisible   = { fg = spec.bg0, bg = spec.bg0 },
    BufferLineSeparatorSelected  = { fg = spec.bg0, bg = spec.bg0 },

    -- Tabs (when in tab mode)
    BufferLineTab                = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineTabSelected        = { fg = spec.fg1, bg = spec.bg1, style = "bold" },
    BufferLineTabClose           = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineTabSeparator       = { fg = spec.bg0, bg = spec.bg0 },
    BufferLineTabSeparatorSelected = { fg = spec.bg0, bg = spec.bg0 },

    -- Close buttons
    BufferLineCloseButton        = { fg = spec.fg3, bg = spec.bg0 },

    -- Modified indicator
    BufferLineModified           = { fg = spec.diag.warn, bg = spec.bg0 },

    -- Diagnostics - follow the bg0/bg1 pattern
    BufferLineError              = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineErrorVisible       = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineErrorSelected      = { fg = spec.diag.error, bg = spec.bg1, style = "bold" },

    BufferLineWarning            = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineWarningVisible     = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineWarningSelected    = { fg = spec.diag.warn, bg = spec.bg1, style = "bold" },

    BufferLineInfo               = { fg = spec.diag.info, bg = spec.bg0 },
    BufferLineInfoVisible        = { fg = spec.diag.info, bg = spec.bg0 },
    BufferLineInfoSelected       = { fg = spec.diag.info, bg = spec.bg1, style = "bold" },

    BufferLineHint               = { fg = spec.diag.hint, bg = spec.bg0 },
    BufferLineHintVisible        = { fg = spec.diag.hint, bg = spec.bg0 },
    BufferLineHintSelected       = { fg = spec.diag.hint, bg = spec.bg1, style = "bold" },

    -- Duplicates
    BufferLineDuplicate          = { fg = spec.fg3, bg = spec.bg0, style = "italic" },
    BufferLineDuplicateVisible   = { fg = spec.fg3, bg = spec.bg0, style = "italic" },
    BufferLineDuplicateSelected  = { fg = spec.fg2, bg = spec.bg1, style = "italic" },

    -- Pick (when using buffer picking mode)
    BufferLinePick               = { fg = spec.diag.error, bg = spec.bg0, style = "bold" },
    BufferLinePickVisible        = { fg = spec.diag.error, bg = spec.bg0, style = "bold" },
    BufferLinePickSelected       = { fg = spec.diag.error, bg = spec.bg1, style = "bold" },

    -- Offset (for file explorer sidebars)
    BufferLineOffsetSeparator    = { bg = spec.bg0 },

    -- Dev icons - fallback only; per-filetype colors are applied dynamically
    -- by M.setup() via autocmd querying nvim-web-devicons at runtime.
    BufferLineDevIconDefault         = { fg = spec.fg2, bg = spec.bg0 },
    BufferLineDevIconDefaultSelected = { fg = spec.fg1, bg = spec.bg1 },
    BufferLineDevIconDefaultInactive = { fg = spec.fg2, bg = spec.bg0 },
  }
end

return M
