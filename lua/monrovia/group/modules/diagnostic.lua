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

    DiagnosticVirtualTextError = { fg = spec.fg1, bg = dbg.error },
    DiagnosticVirtualTextWarn  = { fg = spec.fg1, bg = dbg.warn },
    DiagnosticVirtualTextInfo  = { fg = spec.fg1, bg = dbg.info },
    DiagnosticVirtualTextHint  = { fg = spec.fg1, bg = dbg.hint },
    DiagnosticVirtualTextOk    = { fg = spec.fg1, bg = dbg.ok },

    DiagnosticUnderlineError   = { style = "undercurl", sp = d.error },
    DiagnosticUnderlineWarn    = { style = "undercurl", sp = d.warn },
    DiagnosticUnderlineInfo    = { style = "undercurl", sp = d.info },
    DiagnosticUnderlineHint    = { style = "undercurl", sp = d.hint },
    DiagnosticUnderlineOk      = { style = "undercurl", sp = d.ok },
  }
end

return M
