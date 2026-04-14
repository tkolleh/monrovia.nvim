-- https://github.com/akinsho/bufferline.nvim

local M = {}

function M.get(spec, config, opts)
  local c = spec.palette

  -- stylua: ignore
  return {
    BufferLineFill               = { bg = spec.bg0 },
    BufferLineBackground         = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineBufferVisible      = { fg = spec.fg2, bg = spec.bg2 },
    BufferLineBufferSelected     = { fg = spec.fg1, bg = spec.bg1, style = "bold" },
    BufferLineSeparator          = { fg = spec.bg4, bg = spec.bg0 },
    BufferLineSeparatorVisible   = { fg = spec.bg4, bg = spec.bg2 },
    BufferLineSeparatorSelected  = { fg = spec.bg4 },

    BufferLineTab                = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineTabSelected        = { fg = spec.fg1, bg = spec.bg1, style = "bold" },
    BufferLineTabClose           = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineTabSeparator       = { fg = spec.bg4, bg = spec.bg1 },
    BufferLineTabSeparatorSelected = { fg = spec.bg4 },

    BufferLineCloseButton        = { fg = spec.fg3, bg = spec.bg0 },
    BufferLineCloseButtonVisible = { fg = spec.fg3, bg = spec.bg2 },
    BufferLineCloseButtonSelected = { fg = spec.diag.error },

    BufferLineModified           = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineModifiedVisible    = { fg = spec.diag.warn, bg = spec.bg2 },
    BufferLineModifiedSelected   = { fg = spec.diag.warn },

    BufferLineError              = { fg = spec.diag.error, bg = spec.bg0 },
    BufferLineErrorVisible       = { fg = spec.diag.error, bg = spec.bg2 },
    BufferLineErrorSelected      = { fg = spec.diag.error },

    BufferLineWarning            = { fg = spec.diag.warn, bg = spec.bg0 },
    BufferLineWarningVisible     = { fg = spec.diag.warn, bg = spec.bg2 },
    BufferLineWarningSelected    = { fg = spec.diag.warn },

    BufferLineInfo               = { fg = spec.diag.info, bg = spec.bg0 },
    BufferLineInfoVisible        = { fg = spec.diag.info, bg = spec.bg2 },
    BufferLineInfoSelected       = { fg = spec.diag.info },

    BufferLineHint               = { fg = spec.diag.hint, bg = spec.bg0 },
    BufferLineHintVisible        = { fg = spec.diag.hint, bg = spec.bg2 },
    BufferLineHintSelected       = { fg = spec.diag.hint },

    BufferLineIndicatorSelected  = { fg = spec.diag.info },
    BufferLineIndicatorVisible   = { fg = spec.diag.info, bg = spec.bg2 },

    BufferLineDuplicate          = { fg = spec.fg3, bg = spec.bg0, style = "italic" },
    BufferLineDuplicateVisible   = { fg = spec.fg3, bg = spec.bg2, style = "italic" },
    BufferLineDuplicateSelected  = { fg = spec.fg3, style = "italic" },

    BufferLinePick               = { fg = spec.diag.error, style = "bold" },
    BufferLinePickVisible        = { fg = spec.diag.error, bg = spec.bg2, style = "bold" },
    BufferLinePickSelected       = { fg = spec.diag.error, style = "bold" },

    BufferLineOffsetSeparator    = { bg = spec.bg0 },
    BufferLineDevIconDefault     = { fg = spec.fg3 },
    BufferLineDevIconDefaultSelected = { fg = spec.fg1 },
  }
end

return M