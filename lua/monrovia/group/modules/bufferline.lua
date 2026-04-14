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

    -- Visible but not active buffers - slightly lighter than background
    BufferLineBufferVisible      = { fg = spec.fg2, bg = spec.bg2 },
    BufferLineCloseButtonVisible = { fg = spec.fg3, bg = spec.bg2 },
    BufferLineModifiedVisible    = { fg = spec.diag.warn, bg = spec.bg2 },
    BufferLineIndicatorVisible   = { fg = spec.diag.info, bg = spec.bg2 },

    -- Selected/active buffer - use bg3 (lighter, distinctive)
    -- This matches the cursor line background for visual consistency
    BufferLineBufferSelected     = { fg = spec.fg1, bg = spec.bg3, style = "bold" },
    BufferLineCloseButtonSelected = { fg = spec.diag.error, bg = spec.bg3 },
    BufferLineModifiedSelected   = { fg = spec.diag.warn, bg = spec.bg3, style = "bold" },
    BufferLineIndicatorSelected  = { fg = spec.diag.info, bg = spec.bg3 },

    -- Separators for slant style:
    -- The separator fg color draws the slant, bg blends with the next area
    -- Inactive separator: slant from bg0 to bg0 (invisible)
    BufferLineSeparator          = { fg = spec.bg0, bg = spec.bg0 },
    -- Visible separator: slant from bg2 to bg0 (if next to inactive) or bg2
    BufferLineSeparatorVisible   = { fg = spec.bg2, bg = spec.bg0 },
    -- Selected separator: slant from bg3 to bg0 or bg2
    BufferLineSeparatorSelected  = { fg = spec.bg3, bg = spec.bg0 },

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
