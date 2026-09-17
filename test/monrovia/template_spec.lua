local template = require("monrovia.util.template")
local spec = require("monrovia.spec")

describe("Template", function()
  local s = spec.load("monrovia_night")

  it("passes literal hex through unchanged", function()
    local result = template.parse({ Foo = { fg = "#112233" } }, s)
    assert.are.same("#112233", result.Foo.fg)
  end)

  it("passes non-string values through unchanged", function()
    -- blend is an integer; indexing it used to throw inside parse_string.
    local result = template.parse({ Foo = { bg = "#000000", blend = 80 } }, s)
    assert.are.same(80, result.Foo.blend)
  end)

  it("resolves dotted spec paths", function()
    local result = template.parse({ Foo = { fg = "syntax.func" } }, s)
    assert.are.same(s.syntax.func, result.Foo.fg)
  end)

  it("resolves a Shade path to its base", function()
    local result = template.parse({ Foo = { fg = "palette.blue" } }, s)
    assert.are.same(s.palette.blue.base, result.Foo.fg)
  end)

  it("leaves unresolvable strings alone", function()
    local result = template.parse({ Foo = { link = "Comment" } }, s)
    assert.are.same("Comment", result.Foo.link)
  end)
end)
