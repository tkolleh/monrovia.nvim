-- https://github.com/akinsho/bufferline.nvim

local M = {}

function M.get(spec, config, opts)
  local c = spec.palette

  -- stylua: ignore
  return {
    -- Fill area (empty space in tabline)
    BufferLineFill               = { bg = spec.bg0 },

    -- Background buffers (not visible)
    BufferLineBackground         = { fg = spec.syntax.comment, bg = spec.bg0 },

    -- Visible but not active buffers
    BufferLineBufferVisible      = { fg = spec.fg2, bg = spec.bg1 },
    BufferLineCloseButtonVisible = { fg = spec.fg3, bg = spec.bg1 },
    BufferLineModifiedVisible    = { fg = spec.diag.warn, bg = spec.bg1 },
    BufferLineIndicatorVisible   = { fg = spec.diag.info, bg = spec.bg1 },

    -- Selected/active buffer - uses fg3 for background like barbar.nvim
    -- This creates a distinctive "popped" look for the active tab
    BufferLineBufferSelected     = { fg = spec.fg1, bg = spec.fg3, style = "bold" },
    BufferLineCloseButtonSelected = { fg = spec.diag.error, bg = spec.fg3 },
    BufferLineModifiedSelected   = { fg = spec.diag.warn, bg = spec.fg3, style = "bold" },
    BufferLineIndicatorSelected  = { fg = spec.diag.info, bg = spec.fg3 },

    -- Separators - subtle, blend with fill
    BufferLineSeparator          = { fg = spec.bg0, bg = spec.bg0 },
    BufferLineSeparatorVisible   = { fg = spec.bg1, bg = spec.bg1 },
    BufferLineSeparatorSelected  = { fg = spec.fg3, bg = spec.fg3 },

    -- Tabs (when in tab mode)
    BufferLineTab                = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineTabSelected        = { fg = spec.fg1, bg = spec.fg3, style = "bold" },
    BufferLineTabClose           = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineTabSeparator       = { fg = spec.bg0, bg = spec.bg0 },
    BufferLineTabSeparatorSelected = { fg = spec.fg3, bg = spec.fg3 },

    -- Close buttons
    BufferLineCloseButton        = { fg = spec.fg3, bg = spec.bg0 },

    -- Modified indicator
    BufferLineModified           = { fg = spec.diag.warn, bg = spec.bg0 },

    -- Diagnostics
    BufferLineError              = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineErrorVisible       = { fg = spec.diag.error, bg = spec.bg1 },
    BufferLineErrorSelected      = { fg = spec.diag.error, bg = spec.fg3, style = "bold" },

    BufferLineWarning            = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineWarningVisible     = { fg = spec.diag.warn, bg = spec.bg1 },
    BufferLineWarningSelected    = { fg = spec.diag.warn, bg = spec.fg3, style = "bold" },

    BufferLineInfo               = { fg = spec.diag.info, bg = spec.bg0 },
    BufferLineInfoVisible        = { fg = spec.diag.info, bg = spec.bg1 },
    BufferLineInfoSelected       = { fg = spec.diag.info, bg = spec.fg3, style = "bold" },

    BufferLineHint               = { fg = spec.diag.hint, bg = spec.bg0 },
    BufferLineHintVisible        = { fg = spec.diag.hint, bg = spec.bg1 },
    BufferLineHintSelected       = { fg = spec.diag.hint, bg = spec.fg3, style = "bold" },

    -- Duplicates
    BufferLineDuplicate          = { fg = spec.fg3, bg = spec.bg0, style = "italic" },
    BufferLineDuplicateVisible   = { fg = spec.fg3, bg = spec.bg1, style = "italic" },
    BufferLineDuplicateSelected  = { fg = spec.fg2, bg = spec.fg3, style = "italic" },

    -- Pick (when using buffer picking mode)
    BufferLinePick               = { fg = spec.diag.error, bg = spec.bg0, style = "bold" },
    BufferLinePickVisible        = { fg = spec.diag.error, bg = spec.bg1, style = "bold" },
    BufferLinePickSelected       = { fg = spec.diag.error, bg = spec.fg3, style = "bold" },

    -- Offset (for file explorer sidebars)
    BufferLineOffsetSeparator    = { bg = spec.bg0 },

    -- Dev icons - use palette colors
    BufferLineDevIconDefault     = { fg = spec.fg2 },
    BufferLineDevIconDefaultSelected = { fg = spec.fg1 },
  }
end

return M
