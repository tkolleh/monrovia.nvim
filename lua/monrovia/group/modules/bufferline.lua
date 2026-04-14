-- https://github.com/akinsho/bufferline.nvim

local M = {}

function M.get(spec, config, opts)
  local c = spec.palette

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
    -- The separator fg color draws the slant, bg blends with the next area
    -- Background to visible: slant from bg0 to bg2
    BufferLineSeparator          = { fg = spec.bg0, bg = spec.bg0 },
    -- Visible to selected: slant from bg0 to bg1
    BufferLineSeparatorVisible   = { fg = spec.bg0, bg = spec.bg1 },
    -- Selected to background: slant from bg1 to bg0
    BufferLineSeparatorSelected  = { fg = spec.bg1, bg = spec.bg0 },

    -- Tabs (when in tab mode)
    BufferLineTab                = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineTabSelected        = { fg = spec.fg1, bg = spec.bg3, style = "bold" },
    BufferLineTabClose           = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineTabSeparator       = { fg = spec.bg0, bg = spec.bg0 },
    BufferLineTabSeparatorSelected = { fg = spec.bg3, bg = spec.bg0 },

    -- Close buttons
    BufferLineCloseButton        = { fg = spec.fg3, bg = spec.bg0 },

    -- Modified indicator
    BufferLineModified           = { fg = spec.diag.warn, bg = spec.bg0 },

    -- Diagnostics - follow the bg0/bg2/bg3 pattern
    BufferLineError              = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineErrorVisible       = { fg = spec.diag.error, bg = spec.bg2 },
    BufferLineErrorSelected      = { fg = spec.diag.error, bg = spec.bg3, style = "bold" },

    BufferLineWarning            = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineWarningVisible     = { fg = spec.diag.warn, bg = spec.bg2 },
    BufferLineWarningSelected    = { fg = spec.diag.warn, bg = spec.bg3, style = "bold" },

    BufferLineInfo               = { fg = spec.diag.info, bg = spec.bg0 },
    BufferLineInfoVisible        = { fg = spec.diag.info, bg = spec.bg2 },
    BufferLineInfoSelected       = { fg = spec.diag.info, bg = spec.bg3, style = "bold" },

    BufferLineHint               = { fg = spec.diag.hint, bg = spec.bg0 },
    BufferLineHintVisible        = { fg = spec.diag.hint, bg = spec.bg2 },
    BufferLineHintSelected       = { fg = spec.diag.hint, bg = spec.bg3, style = "bold" },

    -- Duplicates
    BufferLineDuplicate          = { fg = spec.fg3, bg = spec.bg0, style = "italic" },
    BufferLineDuplicateVisible   = { fg = spec.fg3, bg = spec.bg2, style = "italic" },
    BufferLineDuplicateSelected  = { fg = spec.fg2, bg = spec.bg3, style = "italic" },

    -- Pick (when using buffer picking mode)
    BufferLinePick               = { fg = spec.diag.error, bg = spec.bg0, style = "bold" },
    BufferLinePickVisible        = { fg = spec.diag.error, bg = spec.bg2, style = "bold" },
    BufferLinePickSelected       = { fg = spec.diag.error, bg = spec.bg3, style = "bold" },

    -- Offset (for file explorer sidebars)
    BufferLineOffsetSeparator    = { bg = spec.bg0 },

    -- Dev icons - use palette colors
    BufferLineDevIconDefault     = { fg = spec.fg2 },
    BufferLineDevIconDefaultSelected = { fg = spec.fg1 },
  }
end

return M
