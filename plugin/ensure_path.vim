" File:		ensure_path.vim
" Author:	Luc Hermitte <hermitte@free.fr>
" Last Update:	03rd apr 2002
"------------------------------------------------------------------------
"
"if !exists("g:ensure_path_vim")
  let g:ensure_path_vim = 1

  command! -nargs=1 EnsurePath :call EnsurePath(<args>)
  
  " Main function {{{
  function! EnsurePath(path)
"    call input("isdirectory(".a:path.") = ".isdirectory(a:path))
    if !isdirectory(a:path)
      let up = substitute(a:path, '/\=[^/]*/\=$', '/', '')
"      call input("up = ".up)
      if strlen(up) > 1
"	call input("boucle ".up)
	call EnsurePath(up)
      endif
"      call input("construit ".a:path)
      call EnsurePathLastDepth(a:path)
    endif
  endfunction
  " }}}

  " Internal Function {{{
  function! EnsurePathLastDepth(path)
    if !isdirectory(a:path)
      if filereadable(a:path)
	echohl ErrorMsg
	echo   "A file is found were a folder is expected : " . a:path
	echohl None
	return 0 	" exit
      endif
      let v:errmsg=""
      if &verbose >= 1 | echo "Create <".a:path.">\n" | endif
      if has("unix") 
	call system('mkdir '.a:path)
      elseif has("win32")
	if &shell =~ "sh"
	  let path = substitute(a:path,'\\','/','g')
	  ""echo "system( 'mkdir ".path."')"
	  call system('mkdir '.path)
	  ""exe "!mkdir ".path
	else
	  let path = substitute(a:path,'/','\\','g')
	  ""echo "system( 'md ".path."')"
	  call system('md '.path)
	endif
      endif
      if strlen(v:errmsg) != 0
	echohl ErrorMsg
	echo   v:errmsg
	echohl None
      endif
      return 1
    else
      return 0
    endif
  endfunction
  " }}}


"endif
"------------------------------------------------------------------------
" vim600: set foldmethod=marker:
