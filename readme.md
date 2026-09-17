> **⚠️ Hardfork notice**: monrovia.nvim began as a hardfork of [nightfox.nvim](https://github.com/EdenEast/nightfox.nvim). We honor the original work by EdenEast; monrovia.nvim is now an independent project.

<p align="center">
  <img width="128" height="128" src="assets/coat_of_arms_of_liberia.png" />
</p>

<h1 align="center">Monrovia</h1>

<p align="center">
  A highly customizable theme for neovim with support for lsp, treesitter and a variety of plugins.
</p>

<div align="center">
  <h3>Monrovia Night</h3><img src="https://user-images.githubusercontent.com/2746374/158456286-9e3ee657-60e6-49d8-b85e-dcab285b31c3.png" alt="monrovia_night" style="border-radius:1%" />
  <h3>Monrovia Day</h3><img src="https://user-images.githubusercontent.com/2746374/210672782-6b8690d0-3ef5-4f32-bdea-4f0a97b9d9d5.png" alt="monrovia_day" style="border-radius:1%" />
</div>

## ⚠️ Breaking changes in v4.0.0

- **Neovim 0.10+ required.** Vim and Neovim below 0.10 are no longer supported.
- **Run `:MonroviaCompile`** after upgrading to regenerate the cache.

## Styles

Seven variants ship with the plugin. Each one is its own colorscheme name.

| Dark | Light |
| --- | --- |
| `monrovia_night`, `monrovia_dusk`, `monrovia_midnight`, `monrovia_sunset`, `monrovia_twilight` | `monrovia_dawn`, `monrovia_day` |

## Installation

Use your favorite package manager.

```lua
{ "tkolleh/monrovia.nvim" } -- lazy.nvim
```

```lua
vim.pack.add({ "https://github.com/tkolleh/monrovia.nvim" }) -- vim.pack (builtin, Neovim 0.12+)
```

```lua
MiniDeps.add("tkolleh/monrovia.nvim") -- mini.deps
```

## Usage

Pick a style and set it with `:colorscheme`. That is the whole setup.

```lua
vim.cmd("colorscheme monrovia_night")
```

Matching [lualine](https://github.com/nvim-lualine/lualine.nvim) and [lightline](https://github.com/itchyny/lightline.vim) themes are included under the same names.

## Configuration

You only need to call `setup` if you want to change something. Any option you leave out keeps its default.

```lua
require("monrovia").setup({
  options = {
    compile_path = vim.fn.stdpath("cache") .. "/monrovia", -- Where compiled files are written
    compile_file_suffix = "_compiled", -- Compiled file suffix
    transparent = false,     -- Don't set a background, use the terminal's
    terminal_colors = true,  -- Set `vim.g.terminal_color_*` for `:terminal`
    dim_inactive = false,    -- Darken non-focused windows
    module_default = true,   -- Default enable value for modules
    colorblind = {
      enable = false,        -- Enable color vision deficiency support
      simulate_only = false, -- Only show simulated colors, not diff shifted
      severity = {
        protan = 0,          -- Severity [0,1] for protan (red)
        deutan = 0,          -- Severity [0,1] for deutan (green)
        tritan = 0,          -- Severity [0,1] for tritan (blue)
      },
    },
    styles = {               -- Any valid attr-list value, see `:help attr-list`
      comments = "NONE",
      conditionals = "NONE",
      constants = "NONE",
      functions = "NONE",
      keywords = "NONE",
      numbers = "NONE",
      operators = "NONE",
      preprocs = "NONE",
      strings = "NONE",
      types = "NONE",
      variables = "NONE",
    },
    inverse = {              -- Swap fg and bg instead of the normal highlight
      match_paren = false,
      visual = false,
      search = false,
    },
    modules = {              -- Per-plugin highlight support, see below.
      bufferline = true,     -- Modules not listed here follow `module_default`.
      coc = { background = true },
      diagnostic = { enable = true, background = true },
      native_lsp = { enable = true, background = true },
      treesitter = true,
      lsp_semantic_tokens = true,
      leap = { background = true },
    },
  },
  palettes = {},             -- Override colors
  specs = {},                -- Override how colors map to meanings
  groups = {},               -- Override highlight groups
})

-- setup must be called before loading
vim.cmd("colorscheme monrovia_night")
```

So a config that only italicizes comments is just:

```lua
require("monrovia").setup({
  options = { styles = { comments = "italic" } },
})
```

Every option is described in full in `:help monrovia-option`.

### Modules

Modules hold the highlight support for individual plugins and Neovim features. They are all on by default. Set a module to `false` to turn it off, or pass a table when it has extra settings:

```lua
require("monrovia").setup({
  options = {
    module_default = false,        -- Opt in instead of opt out
    modules = {
      telescope = true,
      native_lsp = { enable = true, background = false },
    },
  },
})
```

See [Supported plugins](#supported-plugins) for the list, and `:help monrovia-modules` for each module's settings.

## Custom colors

Three layers let you change colors, from lowest to highest: **palettes** are the raw colors, **specs** map those colors to meanings like `syntax.keyword` or `git.add`, and **groups** are the final highlight groups. Each layer takes an `all` table applied to every style, plus per-style tables that win over `all`.

Values that don't start with `#` are treated as a path into the layer below, so `"magenta"`, `"magenta.bright"` and `"syntax.string"` all work as references.

```lua
require("monrovia").setup({
  palettes = {
    all = { red = "#ff0000" },
    monrovia_day = { blue = { base = "#4d688e", bright = "#4e75aa", dim = "#485e7d" } },
  },
  specs = {
    all = { syntax = { keyword = "magenta.bright" } },
  },
  groups = {
    all = { Whitespace = { link = "Comment" } },
    monrovia_night = { IncSearch = { bg = "palette.cyan" } },
  },
})

vim.cmd("colorscheme monrovia_night")
```

You can also invent your own spec values and reference them from groups, which is handy when one color is currently shared by several things you want to split apart.

For the full field lists, the template rules, and more examples, see `:help monrovia-palette`, `:help monrovia-spec`, `:help monrovia-group` and `:help monrovia-templates`. To find the name of a highlight group, see `:help group-name` and `:help nvim-treesitter-highlights`.

## Commands

| Command | What it does |
| --- | --- |
| `:MonroviaCompile` | Rebuild the compiled cache (also available as `require("monrovia").compile()`) |
| `:MonroviaInteractive` | Reload your config and the colorscheme every time you save the current file |

Monrovia pre-computes your configuration and caches the result as Lua bytecode, which keeps startup fast. This happens automatically when your config changes, so `:MonroviaCompile` is only needed if something gets out of sync. Compiled files go in your Neovim cache directory (`:echo stdpath("cache")`) by default.

`:MonroviaInteractive` sources the current file on every write, so a syntax error in it will raise an error. It also won't work if your monrovia config lives in a package manager's `config = function() end` block that needs recompiling.

## Api

Monrovia exposes the data it builds. You can read the spec for any style:

```lua
local spec = require("monrovia.spec").load("monrovia_night")
print(vim.inspect(spec.git))
-- {
--   add = "#81b29a",
--   changed = "#dbc074",
--   conflict = "#f4a261",
--   ignored = "#acb4be",
--   removed = "#c94f6d"
-- }
```

The color library it uses internally is available too, with conversions between hex, RGBA, HSV and HSL plus operations like `blend`, `shade`, `brighten` and `saturate`:

```lua
local Color = require("monrovia.lib.color")
print(Color.from_hex("#192330"):blend(Color.from_hex("#ff0000"), 0.2):to_css())
-- "#471c26"
```

Full signatures are in `:help monrovia-spec` and `:help monrovia-color`.

## Supported plugins

- [alpha-nvim](https://github.com/goolord/alpha-nvim)
- [aerial.nvim](https://github.com/stevearc/aerial.nvim)
- [barbar.nvim](https://github.com/romgrk/barbar.nvim)
- [blink.cmp](https://github.com/saghen/blink.cmp)
- [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [coc.nvim](https://github.com/neoclide/coc.nvim)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [dashboard-nvim](https://github.com/glepnir/dashboard-nvim)
- [fern.vim](https://github.com/lambdalisue/fern.vim)
- [fidget.nvim](https://github.com/j-hui/fidget.nvim)
- [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [glyph-palette.vim](https://github.com/lambdalisue/glyph-palette.vim)
- [hop.nvim](https://github.com/phaazon/hop.nvim)
- [vim-illuminate](https://github.com/RRethy/vim-illuminate)
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [leap.nvim](https://github.com/ggandor/leap.nvim)
- [lightspeed.nvim](https://github.com/ggandor/lightspeed.nvim)
- [lspsaga.nvim](https://github.com/glepnir/lspsaga.nvim)
- [lsp-trouble.nvim](https://github.com/simrat39/lsp-trouble.nvim)
- [mini.nvim](https://github.com/echasnovski/mini.nvim)
- [modes.nvim](https://github.com/mvllow/modes.nvim)
- [nvim-navic](https://github.com/SmiteshP/nvim-navic)
- [neogit](https://github.com/NeogitOrg/neogit)
- [neotest](https://github.com/nvim-neotest/neotest)
- [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim)
- [nvim-notify](https://github.com/rcarriga/nvim-notify)
- [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)
- [pounce.nvim](https://github.com/rlane/pounce.nvim)
- [vim-signify](https://github.com/mhinz/vim-signify)
- [vim-sneak](https://github.com/justinmk/vim-sneak)
- [rainbow-delimiters](https://github.com/hiphish/rainbow-delimiters.nvim)
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
- [symbols-outline.nvim](https://github.com/simrat39/symbols-outline.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [nvim-ts-rainbow](https://github.com/p00f/nvim-ts-rainbow)
- [nvim-ts-rainbow2](https://github.com/HiPhish/nvim-ts-rainbow2)
- [which-key.nvim](https://github.com/folke/which-key.nvim)
- native LSP (`vim.lsp`, including semantic tokens) and `vim.diagnostic`

## Acknowledgements

- [nightfox](https://github.com/EdenEast/nightfox.nvim) 🙏🏾
- [catppuccin](https://github.com/catppuccin/nvim/) (integration/modules)
- [rose-pine](https://github.com/rose-pine/nvim) (light palettes)
- [oxocarbon.nvim](https://github.com/shaunsingh/oxocarbon.nvim) (palette inspiration)
- [coolers](https://coolers.co) (useful color information and palette tool)
- [colorhexa](https://www.colorhexa.com/) (detailed color information)
- [neogit](https://github.com/NeogitOrg/neogit/blob/b688a2c/lua/neogit/lib/color.lua) (base for color lib)
- [daltonlens](https://daltonlens.org/) (understanding cvd simulations and research. Thanks [@nburrus](https://github.com/nburrus)!)
