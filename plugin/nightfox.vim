" Load only once
if exists('g:loaded_monrovia') | finish | endif

command! MonroviaCompile lua require('monrovia').compile()
command! MonroviaInteractive lua require('monrovia.interactive').attach()

let g:loaded_monrovia = 1
