if has('nvim')
  let s:p = v:lua.require('monrovia.util.lightline').generate('monrovia_sunset')
else
  lua monrovia_vim = require('monrovia.util.lightline').dump('monrovia_sunset')
  let s:palette_str = luaeval('monrovia_vim')
  let s:p = eval(s:palette_str)
endif
let g:lightline#colorscheme#monrovia_sunset#palette = lightline#colorscheme#fill(s:p)