# Quick Reference: Neovim Modernization Changes

## One-Line Summary of Each File Change

| File | Change Type | Line(s) | From | To |
|------|-------------|---------|------|-----|
| `lua/nightfox/lib/vim/compiler.lua` | **DELETE** | - | - | - |
| `lua/nightfox/lib/vim/init.lua` | **DELETE** | - | - | - |
| `lua/nightfox/init.lua` | Edit | 1-2, 30 | `is_vim` check + dynamic require | `require("nightfox.lib.compiler")` |
| `lua/nightfox/util/init.lua` | Edit | 29-31 | `is_nvim`, `use_nvim_api` vars | **DELETE** |
| `lua/nightfox/util/init.lua` | Edit | 64-71 | `vim_cache_home()` function | **DELETE** |
| `lua/nightfox/util/init.lua` | Edit | 73 | `is_nvim and stdpath or vim_cache` | `vim.fn.stdpath("cache")` |
| `lua/nightfox/lib/compiler.lua` | Edit | 92 | `loadstring(...)` | `load(...)` |
| `lua/nightfox/lib/deprecation.lua` | Edit | 14-20 | `vim.cmd` autocmd block | `nvim_create_augroup` + `nvim_create_autocmd` |
| `lua/nightfox/lib/deprecation.lua` | Edit | 27-35 | `if vim.fn.has("nvim")` block | `vim.api.nvim_echo(...)` only |
| `lua/nightfox/lib/log.lua` | Edit | 3 | `local is_nvim = ...` | **DELETE** |
| `test/init.lua` | Edit | 8 | `vim.loop.fs_stat` | `vim.uv.fs_stat` |
| `.github/minimal_init.lua` | Edit | 11 | `vim.loop.fs_stat` | `vim.uv.fs_stat` |
| `misc/feline.lua` | Edit | 59 | `nvim_get_hl_by_name(name, true)` | `nvim_get_hl(0, { name = name, link = false })` |
| `misc/tabby.lua` | Edit | 59 | `nvim_get_hl_by_name(name, true)` | `nvim_get_hl(0, { name = name, link = false })` |
| `lua/nightfox/health.lua` | **CREATE** | - | - | New health check module |
| `readme.md` | Edit | 53 | `Neovim >= 0.8 or Vim 9` | `Neovim >= 0.10` |

---

## Exact Code Changes (Copy-Paste Ready)

### 1. lua/nightfox/init.lua

**Find and delete lines 1-2:**
```lua
local is_vim = vim.fn.has("nvim") ~= 1
if is_vim then
  vim.cmd("command! -nargs=1 -complete=customlist,nightfox#complete Styles call nightfox#init(<q-args>)")
end
```

**Find line 30:**
```lua
local compiler = require("nightfox.lib." .. (is_vim and "vim." or "") .. "compiler")
```

**Replace with:**
```lua
local compiler = require("nightfox.lib.compiler")
```

---

### 2. lua/nightfox/util/init.lua

**Delete lines 29-31:**
```lua
M.is_nvim = vim.fn.has("nvim") == 1
M.use_nvim_api = M.is_nvim and vim.fn.has("nvim-0.7") == 1
```

**Delete lines 64-71 (entire function):**
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

**Change line 73:**
```lua
-- FROM
M.cache_home = M.is_nvim and vim.fn.stdpath("cache") or vim_cache_home()

-- TO
M.cache_home = vim.fn.stdpath("cache")
```

---

### 3. lua/nightfox/lib/compiler.lua

**Line 92:**
```lua
-- FROM
local f = loadstring(table.concat(lines, "\n"), "=")

-- TO
local f = load(table.concat(lines, "\n"), "=")
```

---

### 4. lua/nightfox/lib/deprecation.lua

**Replace lines 14-20:**
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

**Replace lines 27-35:**
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

---

### 5. lua/nightfox/lib/log.lua

**Delete line 3:**
```lua
local is_nvim = vim.fn.has("nvim") == 1
```

---

### 6. test/init.lua

**Line 8:**
```lua
-- FROM
if not vim.loop.fs_stat(lazypath) then

-- TO
if not vim.uv.fs_stat(lazypath) then
```

---

### 7. .github/minimal_init.lua

**Line 11:**
```lua
-- FROM
if not vim.loop.fs_stat(lazypath) then

-- TO
if not vim.uv.fs_stat(lazypath) then
```

---

### 8. misc/feline.lua

**Line 59:**
```lua
-- FROM
local hl = vim.api.nvim_get_hl_by_name(name, true)

-- TO
local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
```

---

### 9. misc/tabby.lua

**Line 59:**
```lua
-- FROM
local hl = vim.api.nvim_get_hl_by_name(name, true)

-- TO
local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
```

---

### 10. lua/nightfox/health.lua (NEW FILE)

**Create with contents:**
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

---

### 11. readme.md

**Line 53, change:**
```markdown
FROM:
- Neovim >= 0.8 **or** Vim 9 with lua = **5.1+**

TO:
- Neovim >= 0.10
```

**Add after Features section:**
```markdown
## ⚠️ Breaking Changes in v4.0.0

- **Dropped Vim 9 support**: This plugin now requires Neovim 0.10+
- **API Modernization**: Uses `vim.uv`, new highlight APIs, and Lua `load`
- **Cache Regeneration**: Run `:NightfoxCompile` after upgrading
```

---

## Post-Implementation Verification

### 1. Check for remaining deprecated patterns
```bash
grep -r "vim\.loop" lua/ test/ .github/ misc/ || echo "No vim.loop references found ✓"
grep -r "loadstring" lua/ || echo "No loadstring references found ✓"
grep -r "nvim_get_hl_by_name" misc/ || echo "No nvim_get_hl_by_name references found ✓"
grep -r "is_vim\|is_nvim" lua/ || echo "No is_vim/is_nvim references found ✓"
```

### 2. Run tests
```bash
cd /Users/tkolleh/ws/nightfox.nvim/main.nvim-modernization
make check
make test
```

### 3. Manual verification
```vim
:colorscheme nightfox
:NightfoxCompile
:checkhealth nightfox
```

---

## Troubleshooting

### Issue: `vim.uv` not found
**Cause**: Running on Neovim < 0.10  
**Solution**: Update to Neovim 0.10+

### Issue: Tests fail after changes
**Cause**: Compiled cache incompatible  
**Solution**: 
```bash
rm -rf ~/.cache/nvim/nightfox
make test
```

### Issue: Stylua formatting errors
**Cause**: Code not formatted correctly  
**Solution**:
```bash
stylua lua/ test -f ./stylua.toml
```

---

## Commit Message Template

```
feat!: modernize for neovim 0.10+

BREAKING CHANGE: Drop Vim 9 support, require Neovim 0.10+

Changes:
- Remove lua/nightfox/lib/vim/ compatibility layer
- Replace vim.loop with vim.uv
- Replace loadstring with load
- Modernize nvim_get_hl_by_name to nvim_get_hl
- Modernize vim.cmd autocmds to nvim_create_autocmd
- Simplify cache logic to use vim.fn.stdpath only
- Add health check module

Migration:
Users on Neovim 0.9 or earlier should remain on v3.x
Users upgrading should run :NightfoxCompile after update
```
