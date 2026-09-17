local group = require("monrovia.group")
local palette = require("monrovia.palette")

local function is_color(value)
  return value == nil or value == "NONE" or (type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil)
end

---True when `name` resolves to something Neovim already knows about, i.e. a
---built-in group that exists before any colorscheme is applied.
local function is_builtin(name)
  return not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = name, link = true }))
end

---Every `*hl-Name*` tag Neovim documents, read from the running runtime so the
---list tracks whatever version the suite executes against.
local function documented_builtins()
  local names = {}
  for _, file in ipairs(vim.fn.globpath(vim.env.VIMRUNTIME .. "/doc", "*.txt", false, true)) do
    for _, line in ipairs(vim.fn.readfile(file)) do
      for name in line:gmatch("%*hl%-([A-Za-z@._0-9]+)%*") do
        names[name] = true
      end
    end
  end
  return names
end

-- Groups we deliberately leave to Neovim's default, with the reason.
local UNCOVERED = {
  TermCursor = "reverse default is theme-independent; see editor.lua",
  TermCursorNC = "reverse default is theme-independent; see editor.lua",
  MsgArea = "unset on purpose, upstream nightfox issue #98",
  MsgSeparator = "unset on purpose, upstream nightfox issue #98",
  Menu = "GUI-only, inert in a terminal",
  Scrollbar = "GUI-only, inert in a terminal",
  Tooltip = "GUI-only, inert in a terminal",
  debugPC = "termdebug plugin group, not core UI",
  debugBreakpoint = "termdebug plugin group, not core UI",
  FLoatShadowThrough = "typo in Neovim's own doc tag for FloatShadowThrough",
}

describe("Group", function()
  it("covers every documented built-in highlight group", function()
    local groups = group.load("monrovia_night")
    local missing = {}

    for name in pairs(documented_builtins()) do
      local skip = UNCOVERED[name]
        or name:match("^Nvim") -- vimscript parser groups, only used by :checkhealth vim.lsp
        or name:match("^User%d") -- user-defined statusline groups
        or name == "conceal" -- lowercase duplicate tag for Conceal
      if not skip and groups[name] == nil then
        table.insert(missing, name)
      end
    end

    table.sort(missing)
    assert.are.same(
      {},
      missing,
      ("Neovim documents these groups but monrovia does not define them: %s"):format(table.concat(missing, ", "))
    )
  end)

  for _, style in ipairs(palette.themes) do
    describe(style, function()
      local groups = group.load(style)

      it("emits a non-empty table of tables", function()
        assert.is_true(vim.tbl_count(groups) > 0)
        for name, value in pairs(groups) do
          assert.are.same("table", type(value), name .. " is not a table")
        end
      end)

      it("uses only valid colours for fg, bg and sp", function()
        for name, value in pairs(groups) do
          for _, key in ipairs({ "fg", "bg", "sp" }) do
            assert.is_true(is_color(value[key]), ("%s.%s = %s"):format(name, key, tostring(value[key])))
          end
        end
      end)

      -- nvim_set_hl rejects unknown keys outright ("invalid key: itallic"), but
      -- compilation only parses the generated Lua, it never executes it. A typo
      -- in a style string therefore compiles cleanly and throws at colorscheme
      -- load. Applying every group here moves that failure into the test suite.
      it("applies cleanly through nvim_set_hl", function()
        local highlight = require("monrovia.lib.highlight")
        local ok, err = pcall(highlight.highlight, groups)
        assert.is_true(ok, tostring(err))
      end)

      it("links only to groups that exist", function()
        for name, value in pairs(groups) do
          if value.link and value.link ~= "" then
            local resolved = groups[value.link] ~= nil or is_builtin(value.link)
            assert.is_true(resolved, ("%s links to undefined group %q"):format(name, value.link))
          end
        end
      end)
    end)
  end
end)
