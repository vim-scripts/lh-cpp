" ========================================================================
" File:			cpp_FindContextClass.vim
" Author:		Luc Hermitte <MAIL:hermitte@free.fr>
" 			<URL:http://hermitte.free.fr/vim/>
"
" Last Update:		22nd jan 2002
"
" Dependencies:		parse-class.sed & sed

" Defines:
" * Function Cpp_SearchClassDefinition(lineNo)
"   Returns the class name of any member at line lineNo -- could be of the
"   form : "A::B::C" for embeded classes.
"
" TODO:
" * support templates -> A<T>::B, etc
" * Work on temporary (non saved) version of the C++ file.
" ==========================================================================
"
finish
if !exists("g:loaded_cpp_FindContextClass_vim")
  let g:loaded_cpp_FindContextClass_vim = 1

"
" ==========================================================================
" Checks whether lineNo is in between the '{' at line classStart and its
" '}' counterpart ; in that case, returns "::".className

function! Cpp_IsWithin(classStart, lineNo, className)
  if a:lineNo < a:classStart
    return ""
  endif
    ""echo line('.') . '--' . col('.') . "\n"
  exe ":" . a:classStart 
    ""echo line('.') . '--' . col('.') . "\n"
  exe "normal \<end>\<right>"
    ""echo line('.') . '--' . col('.') . "\n"
  exe "normal ?{?\<cr>"		
    ""echo line('.') . '--' . col('.') . "\n"
      "dont know why, but ?{? is not enough...
  normal %
    ""echo line('.') . '--' . col('.') . "\n"
  if a:lineNo <= line('.')
    return '::' . substitute (a:className, "\n", '', '')
  endif
  return ""
endfunction

" ==========================================================================
" Search for a class definition (not forwarded definition) on several lines
let g:sed_string = "sed --silent -f ". expand("<sfile>:p:h")."/parse-class.sed "
function! Cpp_SearchClassDefinition(lineNo)
  ""if has("unix")
    let result = system( g:sed_string .  substitute(expand("%:p"),'\\','/','g'))
  ""elseif has("win32")
    ""let result = system( 'd:/users/hermitte/bin/usr/local/wbin/' . g:sed_string . expand("%:p"))
    ""let result = system( 'd:\users\hermitte\bin\usr\local\wbin\' . g:sed_string . expand("%:p"))
    ""echo system( 'd:\users\hermitte\bin\usr\local\wbin\' . g:sed_string . expand("%:p"))
    ""let result = 'd:\users\hermitte\bin/usr/local/wbin/' . g:sed_string .  expand("%:p")
  ""endif
  if v:shell_error
    echohl ErrorMsg
    echohl "Can't execute sed with current environment...\n"
    echohl None
    return
  endif

  let t = result
  let pos = 0
  let class = ""
  while pos != -1
    let pos = matchend(t, "\\d\\+\n")
    if pos != -1
      let pat = strpart(t,0,pos-1)
      let t = strpart(t, pos, strlen(t)-pos)
      let pos = matchend(t,"\\i\\+\n")
      let cl = Cpp_IsWithin(pat,a:lineNo,strpart(t,0,pos-1))
      if strlen(cl) != 0
	let class = class . cl
      endif
      let t = strpart(t, pos, strlen(t)-pos)
    endif
  endwhile
  return substitute (class, '^:\+', '', 'g')
endfunction


endif
" ========================================================================
" vim60: set fdm=marker:
