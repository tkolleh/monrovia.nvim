local M = {}

---Convert a Shade or Color to a css string
---@param value Shade | Color
---@return string css hex string
local function to_value(value)
  return value.base and value.base or value:to_css()
end

---Walk path (one.two.three) in a table and return value
---@param t table
---@param path string
---@return any
local function get_path(t, path)
  for segment in path:gmatch("[^.]+") do
    if type(t) == "table" then
      t = t[segment]
    end
  end
  return t
end

---Resolve one override value against the spec. Strings are treated as dotted
---template paths ("syntax.func"); anything else is passed through untouched.
---@param value any
---@param spec Spec
---@return any
local function parse_string(value, spec)
  -- Overrides carry numbers (blend) and booleans alongside colour strings.
  -- Indexing those throws, so non-strings must short-circuit here.
  if type(value) ~= "string" then
    return value
  end

  -- `value[1]` resolves through the string metatable and is always nil, so this
  -- shortcut never fired; literal hex survived only because get_path failed to
  -- resolve it and the final fallback returned the input unchanged.
  if value == "" or value:sub(1, 1) == "#" then
    return value
  end

  local path = get_path(spec, value)
  return path and path.base or path or value
end

function M.parse(template, spec)
  local result = {}

  for group, opts in pairs(template) do
    if type(opts) == "table" then
      local new = {}
      for key, value in pairs(opts) do
        new[key] = type(value) == "table" and to_value(value) or parse_string(value, spec)
      end
      result[group] = new
    else
      result[group] = parse_string(opts, spec)
    end
  end

  return result
end

function M.parse_template_str(template, spec)
  return (
    template:gsub("($%b{})", function(w)
      local path = w:sub(3, -2)
      local value = get_path(spec, path) or w
      if type(value) == "table" then
        return value.base and value.base or value
      else
        return value or w
      end
    end)
  )
end

return M
