" skyfm
" Version: 0.0.1
" Author: 
" License: 

if exists('g:loaded_skyfm')
  finish
endif
let g:loaded_skyfm = 1

let s:save_cpo = &cpo
set cpo&vim

command! SkyfmUpdateChannels call skyfm#update_channels()
command! -nargs=1 -complete=customlist,skyfm#channel_key_complete SkyfmPlay call skyfm#play(<f-args>)
command! SkyfmStop call skyfm#stop()

augroup skyfm
  autocmd!
  autocmd skyfm VimLeave * call skyfm#stop()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
