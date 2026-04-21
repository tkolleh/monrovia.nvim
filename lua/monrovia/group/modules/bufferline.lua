-- https://github.com/akinsho/bufferline.nvim

local M = {}

--- Dynamically applies per-filetype icon highlight groups for bufferline.
--- bufferline generates group names like BufferLineDevIconTsx at runtime by
--- querying nvim-web-devicons, so static highlight tables cannot cover them.
--- This autocmd re-applies correct bg (active/inactive/visible) + real icon fg color
--- whenever a new buffer is entered or the colorscheme reloads.
function M.setup(spec)
  local C = require("monrovia.lib.color")
  local bg_visible = C(spec.bg0):blend(C(spec.bg1), 0.5):to_css()

  local augroup = vim.api.nvim_create_augroup("MonroviaBufferlineIcons", { clear = true })

  vim.api.nvim_create_autocmd({ "ColorScheme", "BufEnter" }, {
    group = augroup,
    pattern = "*",
    callback = function(ev)
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if not ok then
        return
      end

      -- ColorScheme must repaint every known icon type; BufEnter only needs the entering buffer.
      local bufs = ev.event == "ColorScheme" and vim.api.nvim_list_bufs() or { ev.buf }

      for _, buf in ipairs(bufs) do
        pcall(function()
          local name = vim.api.nvim_buf_get_name(buf)
          if name == "" then
            return
          end
          local fname = vim.fn.fnamemodify(name, ":t")
          local ext   = vim.fn.fnamemodify(name, ":e")
          local _, hl_name    = devicons.get_icon(fname, ext, { default = true })
          local _, icon_color = devicons.get_icon_color(fname, ext, { default = true })

          if not hl_name then
            return
          end

          vim.api.nvim_set_hl(0, "BufferLine" .. hl_name .. "Selected", { bg = spec.bg1,   fg = icon_color })
          vim.api.nvim_set_hl(0, "BufferLine" .. hl_name,               { bg = spec.bg0,   fg = icon_color })
          vim.api.nvim_set_hl(0, "BufferLine" .. hl_name .. "Inactive", { bg = spec.bg0,   fg = icon_color })
          vim.api.nvim_set_hl(0, "BufferLine" .. hl_name .. "Visible",  { bg = bg_visible, fg = icon_color })
        end)
      end
    end,
  })
end

function M.get(spec, config, opts)
  local C = require("monrovia.lib.color")
  -- bg for split-window buffers that are visible but not the focused tab
  local bg_visible = C(spec.bg0):blend(C(spec.bg1), 0.5):to_css()

  -- stylua: ignore
  return {
    -- Fill area (empty space in tabline)
    BufferLineFill               = { bg = spec.bg0 },

    -- Background buffers (not visible, not active)
    BufferLineBackground         = { fg = spec.syntax.comment, bg = spec.bg0 },

    -- Visible but unfocused buffers (split window, not active tab)
    BufferLineBufferVisible      = { fg = spec.fg2,       bg = bg_visible },
    BufferLineCloseButtonVisible = { fg = spec.fg3,       bg = bg_visible },
    BufferLineModifiedVisible    = { fg = spec.diag.warn, bg = bg_visible },
    BufferLineIndicatorVisible   = { fg = spec.diag.info, bg = bg_visible },

    -- Selected/active buffer — bg1 blends with the editor content area
    BufferLineBufferSelected      = { fg = spec.fg1,        bg = spec.bg1, bold = true },
    BufferLineCloseButtonSelected = { fg = spec.diag.error, bg = spec.bg1 },
    BufferLineModifiedSelected    = { fg = spec.diag.warn,  bg = spec.bg1, bold = true },
    BufferLineIndicatorSelected   = { fg = spec.diag.info,  bg = spec.bg1 },

    -- Separators for slant style:
    -- fg = the fill color (blade edge color); bg = the tab's own background.
    -- Inactive tabs sit on bg0 so both sides are bg0 → blade is invisible.
    -- Visible tab's left-edge blade still shows bg0 against bg_visible.
    -- Active tab's blade shows bg0 (fill) against bg1 (active tab).
    BufferLineSeparator          = { fg = spec.bg0, bg = spec.bg0    },
    BufferLineSeparatorVisible   = { fg = spec.bg0, bg = bg_visible  },
    BufferLineSeparatorSelected  = { fg = spec.bg0, bg = spec.bg1    },

    -- Tabs (tab-mode)
    BufferLineTab                  = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineTabSelected          = { fg = spec.fg1, bg = spec.bg1, bold = true },
    BufferLineTabClose             = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineTabSeparator         = { fg = spec.bg0, bg = spec.bg0  },
    BufferLineTabSeparatorSelected = { fg = spec.bg0, bg = spec.bg1  },

    -- Close buttons
    BufferLineCloseButton        = { fg = spec.fg3, bg = spec.bg0 },

    -- Modified indicator
    BufferLineModified           = { fg = spec.diag.warn, bg = spec.bg0 },

    -- Diagnostics (icon/underline)
    BufferLineError              = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineErrorVisible       = { fg = spec.diag.error, bg = bg_visible },
    BufferLineErrorSelected      = { fg = spec.diag.error, bg = spec.bg1,  bold = true },

    BufferLineWarning            = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineWarningVisible     = { fg = spec.diag.warn, bg = bg_visible },
    BufferLineWarningSelected    = { fg = spec.diag.warn, bg = spec.bg1,  bold = true },

    BufferLineInfo               = { fg = spec.diag.info, bg = spec.bg0 },
    BufferLineInfoVisible        = { fg = spec.diag.info, bg = bg_visible },
    BufferLineInfoSelected       = { fg = spec.diag.info, bg = spec.bg1,  bold = true },

    BufferLineHint               = { fg = spec.diag.hint, bg = spec.bg0 },
    BufferLineHintVisible        = { fg = spec.diag.hint, bg = bg_visible },
    BufferLineHintSelected       = { fg = spec.diag.hint, bg = spec.bg1,  bold = true },

    -- Diagnostic count badges (blended to avoid overwhelming the tabline)
    BufferLineErrorDiagnosticSelected = { fg = C(spec.diag.error):blend(C(spec.bg1),    0.25):to_css(), bg = spec.bg1,    bold = true },
    BufferLineErrorDiagnostic         = { fg = C(spec.diag.error):blend(C(spec.bg0),    0.40):to_css(), bg = spec.bg0,    bold = true },
    BufferLineErrorDiagnosticVisible  = { fg = C(spec.diag.error):blend(C(bg_visible),  0.30):to_css(), bg = bg_visible,  bold = true },

    BufferLineWarningDiagnosticSelected = { fg = C(spec.diag.warn):blend(C(spec.bg1),   0.25):to_css(), bg = spec.bg1,    bold = true },
    BufferLineWarningDiagnostic         = { fg = C(spec.diag.warn):blend(C(spec.bg0),   0.40):to_css(), bg = spec.bg0,    bold = true },
    BufferLineWarningDiagnosticVisible  = { fg = C(spec.diag.warn):blend(C(bg_visible), 0.30):to_css(), bg = bg_visible,  bold = true },

    BufferLineInfoDiagnosticSelected  = { fg = C(spec.diag.info):blend(C(spec.bg1),    0.25):to_css(), bg = spec.bg1,    bold = true },
    BufferLineInfoDiagnostic          = { fg = C(spec.diag.info):blend(C(spec.bg0),    0.40):to_css(), bg = spec.bg0,    bold = true },
    BufferLineInfoDiagnosticVisible   = { fg = C(spec.diag.info):blend(C(bg_visible),  0.30):to_css(), bg = bg_visible,  bold = true },

    BufferLineHintDiagnosticSelected  = { fg = C(spec.diag.hint):blend(C(spec.bg1),    0.25):to_css(), bg = spec.bg1,    bold = true },
    BufferLineHintDiagnostic          = { fg = C(spec.diag.hint):blend(C(spec.bg0),    0.40):to_css(), bg = spec.bg0,    bold = true },
    BufferLineHintDiagnosticVisible   = { fg = C(spec.diag.hint):blend(C(bg_visible),  0.30):to_css(), bg = bg_visible,  bold = true },

    -- Duplicates
    BufferLineDuplicate          = { fg = spec.fg3, bg = spec.bg0,    italic = true },
    BufferLineDuplicateVisible   = { fg = spec.fg3, bg = bg_visible,  italic = true },
    BufferLineDuplicateSelected  = { fg = spec.fg2, bg = spec.bg1,    italic = true },

    -- Pick (buffer picking mode)
    BufferLinePick               = { fg = spec.diag.error, bg = spec.bg0,   bold = true },
    BufferLinePickVisible        = { fg = spec.diag.error, bg = bg_visible, bold = true },
    BufferLinePickSelected       = { fg = spec.diag.error, bg = spec.bg1,   bold = true },

    -- Number labels (shown when bufferline `numbers` option is set)
    BufferLineNumbers             = { fg = spec.fg3, bg = spec.bg0                },
    BufferLineNumbersVisible      = { fg = spec.fg3, bg = bg_visible              },
    BufferLineNumbersSelected     = { fg = spec.fg1, bg = spec.bg1,  bold = true  },

    -- Truncation marker (shown when tabline runs out of space)
    BufferLineTruncMarker         = { fg = spec.fg3, bg = spec.bg0 },

    -- Tab separators (tab-mode, all three states)
    BufferLineTabSeparatorVisible = { fg = spec.bg0, bg = bg_visible },

    -- Offset (file explorer sidebars)
    BufferLineOffsetSeparator    = { bg = spec.bg0 },

    -- Dev icons — fallback only; per-filetype colors applied dynamically by M.setup().
    BufferLineDevIconDefault         = { fg = spec.fg2, bg = spec.bg0  },
    BufferLineDevIconDefaultSelected = { fg = spec.fg1, bg = spec.bg1  },
    BufferLineDevIconDefaultInactive = { fg = spec.fg2, bg = spec.bg0  },
    BufferLineDevIconDefaultVisible  = { fg = spec.fg2, bg = bg_visible },
  }
end

return M
