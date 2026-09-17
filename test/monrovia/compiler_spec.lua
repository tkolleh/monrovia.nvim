local compiler = require("monrovia.lib.compiler")
local config = require("monrovia.config")
local override = require("monrovia.override")
local palette = require("monrovia.palette")

---Isolate each example from the user's real cache directory.
local function with_temp_cache()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  config.set_options({ compile_path = dir })
  return dir
end

describe("Compiler", function()
  after_each(function()
    config.reset()
    override.reset()
  end)

  it("tolerates a bare get_compiled_info() call", function()
    -- health.lua calls this without arguments; indexing a nil opts used to throw.
    assert.has_no.errors(function()
      config.get_compiled_info()
    end)
  end)

  describe("compiling every style", function()
    it("writes a non-empty, loadable blob and leaves no temp file", function()
      with_temp_cache()

      for _, style in ipairs(palette.themes) do
        compiler.compile({ style = style })
        local _, file = config.get_compiled_info({ name = style })

        local stat = vim.uv.fs_stat(file)
        assert.is_truthy(stat, style .. ": no blob written")
        assert.is_true(stat.size > 0, style .. ": blob is empty")
        assert.is_truthy(loadfile(file), style .. ": blob does not load")
        assert.is_nil(vim.uv.fs_stat(file .. ".tmp"), style .. ": left a .tmp behind")
      end
    end)

    it("produces a blob that applies the colorscheme", function()
      with_temp_cache()

      for _, style in ipairs(palette.themes) do
        compiler.compile({ style = style })
        local _, file = config.get_compiled_info({ name = style })

        local chunk = loadfile(file)
        assert.has_no.errors(chunk)

        assert.are.same(style, vim.g.colors_name)
        assert.are.same(palette.load(style).meta.light and "light" or "dark", vim.o.background)

        local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
        assert.is_truthy(normal.fg, style .. ": Normal has no fg")
        assert.is_truthy(normal.bg, style .. ": Normal has no bg")
      end
    end)
  end)

  it("leaves an existing blob untouched when compilation fails", function()
    with_temp_cache()

    compiler.compile({ style = "monrovia_night" })
    local _, file = config.get_compiled_info({ name = "monrovia_night" })
    local before = vim.uv.fs_stat(file)

    -- An unbalanced quote in an override produces invalid generated Lua. The
    -- compiler used to truncate the output before discovering that, leaving a
    -- zero-byte blob that loadfile() happily accepts and that sets no colours.
    override.groups = { all = { Normal = { fg = '#000000" ]] .. nil .. [[' } } }
    pcall(compiler.compile, { style = "monrovia_night" })

    local after = vim.uv.fs_stat(file)
    assert.is_truthy(after, "cache was removed by a failed compile")
    assert.are.same(before.size, after.size, "cache was rewritten by a failed compile")
  end)

  it("treats a zero-byte blob as unloadable", function()
    local dir = with_temp_cache()
    local empty = vim.fs.joinpath(dir, "empty_compiled")
    assert(io.open(empty, "wb")):close()

    -- loadfile() succeeds on an empty file and returns a no-op chunk, so size is
    -- the only reliable signal that a compile failed.
    assert.is_truthy(loadfile(empty), "precondition: loadfile accepts empty files")
    assert.are.same(0, vim.uv.fs_stat(empty).size)
  end)
end)
