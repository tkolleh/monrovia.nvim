# Neovim v0.10+ Modernization Project - Agent Context

> **Worktree**: `nvim-modernization`  
> **Branch**: `nvim-modernization`  
> **Goal**: Modernize nightfox.nvim for Neovim v0.10+ only, removing Vim 9 compatibility

---

## Project Overview

This is a fork of [nightfox.nvim](https://github.com/EdenEast/nightfox.nvim), a highly customizable colorscheme for Neovim. The original project supports both Vim 9 + Lua 5.1 and Neovim 0.8+. 

**This worktree implements a clean break**: Neovim 0.10+ only, removing all Vim compatibility code and modernizing APIs.

---

## What Changed (User Decision Summary)

Based on the discovery session:
- **A2: D** - All API modernization (vim.loop→vim.uv, loadstring→load, etc.)
- **A3: C** - No new plugins, focus on core improvements
- **A4: D** - Drop Vim support, pure Neovim-only
- **A5: C** - Leave color schemes as-is

---

## Architecture

```
lua/nightfox/
├── init.lua              # Main entry point - REMOVE is_vim checks
├── config.lua            # Configuration - no changes needed
├── lib/
│   ├── color.lua         # Color library - no changes
│   ├── compiler.lua      # Bytecode compiler - loadstring→load
│   ├── deprecation.lua   # Deprecation notices - modernize autocmds
│   ├── highlight.lua     # Highlight utilities - no changes
│   ├── log.lua           # Logging - remove is_nvim checks
│   └── vim/              # DELETE THIS DIRECTORY (Vim compatibility)
│       ├── compiler.lua
│       └── init.lua
├── group/                # Highlight group definitions
│   ├── editor.lua
│   ├── syntax.lua
│   ├── terminal.lua
│   └── modules/          # Plugin highlight groups
├── palette/              # Color palettes (nightfox, dayfox, etc.)
├── spec.lua              # Palette→spec mapping
├── palette.lua           # Palette loader
└── util/
    └── init.lua          # Utilities - simplify cache logic
```

---

## Implementation Order

### Phase 1: Remove Vim Compatibility (CRITICAL)
1. **Delete** `lua/nightfox/lib/vim/` directory entirely
2. **Update** `lua/nightfox/init.lua` - Remove is_vim conditional loading
3. **Update** `lua/nightfox/util/init.lua` - Simplify to use vim.fn.stdpath only
4. **Update** `lua/nightfox/lib/deprecation.lua` - Remove vim fallback
5. **Update** `lua/nightfox/lib/log.lua` - Remove is_nvim checks

### Phase 2: API Modernization (HIGH)
6. **Update** `lua/nightfox/lib/compiler.lua` - loadstring→load
7. **Update** `test/init.lua` - vim.loop→vim.uv
8. **Update** `.github/minimal_init.lua` - vim.loop→vim.uv
9. **Update** `misc/feline.lua` - nvim_get_hl_by_name→nvim_get_hl
10. **Update** `misc/tabby.lua` - nvim_get_hl_by_name→nvim_get_hl
11. **Update** `lua/nightfox/lib/deprecation.lua` - vim.cmd→nvim_create_autocmd

### Phase 3: Documentation & Validation (MEDIUM)
12. **Update** `readme.md` - Change requirements to Neovim 0.10+
13. **Create** `lua/nightfox/health.lua` - Add health check module
14. **Run** `make test` - Validate all tests pass
15. **Run** `make check` - Validate stylua formatting

---

## Specific Code Changes

### 1. Delete lua/nightfox/lib/vim/ directory

**Files to delete:**
- `lua/nightfox/lib/vim/compiler.lua`
- `lua/nightfox/lib/vim/init.lua`

### 2. lua/nightfox/init.lua - Remove is_vim checks

**Current (lines 1-2, 30):**
```lua
local is_vim = vim.fn.has("nvim") ~= 1
if is_vim then
  -- ... vim-specific setup
end
local compiler = require("nightfox.lib." .. (is_vim and "vim." or "") .. "compiler")
```

**Replace with:**
```lua
local compiler = require("nightfox.lib.compiler")
```

### 3. lua/nightfox/util/init.lua - Simplify cache logic

**Remove lines 29-31:**
```lua
M.is_nvim = vim.fn.has("nvim") == 1
M.use_nvim_api = M.is_nvim and vim.fn.has("nvim-0.7") == 1
```

**Remove lines 64-71 (vim_cache_home function):**
```lua
local function vim_cache_home()
  if M.is_windows then
    return M.join_paths(vim.fn.expand("%localappdata%"), "Temp", "vim")
  end
  local xdg = os.getenv("XDG_CACHE_HOME")
  local root = xdg or vim.fn.expand("$HOME/.cache")
  return M.join_paths(root, "vim")
end
```

**Replace line 73:**
```lua
-- Before
M.cache_home = M.is_nvim and vim.fn.stdpath("cache") or vim_cache_home()

-- After
M.cache_home = vim.fn.stdpath("cache")
```

### 4. lua/nightfox/lib/deprecation.lua - Modernize

**Replace lines 27-35:**
```lua
-- Before
if vim.fn.has("nvim") then
  vim.api.nvim_echo(M._list, true, {})
else
  local msg = {}
  for _, v in ipairs(M._list) do
    table.insert(msg, v[1])
  end
  print(table.concat(msg, ""))
end

-- After
vim.api.nvim_echo(M._list, true, {})
```

**Replace lines 14-20 (vim.cmd autocmd):**
```lua
-- Before
vim.cmd([[
  augroup NightfoxdeprecationMessage
    au!
    autocmd VimEnter * ++once lua require("nightfox.lib.deprecation").flush()
  augroup END
]])

-- After
local augroup = vim.api.nvim_create_augroup("NightfoxdeprecationMessage", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  once = true,
  callback = function()
    require("nightfox.lib.deprecation").flush()
  end,
})
```

### 5. lua/nightfox/lib/compiler.lua - Replace loadstring

**Line 92:**
```lua
-- Before
local f = loadstring(table.concat(lines, "\n"), "=")

-- After
local f = load(table.concat(lines, "\n"), "=")
```

### 6. test/init.lua - Replace vim.loop

**Line 8:**
```lua
-- Before
if not vim.loop.fs_stat(lazypath) then

-- After
if not vim.uv.fs_stat(lazypath) then
```

### 7. .github/minimal_init.lua - Replace vim.loop

**Line 11:**
```lua
-- Before
if not vim.loop.fs_stat(lazypath) then

-- After
if not vim.uv.fs_stat(lazypath) then
```

### 8. misc/feline.lua - Modernize highlight retrieval

**Line 59:**
```lua
-- Before
local hl = vim.api.nvim_get_hl_by_name(name, true)

-- After
local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
```

### 9. misc/tabby.lua - Modernize highlight retrieval

**Line 59:**
```lua
-- Before
local hl = vim.api.nvim_get_hl_by_name(name, true)

-- After
local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
```

### 10. Create lua/nightfox/health.lua

```lua
local M = {}

M.check = function()
  vim.health.start("nightfox.nvim")
  
  -- Check Neovim version
  if vim.fn.has("nvim-0.10") == 0 then
    vim.health.error("Requires Neovim 0.10+")
  else
    vim.health.ok("Using Neovim 0.10+")
  end
  
  -- Check vim.uv availability
  if vim.uv then
    vim.health.ok("vim.uv available (Neovim 0.10+)")
  else
    vim.health.warn("vim.uv not available, using vim.loop fallback")
  end
  
  -- Check compilation cache
  local config = require("nightfox.config")
  local util = require("nightfox.util")
  local path, file = config.get_compiled_info()
  if util.exists(file) then
    vim.health.ok("Compiled colorscheme cache exists")
  else
    vim.health.info("No compiled cache yet (will be created on first run)")
  end
end

return M
```

---

## Testing Commands

```bash
# Formatting check
stylua --check lua/ test -f ./stylua.toml

# Run tests
make test

# Manual test
nvim --clean -u .github/minimal_init.lua
```

---

## Critical Notes for Implementer

1. **Compiled Cache**: The compiler generates bytecode cache files. After these changes, users will need to run `:NightfoxCompile` to regenerate cache.

2. **Breaking Change**: This is a breaking change requiring Neovim 0.10+. Update readme.md requirements section.

3. **Vim.fn calls**: We're keeping `vim.fn.has()` for version checks and `vim.fn.stdpath()` - these are not deprecated.

4. **No Vim Support**: Deleted vim/ directory means Vim 9 users can no longer use this fork. This is intentional.

5. **Testing**: After changes, verify:
   - `:colorscheme nightfox` loads without errors
   - `:NightfoxCompile` works
   - `:checkhealth nightfox` shows all OK
   - `make test` passes

---

## Files Summary

### Deleted (2):
- `lua/nightfox/lib/vim/compiler.lua`
- `lua/nightfox/lib/vim/init.lua`

### Modified (9):
1. `lua/nightfox/init.lua`
2. `lua/nightfox/util/init.lua`
3. `lua/nightfox/lib/compiler.lua`
4. `lua/nightfox/lib/deprecation.lua`
5. `lua/nightfox/lib/log.lua`
6. `test/init.lua`
7. `.github/minimal_init.lua`
8. `misc/feline.lua`
9. `misc/tabby.lua`

### Created (1):
- `lua/nightfox/health.lua`

### Documentation (1):
- `readme.md` (update requirements)

---

## References

- Original repo: https://github.com/EdenEast/nightfox.nvim
- Neovim v0.10 changelog: https://neovim.io/doc/user/news-0.10.html
- vim.uv documentation: `:help vim.uv`
- nvim_create_autocmd: `:help nvim_create_autocmd()`
- nvim_get_hl: `:help nvim_get_hl()`

---

## Questions?

If you encounter unexpected issues:
1. Check if the file has additional Vim compatibility code not listed here
2. Search for `is_vim`, `is_nvim`, `vim.fn.has("nvim")` patterns
3. Run `make check` to catch stylua formatting issues early
4. Test incrementally: make changes, run `:NightfoxCompile`, verify colors load
