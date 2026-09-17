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

describe("Group", function()
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
