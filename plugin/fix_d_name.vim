"=============================================================================
" File:		fix_d_name.vim
" Author:	Luc Hermitte <EMAIL:hermitte at free.fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	1.0
" Created:	28th aug 2002
" Last Update:	28th aug 2002
"------------------------------------------------------------------------
" Description:	Fix directory and files names according to the 'shellslash'
" option
" 
"------------------------------------------------------------------------
" Installation:	Drop the file in a $$/plugin directory.
" History:	First version come from Triggers.vim
" TODO:		«missing features»
"=============================================================================
"
" Avoid reinclusion {{{
if !exists("g:loaded_fix_d_name_vim") || exists('g:do_load_fix_d_name')
  let g:loaded_fix_d_name_vim = 1
  let s:cpo_save=&cpo
  set cpo&vim
" }}}
"=============================================================================
function! FixDname(dname) " {{{
  let dname = matchstr(a:dname, '^.*[^/\\]')
  if !has("win32") || &shellslash
    " return substitute(dname, '\\\([^ ]\|$\)', '/\1', 'g')
    return substitute(
	  \ substitute(dname, '\\\([^ ]\|$\)', '/\1', 'g'),
	  \ '\(^\|[^\\]\) ', '\1\\ ', 'g')
  else
    " return substitute(
	  " \ substitute(dname, '\([^\\]\) ', '\1\\ ', 'g'), 
	  " \ '/', '\\', 'g')
    return substitute(
	  \ substitute(dname, '\\ ', ' ', 'g'), 
	  \ '/', '\\', 'g')
  endif
  " Note: problem to take care (that explains the complex substition schemes): 
  " sometimes the path passed to the function mix the two writtings, e.g.:
  " "c:\Program Files/longpath/some\ spaces/foo"
endfunction
" }}}
"------------------------------------------------------------------------
  let &cpo=s:cpo_save
endif
"=============================================================================
" vim600: set fdm=marker:
