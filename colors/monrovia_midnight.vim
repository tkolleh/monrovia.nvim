lua << EOF
-- Useful when debugging
if vim.g.monrovia_debug then
  require("monrovia.util.reload")()
end

require("monrovia.config").set_fox("monrovia_midnight")
require("monrovia").load()
EOF
