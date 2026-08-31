local C = require("monrovia.lib.color")
local Shade = require("monrovia.lib.shade")

local meta = {
  name = "monrovia_dawn",
  light = true,
}

-- stylua: ignore
local palette = {
  black   = Shade.new("#575279", "#5f5695", "#504c6b", true),
  red     = Shade.new("#a85169", "#b4647a", "#8c4458", true),
  green   = Shade.new("#547565", "#618774", "#435d51", true),
  yellow  = Shade.new("#9e6310", "#ba7413", "#794c0c", true),
  blue    = Shade.new("#286983", "#2d81a3", "#295e73", true),
  magenta = Shade.new("#7b6298", "#8b73a5", "#67527f", true),
  cyan    = Shade.new("#44757e", "#4f8892", "#365d63", true),
  white   = Shade.new("#e5e9f0", "#e6ebf3", "#c8cfde", true),
  orange  = Shade.new("#98591b", "#b26920", "#754515", true),
  pink    = Shade.new("#b73e7c", "#c4508c", "#983468", true),

  comment = "#5d4f64",

  bg0     = "#ebe5df", -- Dark bg (status line and float)
  bg1     = "#fcf8f3", -- Default bg
  bg2     = "#e6ded6", -- Warm paper folds (dawn ramp ~30°)
  bg3     = "#f2ebe3", -- Subtle warm cursor line (near bg1)
  bg4     = "#bdbfc9", -- Conceal, border fg

  fg0     = "#4c4769", -- Lighter fg
  fg1     = "#2b293c", -- Default fg
  fg2     = "#4c4869", -- Darker fg (status line)
  fg3     = "#2c2932", -- Darker fg (line numbers, fold colums)

  sel0    = "#d0d8d8", -- Popup bg, visual selection bg
  sel1    = "#b8cece", -- Popup sel bg, search bg
}

local function generate_spec(pal)
  -- stylua: ignore start
  local spec = {
    bg0  = pal.bg0,  -- Dark bg (status line and float)
    bg1  = pal.bg1,  -- Default bg
    bg2  = pal.bg2,  -- Lighter bg (colorcolm folds)
    bg3  = pal.bg3,  -- Lighter bg (cursor line)
    bg4  = pal.bg4,  -- Conceal, border fg

    fg0  = pal.fg0,  -- Lighter fg
    fg1  = pal.fg1,  -- Default fg
    fg2  = pal.fg2,  -- Darker fg (status line)
    fg3  = pal.fg3,  -- Darker fg (line numbers, fold colums)

    sel0 = pal.sel0, -- Popup bg, visual selection bg
    sel1 = pal.sel1, -- Popup sel bg, search bg
  }

  spec.syntax = {
    bracket     = spec.fg2,         -- Brackets and Punctuation
    builtin0    = pal.red.base,     -- Builtin variable
    builtin1    = pal.cyan.dim,     -- Builtin type
    builtin2    = pal.orange.dim,   -- Builtin const
    builtin3    = pal.red.dim,      -- Not used
    comment     = pal.comment,      -- Comment
    conditional = pal.magenta.dim,  -- Conditional and loop
    const       = pal.orange.dim,   -- Constants, imports and booleans
    dep         = spec.fg3,         -- Deprecated
    field       = pal.blue.base,    -- Field
    func        = pal.blue.dim,     -- Functions and Titles
    ident       = pal.cyan.base,    -- Identifiers
    keyword     = pal.magenta.base, -- Keywords
    number      = pal.orange.base,  -- Numbers
    operator    = spec.fg2,         -- Operators
    preproc     = pal.pink.dim,     -- PreProc
    regex       = pal.yellow.dim,   -- Regex
    statement   = pal.magenta.base, -- Statements
    string      = pal.green.base,   -- Strings
    type        = pal.yellow.base,  -- Types
    variable    = pal.black.base,   -- Variables
  }

  spec.diag = {
    error = pal.red:harsh(),
    warn  = pal.yellow:harsh(),
    info  = pal.blue:harsh(),
    hint  = pal.green:harsh(),
    ok    = pal.green:harsh(),
  }

  spec.diag_bg = {
    error = C(spec.bg1):blend(C(spec.diag.error), 0.3):to_css(),
    warn  = C(spec.bg1):blend(C(spec.diag.warn), 0.3):to_css(),
    info  = C(spec.bg1):blend(C(spec.diag.info), 0.3):to_css(),
    hint  = C(spec.bg1):blend(C(spec.diag.hint), 0.3):to_css(),
    ok    = C(spec.bg1):blend(C(spec.diag.ok), 0.3):to_css(),
  }

  -- Dimmed gutter text (e.g. statuscolumn wrap indicator) on non-cursor lines.
  -- 0.38 favors visible dimming over strict accessibility: day/dawn/dusk land
  -- below the 3:1 floor for dimmed text (user-accepted trade-off) so the
  -- gutter reads as clearly receded; night/midnight/sunset/twilight still
  -- clear 3:1. Drop to ~0.25 to keep all seven above 3:1 if that matters more.
  spec.dim = {
    statuscolumn = C(spec.fg3):blend(C(spec.bg1), 0.38):to_css(),
  }

  -- Decoupled from spec.diag so search-highlight brightness can be tuned
  -- independently of diagnostic colors.
  spec.search_bg = C(spec.bg1):blend(C(pal.green.base), 0.2):to_css()

  -- Fainter than bg2 so LSP inlay hints (type hints, zk note-title previews,
  -- etc.) read as a subtle wash instead of a solid tinted block.
  spec.inlay_hint_bg = C(spec.bg1):blend(C(spec.bg2), 0.3):to_css()

  -- Decoupled from spec.diag; mixed 0.7 toward bg1 for a lighter squiggle
  -- (undercurl sp has no text-fill AA obligation, unlike diag/diag_bg).
  spec.spell = {
    error = "#ae7782",
    warn  = "#a37b4e",
    info  = "#6a8896",
    hint  = "#76887d",
  }

  spec.diff = {
    add    = C(spec.bg1):blend(C(pal.green.base), 0.2):to_css(),
    delete = C(spec.bg1):blend(C(pal.red.base), 0.2):to_css(),
    change = C(spec.bg1):blend(C(pal.blue.base), 0.2):to_css(),
    text   = C(spec.bg1):blend(C(pal.blue.base), 0.4):to_css(),
  }

  spec.git = {
    add      = pal.green.base,
    removed  = pal.red.base,
    changed  = pal.yellow.base,
    conflict = pal.orange.base,
    ignored  = pal.comment,
  }

  -- stylua: ignore start

  return spec
end

return { meta = meta, palette = palette, generate_spec = generate_spec }
