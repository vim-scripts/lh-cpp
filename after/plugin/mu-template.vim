" Author:	Gergely Kontra <kgergely@mcl.hu>
" Last Official Version:	0.11
"
" Last Update:  09th jul 2002
" Version:	0.22, by Luc Hermitte <hermitte@free.fr>
" 
" Description:	Micro vim template file loader
" Installation:	{{{
" 		Drop it into your plugin directory
"               If you have some bracketing macros predefined, install this
"               plugin in <$$/after/plugin>
"               }}}
" Usage:	{{{
" 		When a new file is created, a template file is loaded ; the
" 		name of the template beeing of the form
" 		$$/template/template.&ft , &ft being the filetype of the new
" 		file.
"
" 		We can also volontarily invoke a template construction with 
" 			:MuTemplate id
" 		that will loads $$/template/template.id ; cf. for instance 
" 		template.cpp-class
"
" 		Template file has some magic characters
"		- Strings surrounded by ¡ are expanded by vim
"		  Eg: ¡strftime('%c')¡ will be expanded to the current time
"		  (the time, when the template is read), so
"		  2002.02.20. 14:49:23 on my system NOW.
"		  Eg: ¡expr==1?"text1":text2¡ will be expanded as "text1" or
"		  "text2" regarding 'expr' values 1 or not.
"		- Strings surrounded by ¿ are interpreted by vim
"		  Eg: ¿let s:fn=expand("%")¿ will affect s:fn with the name of
"		  the file currently created.
"		- Strings between «» signs are fill-out places, or marks, if
"		  you are familiar with some bracketing or jumping macros
"		}}}
" History: {{{	0.1	Initial release
"		0.11	- 'runtimepath' is searched for template files,
"			Luc Hermitte <hermitte@free.fr>'s improvements
"			- plugin => non reinclusion
"			- A little installation comment
"			- change 'exe "norm \<c-j>"' to 'norm ¡jump!' + startinsert
"			- add '¿vimExpr¿' to define areas of VimL, ideal to compute
"			  variables
"
"               0.1bis&ter not included in 0.11, 
"               (*) default value for g:author as it is used in some templates
"                   -> $USERNAME (windows specific ?)
"               (*) extend '¡.\{-}¡' and s:Exec() in order to clear empty
"                  lines after the interpretation of '¡.\{-}¡'
"                  cf. template.vim and say 'No' to see the difference.
"               0.20
"               (*) Command (:MuTemplate) in order to insert templates on
"                   request, and at the current cursor position.
"                   Ex: :MuTemplate cpp-class
"               (*) s:Template() changed in consequence
"               0.20bis
"               (*) correct search(...,'W') to search(...,&ws?'w':'W')
"                   ie.: the 'wrapscan' option is used.
"               (*) search policy of the template files improved :
"                  1- search in $VIMTEMPLATES if defined 
"                  2- true search in 'runtimepath' with :SearchInRuntime if
"                     <searchInRUntime.vim> installed.
"                  3- search of the first $$/template/ directory found to
"                     define $VIMTEMPLATES
"               (*) use &fdm to ease the edition of this file
"               0.22
"               (*) Add a global boolean (0/1) option :
"                 g:mt_jump_to_first_markers that specifies whether we want to
"                 jump automatically to the first marker inserted.
"               }}}
" BUGS:		{{{
"		Globals should be prefixed. Eg.: g:author 
" 		First mark must contain text --> ???
" 		}}}
" TODO:	{{{	Re-executing commands. (Can be useful for Last Modified
"		fields)
"		Different templates for a same filetype, e.g. foo.h, foo.cpp,
"		foo.inl, add-class, etc
"		}}}
"========================================================================

if exists("g:mu_template") | finish | endif
let g:mu_template = 1

"========================================================================
" Default definitions
" Define $VIMTEMPLATES if needed {{{
if !exists('$VIMTEMPLATES') && !exists(':SearchInRuntime')
  let rtp=&rtp
  wh strlen(rtp)
    let idx=stridx(rtp,',')
    if idx<0|let idx=65535|en
    let $VIMTEMPLATES=strpart(rtp,0,idx).'/template'
    if isdirectory($VIMTEMPLATES)
      brea
    en
    let rtp=strpart(rtp,idx+1)
  endw
en
" }}}

" g:author : recurrent special variable {{{
if !exists('g:author')
  if exists('$USERNAME')	" win32
    let g:author = $USERNAME
  elseif exists('$USER')	" unix
    let g:author = $USER
  else
    let g:author = ''
  endif
endif
" }}}
" g:mt_jump_to_first_markers {{{
" specifies we want to jump to the first marker in the file.
if !exists('g:mt_jump_to_first_markers')
  let g:mt_jump_to_first_markers = 1
endif
" }}}

" Default implementation  for ¡jump¡ {{{
if !strlen(maparg('¡jump!','n')) " if you don't have bracketing macros
  function! Jumpfunc()
    if !search('«.\{-}»',&ws?'w':'W') "no more marks
      retu "\<CR>"
    el
      if getline('.')[col('.')]=="»"
	retu "\<Del>\<Del>"
      el
	retu "\<Esc>lvf»\<C-g>"
      en
    en
  endf
  imap ¡jump! <c-r>=Jumpfunc()<CR>
  nm ¡jump! i<C-J>
  nmap <C-J> i¡jump!
  imap <C-J> ¡jump!
  vmap <C-J> <Del><C-J>
en
" }}}

"========================================================================
" Functions
" s:Exec() will interpret a sequence between ¡.\{-}¡ {{{
" ... and return the computed value.
" Note: If the sequence is expanded into an empty string and ends the line in
" the template (ie a:nl=='\n'), then s:Exec() returns a carriage return ('\r')
" at the end of the expression.
" To possibly expand a sequence into an empty string, use the 
" 'bool_expr ?  act1 : act2' VimL operator ; cf template.vim for examples of
" use.
fu! <SID>Exec(what,nl)
  exe 'let s:r = ' . a:what
  return (strlen(s:r) ? s:r. (strlen(a:nl)?"\r":'') : "") 
endf
" }}}

" s:Compute() will interpret a sequence between ¿.\{-}¿ {{{
" ... and return nothing
" Back-Door to trojans !!!
fu! s:Compute(what)
  exe a:what
  return ""
endf
" }}}

" s:Template() is the main function {{{
fu! s:Template(...)
  " 1- determine the name of the template file awaited
  if a:0 > 0 | let pos = ''  | let ft = a:1
    " first option : the template file is specified ; cf. template.cpp-class
  else       | let pos = '0' | let ft=strlen(&ft) ? &ft : 'unknown'
    " otherwise (default) : the template file is function of the current
    " filetype
  endif
  " 2- load the associated template
  if filereadable($VIMTEMPLATES.'/template.'.ft)
    silent exe pos.'r  '.$VIMTEMPLATES.'/template.'.ft
  elseif exists(':SearchInRuntime')
    silent exe 'SearchInRuntime '.pos.'r  template/template.'.ft
  endif
  " 3- if succesful, interpret it
  if (line('$') > 1) || (strlen(getline(0)) > 0)
    silent %s/¿\(.\{-}\)¿\n\=/\=<SID>Compute(submatch(1))/ge
    silent %s/¡\([^¡]*\)¡\(\n\=\)/\=<SID>Exec(submatch(1),submatch(2))/ge
    0
    if g:mt_jump_to_first_markers
      normal ¡jump!
    endif
    startinsert
  en
endf
" }}}

"========================================================================
command! -nargs=? MuTemplate :call <sid>Template(<f-args>)

augroup template
  au BufNewFile * cal <SID>Template()
  "au BufWritePre * echon 'TODO'
  "au BufWritePre * normal ,last
augroup END

"========================================================================
" vim60: set fdm=marker:
