local palette = require("monrovia.palette")
local spec = require("monrovia.spec")

local SHADES = { "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "orange", "pink" }
local PALETTE_COLORS = { "comment", "bg0", "bg1", "bg2", "bg3", "bg4", "fg0", "fg1", "fg2", "fg3", "sel0", "sel1" }

-- Mirrors the ---@class Spec annotation in lua/monrovia/spec.lua. Kept explicit
-- so a palette that silently stops emitting a field fails here rather than
-- surfacing as a nil colour inside a highlight group.
local SPEC_COLORS = { "bg0", "bg1", "bg2", "bg3", "bg4", "fg0", "fg1", "fg2", "fg3", "sel0", "sel1" }
local SPEC_TABLES = {
  syntax = {
    "bracket",
    "builtin0",
    "builtin1",
    "builtin2",
    "builtin3",
    "comment",
    "conditional",
    "const",
    "dep",
    "field",
    "func",
    "ident",
    "keyword",
    "number",
    "operator",
    "preproc",
    "regex",
    "statement",
    "string",
    "type",
    "variable",
  },
  diag = { "error", "warn", "info", "hint", "ok" },
  diag_bg = { "error", "warn", "info", "hint", "ok" },
  diff = { "add", "delete", "change", "text" },
  git = { "add", "removed", "changed" },
}

local function is_hex(value)
  return type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil
end

---Collect every string leaf under `node` as { path, value } pairs.
local function leaves(node, path, acc)
  acc = acc or {}
  for key, value in pairs(node) do
    local child = path .. "." .. tostring(key)
    if type(value) == "string" then
      table.insert(acc, { path = child, value = value })
    elseif type(value) == "table" then
      leaves(value, child, acc)
    end
  end
  return acc
end

describe("Palette", function()
  it("exposes exactly the seven documented styles", function()
    assert.are.same({
      "monrovia_dawn",
      "monrovia_day",
      "monrovia_dusk",
      "monrovia_midnight",
      "monrovia_night",
      "monrovia_sunset",
      "monrovia_twilight",
    }, palette.themes)
  end)

  for _, style in ipairs(palette.themes) do
    describe(style, function()
      local pal = palette.load(style)

      it("reports matching metadata", function()
        assert.are.same(style, pal.meta.name)
        assert.are.same("boolean", type(pal.meta.light))
      end)

      it("defines every Shade with valid base/bright/dim", function()
        for _, name in ipairs(SHADES) do
          local shade = pal[name]
          assert.is_truthy(shade, style .. " is missing shade " .. name)
          for _, variant in ipairs({ "base", "bright", "dim" }) do
            assert.is_true(is_hex(shade[variant]), ("%s.%s.%s = %s"):format(style, name, variant, shade[variant]))
          end
        end
      end)

      it("defines every flat palette colour as valid hex", function()
        for _, name in ipairs(PALETTE_COLORS) do
          assert.is_true(is_hex(pal[name]), ("%s.%s = %s"):format(style, name, tostring(pal[name])))
        end
      end)

      it("generates a spec with every documented field", function()
        local s = spec.load(style)

        for _, name in ipairs(SPEC_COLORS) do
          assert.is_true(is_hex(s[name]), ("%s spec.%s = %s"):format(style, name, tostring(s[name])))
        end

        for group, fields in pairs(SPEC_TABLES) do
          assert.is_truthy(s[group], ("%s spec.%s is missing"):format(style, group))
          for _, name in ipairs(fields) do
            local value = s[group][name]
            assert.is_true(is_hex(value), ("%s spec.%s.%s = %s"):format(style, group, name, tostring(value)))
          end
        end
      end)

      it("generates a spec whose colour leaves are all valid hex", function()
        local s = spec.load(style)
        s.palette = nil -- carries Shade tables and meta, checked separately above

        for _, leaf in ipairs(leaves(s, "spec")) do
          assert.is_true(is_hex(leaf.value), ("%s %s = %s"):format(style, leaf.path, leaf.value))
        end
      end)
    end)
  end
end)
