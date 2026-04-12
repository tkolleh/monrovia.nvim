if has('nvim')
  let s:p = v:lua.require('monrovia.util.lightline').generate('monrovia_twilight')
else
  lua monrovia_vim = require('monrovia.util.lightline').dump('monrovia_twilight')
  let s:palette_str = luaeval('monrovia_vim')
  let s:p = eval(s:palette_str)
endif
let g:lightline#colorscheme#monrovia_twilight#palette = lightline#colorscheme#fill(s:p)