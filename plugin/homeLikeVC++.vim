"=============================================================================
" File:		homeLikeVC++.vim
" Author:	Luc Hermitte <EMAIL:hermitte at free.fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	1.0b
" Created:	23rd mar 2002
" Last Update:	21st jul 2002
"------------------------------------------------------------------------
" Description:	Makes <Home> behaves like it does with Ms-VC++. 
"               -> Hitting <Home> once moves the cursor to the first non blank
"               character of the line, twice: to the first column of the line.
" 
"------------------------------------------------------------------------
" Installation:	Drop it into one of your plugin directories
" History:	1.0: initial version
" TODO:		any missing features ?
"=============================================================================
"
" Avoid reinclusion
if exists("g:loaded_homeLikeVC_vim") | finish | endif
let g:loaded_homeLikeVC_vim = 1
"
"------------------------------------------------------------------------
inoremap <Home> <c-o>:call <SID>HomeLikeVCpp()<cr>
nnoremap <Home> :call <SID>HomeLikeVCpp()<cr>
"
"
function! s:HomeLikeVCpp()
  let ll = strpart(getline('.'), -1, col('.'))
  if ll =~ '^\s\+$' | normal! 0
  else              | normal! ^
  endif
endfunction
