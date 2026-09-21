local M = {}

function M.get(spec, config, opts)
  local d = spec.diag
  local dbg = spec.diag_bg

  -- stylua: ignore
  return {
    DiagnosticError            = { fg = spec.fg1 },
    DiagnosticWarn             = { fg = spec.fg1 },
    DiagnosticInfo             = { fg = spec.fg1 },
    DiagnosticHint             = { fg = spec.fg1 },
    DiagnosticOk               = { fg = spec.fg1 },

    DiagnosticSignError        = { fg = d.error },
    DiagnosticSignWarn         = { fg = d.warn },
    DiagnosticSignInfo         = { fg = d.info },
    DiagnosticSignHint         = { fg = d.hint },
    DiagnosticSignOk           = { fg = d.ok },

    DiagnosticVirtualTextError = { fg = d.text, bg = dbg.error, style = "italic" },
    DiagnosticVirtualTextWarn  = { fg = d.text, bg = dbg.warn,  style = "italic" },
    DiagnosticVirtualTextInfo  = { fg = d.text, bg = dbg.info,  style = "italic" },
    DiagnosticVirtualTextHint  = { fg = d.text, bg = dbg.hint,  style = "italic" },
    DiagnosticVirtualTextOk    = { fg = d.text, bg = dbg.ok,    style = "italic" },

    DiagnosticUnderlineError   = { style = "undercurl", sp = d.error },
    DiagnosticUnderlineWarn    = { style = "undercurl", sp = d.warn },
    DiagnosticUnderlineInfo    = { style = "undercurl", sp = d.info },
    DiagnosticUnderlineHint    = { style = "undercurl", sp = d.hint },
    DiagnosticUnderlineOk      = { style = "undercurl", sp = d.ok },

    -- Multi-line diagnostic blocks. These link to Diagnostic* by default, which
    -- drops the severity tint the virtual-text groups above carry.
    DiagnosticVirtualLinesError = { fg = d.text, bg = dbg.error, style = "italic" },
    DiagnosticVirtualLinesWarn  = { fg = d.text, bg = dbg.warn,  style = "italic" },
    DiagnosticVirtualLinesInfo  = { fg = d.text, bg = dbg.info,  style = "italic" },
    DiagnosticVirtualLinesHint  = { fg = d.text, bg = dbg.hint,  style = "italic" },
    DiagnosticVirtualLinesOk    = { fg = d.text, bg = dbg.ok,    style = "italic" },

    DiagnosticFloatingError    = { fg = d.error },
    DiagnosticFloatingWarn     = { fg = d.warn },
    DiagnosticFloatingInfo     = { fg = d.info },
    DiagnosticFloatingHint     = { fg = d.hint },
    DiagnosticFloatingOk       = { fg = d.ok },

    -- Neovim hard-codes sp = #FFC0B9 here, which clashes with every palette.
    DiagnosticDeprecated       = { style = "strikethrough", sp = d.error },
    DiagnosticUnnecessary      = { link = "Comment" },
  }
end

return M
