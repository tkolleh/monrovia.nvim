lua << EOF
-- Useful when debugging
if vim.g.nightfox_debug then
  require("monrovia.util.reload")()
end

require("monrovia.config").set_fox("nordfox")
require("monrovia").load()
EOF
