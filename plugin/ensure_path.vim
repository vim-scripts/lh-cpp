"------------------------------------------------------------------------
" File:		ensure_path.vim
" Author:	Luc Hermitte <EMAIL:hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim/>
" Last Update:	30th aug 2002
"
" Purpose:	{{{
" 	Proposes a command and a function that make sure a directory exists.
" 	If the directory didn't exist before the call, it is created.
" 	If the parent directories of the required directory do not exist, they
" 	are created in the way.
" }}}
" Installation:	{{{
" 	Drop the file into a $$/plugin/ (or $$/macros/) directory of your VIM
" 	installation regarding you want it to be sourced systematically (or
" 	occasionally) on your request.
" }}}
" Tested on:	{{{
" 	WinMe + command.com
" 	WinMe + cygwin (the VIM version, I used, beeing the one released on
" 		the VIM web site and ftps for PC/MsWindows systems).
" 		Check _vimrc_win (on my web site) to have a precise idea of my
" 		specific settings (for these shells) if you have any troubles.
" 		BTW, if you run VIM from the MsWindows files explorer and want
" 		to use cygwin commands (like mkdir here), be sure to have your
" 		$path correctly set.
" Retest on:
" 	Win95 + command.com & cygwin
" 	WinNT + cmd32 & zsh & cygwin
" 	Sun/Solaris + tcsh
" }}}
"------------------------------------------------------------------------
" avoid multiple inclusions
if exists('g:do_load_ensure_path') || !exists("g:ensure_path_vim")
  let g:ensure_path_vim = 1

  " The command ...
  command! -nargs=1 -complete=expression EnsurePath :call EnsurePath(<args>)
  
  " Main function        <public>  {{{
  " Returns 0 : 0  -> the directory hasn't been created successfully
  "         1 : ok -> the directory has been created successfully
  " Note: for MsWindows system, this function transforms the path before
  " anything else. 
  function! EnsurePath(path)
    let path = a:path
    if has("dos16") || has("dos32") || has('win32')
      " a- change every backslash to forwardslash (when not followed by a
      "    space) ... because of 'isdirectory()'
      let path = substitute(path, '\\\([^ ]\)', '/\1', 'g')
      " b- unescape the spaces ... still because of 'isdirectory()'
      let path = substitute(path, '\\ ', ' ', 'g')
      " call confirm('<'.path.(isdirectory(path)?'> exists': "> doesn't exist"), 'ok')
      " return
    endif
    return EnsurePath_core(path)
  endfunction
  " }}}
  
  " Main loop function   <private> {{{
  " Return 0 : 0
  "        1 : ok
  " Note: This function recursively builds the provided directory.
  function! EnsurePath_core(path)
    " call input("isdirectory(".a:path.") = ".isdirectory(a:path))
    if !isdirectory(a:path)
      " A.1- Get parent directory.
      let up = substitute(a:path, '/\=[^/]*/\=$', '/', '')
      " call input("up = ".up)
      " A.2.a- If the parent is not root.
      if "" != up
	" call input("loop ".up)
	" A.2.a.i-  Recursivelly construct the parent directory.
	let r = EnsurePath_core(up)
	" A.2.a.ii- Return if an error has occurred.
	if r != 1 | 
	  " call input('r= '.r)
	  return r | endif
      endif
      " A.2.b- the parent is root, implicitely, don't recurse.
      " A.3- Construct the directory at the current level.
      " call input("Build ".a:path)
      let r = EnsurePathLastDepth(a:path)
      " call input('rlast= '.r)
      " A.4- Return the result of the construction.
      return r
    else
      " B- The current path exist : terminal condition.
      " call input(a:path." exist")
      return 1
    endif
    " call input("Problem")
  endfunction
  " }}}

  " Creation function    <private> {{{
  " Return 0 : 0
  "        1 : ok
  " Note: This function calls mkdir on the last part of the directory and
  " checks that the creation went OK. 
  function! EnsurePathLastDepth(path)
    " call input("LastDepth isdirectory(".a:path.") = ".isdirectory(a:path))
    if !isdirectory(a:path)
      if filereadable(a:path) " {{{
	echohl ErrorMsg
	echo   "A file is found were a folder is expected : " . a:path
	echohl None
	return 0 	" exit
      endif " }}}
      let v:errmsg=""
      if &verbose >= 1 | echo "Create <".a:path.">\n" | endif
      if     has("unix") " {{{
	"TODO: I'll certainly have to escape the path, if so, please send me
	"an email.
	call system('mkdir '.a:path)
	" call system('mkdir '.escape(a:path, ' '))
	let path = a:path
	" }}}
      elseif has("win32") " {{{
	if &shell =~ "sh"
	  let path = a:path
	  " let path = substitute(a:path,'\\','/', 'g')
	  ""echo "system( 'mkdir ".path."')"
	  call system('mkdir '.escape(path, ' '))
	else
	  let path = substitute(a:path,'/','\\', 'g')
	  let path = substitute(  path,'\\$','','')
	  ""echo "system( 'md ".path."')"
	  if (path =~ ' ') && (has("dos16") || has("dos32") || has('win95'))
	    " system('md name with spaces do not work')
	    exe '!md "'.path.'"'
	    " Other solution if we don't want to wait for user to hit <enter>:
	    " parse the path and replace non-terminal occurences of
	    " directories having spaces in their name with the short name
	    " equivalent ; ie. "C:\Program Files\foo" --> "C:\Progra~1\foo"
	  else
	    call system('md '.path)
	  endif
	endif
	" }}}
      else " Other systems {{{
	echohl ErrorMsg
	echo   "I don't know how to create directories on your system."
	echo   "Any solution is welcomed! ".
	      \ "Please, contact me at <hermitte"."@"."free.fr>"
	echohl None
      endif " }}}
      "
      " ¿ any error ? {{{
      if strlen(v:errmsg) != 0
	echohl ErrorMsg
	echo   v:errmsg
	echohl None
	return 0
      elseif !isdirectory(a:path)
	echohl ErrorMsg
	echo   "<".path."> can't be created!"
	echohl None
	return 0
      endif
      " }}}
      return 1
    else
      return 0
    endif
  endfunction
  " }}}

endif
"------------------------------------------------------------------------
" Implementation Notes: {{{
" (*) isdirectory() seems to require paths defined with forward slashes (even
" on Win Me, command.com and 'shellslash'=0 ; and the spaces must not be
" escaped... It is too simple otherwise.
" (*) On the same WinMe : 
"     - "system('md c:\verylongname')" and "system('md c:\verylongname\foo')"
"       work.
"     - "system('md c:\spaced name')" does not work !!! 
"       while !md "c:\spaced name" does... That's very odd
"     - "system('md "c:\spaced name"')" does not work either ... 
" (*) `mkdir' (from cygwin) is very permissive regarding the use of quotes and
" double-quotes. The only constraint is to have the spaces escaped.
" }}}
"------------------------------------------------------------------------
" vim600: set foldmethod=marker:
