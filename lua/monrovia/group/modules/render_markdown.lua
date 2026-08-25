-- render-markdown.nvim highlight groups
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
local M = {}

function M.get(spec, config, opts)
  -- Only apply to light modes (day, dawn, dusk)
  if not spec.palette.meta.light then
    return {}
  end

  return {
    RenderMarkdownCodeInline = { fg = "#2d7875" }, -- teal-green for inline code
  }
end

return M
