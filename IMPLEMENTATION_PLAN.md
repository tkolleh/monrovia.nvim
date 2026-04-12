# Nightfox.nvim Neovim v0.11+ Modernization Plan

**Version**: 4.0.0 (Breaking Release)  
**Target**: Neovim 0.11+ only  
**Status**: Implementation Ready

---

## Executive Summary

This plan modernizes nightfox.nvim to be a pure Neovim 0.11+ plugin, removing all Vim 9 + Lua 5.1 compatibility code. The changes reduce codebase complexity by ~60 lines and leverage modern Neovim APIs.

### Key Changes
- **Removed**: Vim 9 compatibility layer (`lua/nightfox/lib/vim/`)
- **Modernized**: `vim.loop` → `vim.uv`, `loadstring` → `load`, deprecated highlight APIs
- **Simplified**: Cache logic, compiler selection, utility functions
- **Added**: Health check module for `:checkhealth nightfox`

---

## Phase 1: Remove Vim Compatibility (Priority: CRITICAL)

### 1.1 Delete Vim-Only Directory

**Action**: Permanently delete `lua/nightfox/lib/vim/`

```bash
rm -rf lua/nightfox/lib/vim/
```

**Contents being deleted**:
- `lua/nightfox/lib/vim/compiler.lua` - Vim 9 + Lua 5.1 bytecode compiler
- `lua/nightfox/lib/vim/init.lua` - Vim-specific utilities

**Rationale**: These files are only used when `vim.fn.has("nvim") ~= 1`. Since we're requiring Neovim 0.11+, they're dead code.

---

### 1.2 Simplify Main Init Module

**File**: `lua/nightfox/init.lua`

**Current State** (lines 1-2, 30):
```lua
local is_vim = vim.fn.has("nvim") ~= 1
if is_vim then
  vim.cmd("command! -nargs=1 -complete=customlist,... NightfoxCompile ...")
end
local compiler = require("nightfox.lib." .. (is_vim and "vim." or "") .. "compiler")
```

**Change To**:
```lua
local compiler = require("nightfox.lib.compiler")
```

**Verification**: After change, verify `init.lua` no longer references `is_vim`.

---

### 1.3 Simplify Utility Module

**File**: `lua/nightfox/util/init.lua`

**Changes**:

1. **Remove lines 29-31**:
   ```lua
   -- DELETE these lines
   M.is_nvim = vim.fn.has("nvim") == 1
   M.use_nvim_api = M.is_nvim and vim.fn.has("nvim-0.7") == 1
   ```

2. **Remove lines 64-71** (entire `vim_cache_home` function):
   ```lua
   -- DELETE this entire function
   local function vim_cache_home()
     if M.is_windows then
       return M.join_paths(vim.fn.expand("%localappdata%"), "Temp", "vim")
     end
     local xdg = os.getenv("XDG_CACHE_HOME")
     local root = xdg or vim.fn.expand("$HOME/.cache")
     return M.join_paths(root, "vim")
   end
   ```

3. **Update line 73**:
   ```lua
   -- FROM
   M.cache_home = M.is_nvim and vim.fn.stdpath("cache") or vim_cache_home()
   
   -- TO
   M.cache_home = vim.fn.stdpath("cache")
   ```

**Impact**: Removes ~15 lines of conditional logic. All Neovim users already use `vim.fn.stdpath("cache")` anyway.

---

### 1.4 Update Deprecation Module

**File**: `lua/nightfox/lib/deprecation.lua`

**Change 1** - Remove Vim fallback (lines 27-35):
```lua
-- FROM
if vim.fn.has("nvim") then
  vim.api.nvim_echo(M._list, true, {})
else
  local msg = {}
  for _, v in ipairs(M._list) do
    table.insert(msg, v[1])
  end
  print(table.concat(msg, ""))
end

-- TO
vim.api.nvim_echo(M._list, true, {})
```

**Change 2** - Modernize autocmd (lines 14-20):
```lua
-- FROM
vim.cmd([[
  augroup NightfoxdeprecationMessage
    au!
    autocmd VimEnter * ++once lua require("nightfox.lib.deprecation").flush()
  augroup END
]])

-- TO
local augroup = vim.api.nvim_create_augroup("NightfoxdeprecationMessage", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  once = true,
  callback = function()
    require("nightfox.lib.deprecation").flush()
  end,
})
```

---

### 1.5 Update Log Module

**File**: `lua/nightfox/lib/log.lua`

**Change**: Remove line 3:
```lua
-- DELETE
local is_nvim = vim.fn.has("nvim") == 1
```

**Impact**: The `is_nvim` variable was likely used for conditional logic that's no longer needed.

---

## Phase 2: API Modernization (Priority: HIGH)

### 2.1 Replace loadstring with load

**File**: `lua/nightfox/lib/compiler.lua` (line 92)

**Change**:
```lua
-- FROM
local f = loadstring(table.concat(lines, "\n"), "=")

-- TO
local f = load(table.concat(lines, "\n"), "=")
```

**Rationale**: `loadstring` is deprecated in Lua 5.2+. `load` is available in LuaJIT (which Neovim uses) and Lua 5.2+.

**Risk**: None - Neovim uses LuaJIT 2.1 which supports `load`.

---

### 2.2 Replace vim.loop with vim.uv

**Files**:
- `test/init.lua` (line 8)
- `.github/minimal_init.lua` (line 11)

**Change**:
```lua
-- FROM
if not vim.loop.fs_stat(lazypath) then

-- TO
if not vim.uv.fs_stat(lazypath) then
```

**Rationale**: `vim.loop` is deprecated in Neovim 0.10 in favor of `vim.uv` (direct libuv bindings).

**Note**: `vim.uv` was added in Neovim 0.10. This change enforces our 0.11+ requirement.

---

### 2.3 Modernize Highlight Retrieval APIs

**Files**:
- `misc/feline.lua` (line 59)
- `misc/tabby.lua` (line 59)

**Change**:
```lua
-- FROM (deprecated)
local hl = vim.api.nvim_get_hl_by_name(name, true)

-- TO (Neovim 0.9+)
local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
```

**Important**: Use `link = false` to match original behavior (returns resolved highlight, not linked group name).

---

## Phase 3: Add Health Check (Priority: MEDIUM)

### 3.1 Create Health Check Module

**File**: `lua/nightfox/health.lua` (NEW)

```lua
local M = {}

M.check = function()
  vim.health.start("nightfox.nvim")
  
  -- Check Neovim version
  if vim.fn.has("nvim-0.11") == 0 then
    vim.health.error("Requires Neovim 0.11+")
  else
    vim.health.ok("Using Neovim 0.11+")
  end
  
  -- Check vim.uv availability
  if vim.uv then
    vim.health.ok("vim.uv available")
  else
    vim.health.warn("vim.uv not available")
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

**Purpose**: Users can run `:checkhealth nightfox` to verify their setup.

---

## Phase 4: Documentation Updates (Priority: MEDIUM)

### 4.1 Update README Requirements

**File**: `readme.md` (line 53)

**Change**:
```markdown
-- FROM
- Neovim >= 0.8 **or** Vim 9 with lua = **5.1+**

-- TO
- Neovim >= 0.10
```

### 4.2 Add Breaking Change Notice

**File**: `readme.md` (add after Features section)

```markdown
## ⚠️ Breaking Changes in v4.0.0

- **Dropped Vim 9 support**: This plugin now requires Neovim 0.11+
- **API Modernization**: Uses `vim.uv`, new highlight APIs, and Lua `load`
- **Cache Regeneration**: Run `:NightfoxCompile` after upgrading
```

---

## Testing Strategy

### Automated Testing
```bash
# Run formatting check
make check

# Run test suite
make test
```

### Manual Testing Checklist
- [ ] `:colorscheme nightfox` loads without errors
- [ ] `:colorscheme dayfox`, `duskfox`, `dawnfox`, `nordfox`, `terafox`, `carbonfox` all work
- [ ] `:NightfoxCompile` completes successfully
- [ ] `:checkhealth nightfox` shows all OK
- [ ] Edit a file, see syntax highlighting works
- [ ] Open a file with LSP, see semantic highlighting works
- [ ] Test with a plugin that uses nightfox highlights (telescope, which-key, etc.)

### Cache Testing
```vim
" Clear cache
:!rm -rf ~/.cache/nvim/nightfox

" Recompile
:NightfoxCompile

" Verify file created
:!ls ~/.cache/nvim/nightfox/
```

---

## Rollback Plan

If critical issues are found:

1. **Immediate**: Users can pin to v3.x in their plugin manager:
   ```lua
   -- lazy.nvim
   { "EdenEast/nightfox.nvim", tag = "v3.10.0" }
   ```

2. **Fix Forward**: Create patch release v4.0.1 with fixes

3. **Document**: Update README with known issues and workarounds

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Users on Neovim 0.9 break | Medium | High | Clear version requirement in README |
| Compiled cache issues | Low | Medium | `:NightfoxCompile` regenerates cache |
| Windows path edge cases | Low | Low | `vim.fn.stdpath("cache")` works on all platforms |
| Plugin manager issues | Low | Low | Health check helps diagnose |

---

## Summary of Changes

### Lines of Code Impact
- **Deleted**: ~60 lines (vim compatibility)
- **Modified**: ~25 lines (API updates)
- **Added**: ~35 lines (health check, documentation)
- **Net**: ~100 lines changed, simpler codebase

### Files Modified
1. `lua/nightfox/init.lua` - Simplify compiler loading
2. `lua/nightfox/util/init.lua` - Remove vim_cache_home, is_nvim
3. `lua/nightfox/lib/compiler.lua` - loadstring → load
4. `lua/nightfox/lib/deprecation.lua` - Modernize autocmds, remove vim fallback
5. `lua/nightfox/lib/log.lua` - Remove is_nvim variable
6. `test/init.lua` - vim.loop → vim.uv
7. `.github/minimal_init.lua` - vim.loop → vim.uv
8. `misc/feline.lua` - nvim_get_hl_by_name → nvim_get_hl
9. `misc/tabby.lua` - nvim_get_hl_by_name → nvim_get_hl
10. `lua/nightfox/health.lua` - NEW file
11. `readme.md` - Update requirements, add breaking change notice

### Files Deleted
1. `lua/nightfox/lib/vim/compiler.lua`
2. `lua/nightfox/lib/vim/init.lua`

---

## Success Criteria

✅ All tests pass (`make test`)  
✅ Formatting check passes (`make check`)  
✅ `:colorscheme nightfox` works  
✅ `:NightfoxCompile` works  
✅ `:checkhealth nightfox` shows all OK  
✅ No references to `is_vim`, `vim.loop`, `loadstring`, or `nvim_get_hl_by_name` remain  

---

## Implementation Checklist

- [ ] Phase 1.1: Delete lua/nightfox/lib/vim/ directory
- [ ] Phase 1.2: Update lua/nightfox/init.lua
- [ ] Phase 1.3: Update lua/nightfox/util/init.lua
- [ ] Phase 1.4: Update lua/nightfox/lib/deprecation.lua
- [ ] Phase 1.5: Update lua/nightfox/lib/log.lua
- [ ] Phase 2.1: Update lua/nightfox/lib/compiler.lua
- [ ] Phase 2.2: Update test/init.lua
- [ ] Phase 2.3: Update .github/minimal_init.lua
- [ ] Phase 2.4: Update misc/feline.lua
- [ ] Phase 2.5: Update misc/tabby.lua
- [ ] Phase 3.1: Create lua/nightfox/health.lua
- [ ] Phase 4.1: Update readme.md
- [ ] Testing: Run `make check` and `make test`
- [ ] Testing: Manual verification checklist
- [ ] Documentation: Update CHANGELOG.md

---

**Ready for Implementation**: All phases are designed to be independent and can be implemented in order or in parallel (except Phase 4 which should come last).
