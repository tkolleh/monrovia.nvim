lua << EOF
-- Useful when debugging
if vim.g.nightfox_debug then
  require("monrovia.util.reload")()
end

require("monrovia.config").set_fox("dayfox")
require("monrovia").load()
EOF
