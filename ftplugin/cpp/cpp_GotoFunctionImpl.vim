" \file		cpp_GotoFunctionImpl.vim
" \brief	From VIM-Tip #335: Copy C++ function declaration into
" 		implementation file by Leif Wickland    as of Vim:   5.7 
" \note		See: http://vim.sourceforge.net/tip_view.php?tip_id=335 
" 
" \author	Leif Wickland 
" \author	(Mangled by) Robert KellyIV <Feral at FireTop.Com> 
" \author	Rewrote by Luc Hermitte <hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim/>
" \note		This file and work was based totally on Leif Wickland's
" 		VIM-TIP#335 
"
" \date		08th oct 2002
" \version	$Id$ 
" Version:	0.4 
" History: {{{ 
"    [Luc: 08th oct 2002] 0.4:
"    	(*) Accept comments within the signature and trim them.
"    	(*) If something is written between the ')' and the ';', even on
"    	    new line, it will be understood as part of the prototype
"    	    (typically 'const' and '=0').
"    	    But: We can not put the cursor on this particular line and then
"    	    invoke the command ; the last line accepted is the one of the
"    	    closing parenthesis.
"    [Luc: 08th oct 2002] 0.3:
"    	(*) No more parameters don't require anymore to be on the same line
"    	    But, the return type and the possible const modifier on the
"    	    function must.
"    	(*) No more registers, 
"    	(*) Works with member and non-member functions.
"    	(*) Requires some other files of mine.
"    	    => Can handle nested class.
"    	(*) If an implementation already exists for the function, we go to
"    	    this implementation, otherwise we add it at once.
"    	(*) The command accept optional arguments
"    	(*) Add two default mappings for normal and insert modes, can be
"    	    easily remapped to anything we want.
"    	Todo:
"    	(*) Enable multilines prototypes
"    	    Status: Half implemented in 0.4
"    	(*) Memorize the current cursor position ? -> option
"    	(*) Use tags to achieve a more accurate search
"    	(*) Check whether the function is a pure virtual method and refuse to
"    	    define an implementation ...
"    	(*) Do more testings ...
"    [Feral:274/02@20:42] 0.2 
"	Improvments: from Leif's Tip (#335): 
"	(*) can handle any number of default prams (as long as they are all 
"           on the same line!) 
"           Status: 2/3 fixed with ver 0.4
"	(*) Options on how to format default params, virtual and static. 
"                (see below) TextLink:||@|Prototype:| 
"	(*) placed commands into a function (at least I think it's an
"	    improvement ;) ) 
"	(*) Improved clarity of the code, at least I hope. 
"	(*) Preserves registers/marks. (rather does not use marks), Should not
"	    dirty anything. 
"	(*) All normal operations do not use mappings i.e. :normal! 
"         (I have Y mapped to y$ so Leif's mappings could fail.) 
" 
"	Limitations: 
"	(*) fails on multi line declorations. All prams must be on the same 
"           line. 
"	(*) fails for non member functions. (though not horibly, just have to
"	    remove the IncorectClass:: text... 
"    0.1 
"        Leif's original VIM-Tip #335 
" }}} 
" Requirements: VIM 6.0, cpp_FindContextClass.vim, a.vim
"{{{ [basic]  Tip #335: Copy C++ function declaration into implementation file 
" 
"created:   October 1, 2002 6:47      complexity:   basic 
"author:   Leif Wickland      as of Vim:   5.7 
" 
"There's a handy plug in for MS Visual Studio called CodeWiz that has a nifty
"ability to copy a function declaration and deposit it into the implementation
"file on command.  I actually missed while using vim, so I wrote an
"approximation of that capability.  This isn't foolproof, but it works
"alright.   
" 
"" Copy Function Declaration from a header file into the implementation file. 
"nmap <F5> "lYml[[kw"cye'l 
"nmap <F6> ma:let @n=@/<cr>"lp==:s/\<virtual\>/\/\*&\*\//e<cr>:s/\<static\>/\/\*&\*\//e<cr>:s/\s*=\s*0\s*//e<cr>:s/(.\{-}\zs=\s*[^,)]\{-1,}\>\ze\(\*\/\)\@!.*)/\/\*&\*\//e<cr>:s/(.\{-}\zs=\s*[^,)]\{-1,}\>\ze\(\*\/\)\@!.*)/\/\*&\*\//e<cr>:s/(.\{-}\zs=\s*[^,)]\{-1,}\>\ze\(\*\/\)\@!.*)/\/\*&\*\//e<cr>:let @/=@n<cr>'ajf(b"cPa::<esc>f;s<cr>{<cr>}<cr><esc>kk 
" 
"To use this, source it into vim, for example by placing it in your vimrc,
"press F5 in normal mode with the cursor on the line in the header file that
"declares the function you wish to copy.  Then go to your implementation file
"and hit F6 in normal mode with the cursor where you want the function
"implementation inserted.  }}} 
"=============================================================================
" Buffer Relative stuff {{{
if exists("b:loaded_copycppdectoimp") 
      \ && !exists('g:force_load_copycppdec_toimp')
    finish 
endif 
let b:loaded_copycppdectoimp = 1 
let s:cpo_save=&cpo
set cpo&vim


" Acceptable arguments:
"  'ShowVirtualon', 'ShowVirtualoff', 'ShowVirtual0', 'ShowVirtual1',
"  'ShowStaticon', '..off', '..0' or '..1'
"  'ShowDefaultParamson', '..off', '..0', '..1',  or '..2'
command! -buffer -nargs=* GIMPL call <SID>GrabFromHeaderPasteInSource(<f-args>)

" Mappings {{{
" normal mode mapping ; still possible to set parameters
nnoremap <buffer> <Plug>GotoImpl	:GIMPL<SPACE>
if !hasmapto('<Plug>GotoImpl', 'n')
  nmap <buffer> ;GI <Plug>GotoImpl
  nmap <buffer> <C-W>i <Plug>GotoImpl
endif
" insert mode mapping ; use global parameters
inoremap <buffer> <Plug>GotoImpl	<C-O>:GIMPL<CR>
if !hasmapto('<Plug>GotoImpl', 'i')
  imap <buffer> <C-X>GI <Plug>GotoImpl
endif
" Mappings }}}

" }}}
"=============================================================================
" Global definitions {{{
if exists("g:loaded_cpp_GotoFunctionImpl_vim") 
      \ && !exists('g:force_load_copycppdec_toimp')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_cpp_GotoFunctionImpl_vim = 1
"------------------------------------------------------------------------
" VIM Includes {{{
"------------------------------------------------------------------------
" options {{{
let s:esc_pwd = ''
function! s:CheckOptions()
  " Todo: factorize and move this elsewhere
  if s:esc_pwd != escape(getcwd(), '\')
    let s:pwd = getcwd()
    let s:esc_pwd = escape(s:pwd, '\')
    let g:do_load_cpp_options = 1
    if filereadable("./cpp_options.vim")
      so ./cpp_options.vim
      " elseif filereadable("$VIM/ftplugin/cpp/cpp_options.vim")
      " so $VIM/ftplugin/cpp/cpp_options.vim
    else 
      " so <sfile>:p:h/cpp_options.vim
      runtime ftplugin/cpp/cpp_options.vim
    endif
  endif
endfunction
" }}}
" Function: s:ErrorMsg {{{
function! s:ErrorMsg(text)
  if has('gui_running')
    call confirm(a:text, '&Ok', '1', 'Error')
  else
    " echohl ErrorMsg
    echoerr a:text
    " echohl None
  endif
endfunction " }}}
" Dependencies {{{
if !exists('*Cpp_SearchClassDefinition')
  runtime ftplugin/cpp/cpp_FindContextClass.vim
  if !exists('*Cpp_SearchClassDefinition')
    call s:ErrorMsg(
	  \ '<cpp_GotoFunctionImpl.vim> requires <cpp_FindContextClass.vim>')
    finish
  endif
endif " }}}

" }}}
"------------------------------------------------------------------------
" Function: s:GetFunctionPrototype " {{{
" Todo: 
" * Retrieve the type even when it is not on the same line as the function
"   identifier.
" * Retrieve the const modifier even ahen it is not on the same line as the
"   ')'.
function! s:GetFunctionPrototype(lineNo)
  exe a:lineNo
  " 0- Goto end of current line of prototype (stop at the first found)
  normal! 0
  call search( ')\|\n')
  " 1- Goto start of current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;.*$\ze', 'bW')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'bW')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^;]*;', 'bW')
  let l0 = line('.')
  " 2- Goto the "end" of the current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'W')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;\zs','W')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^;]*;\zs', 'W')
  let l1 = line('.')
  " Abort if nothing found
  if ((0==pos) || (l0>a:lineNo)) | return '' | endif
  " 3- Build the protoype string
  let proto = getline(l0)
  while l0 < l1
    let l0 = l0 + 1
    " Add the line, and trim any comments ending the line
    let proto = proto . "\n" .
	  \ substitute(getline(l0), '\s*//.*$\|\s*/\*.\{-}\*/\s*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$\|/\*.\{-}\*/', '', 'g')
  endwhile
  " 4- and return it.
  exe a:lineNo
  return proto
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:BuildFunctionSignature4impl " {{{
function! s:BuildFunctionSignature4impl(proto,className)
  " 1- XXX if you want virtual commented in the implementation: 
  let impl = substitute(a:proto, '\(\<virtual\>\)\(\s*\)', 
	\ (1 == s:ShowVirtual ? '/*\1*/\2' : ''), '')

  " 2- XXX if you want static commented in the implementation: 
  let impl = substitute(impl, '\(\<static\>\)\(\s*\)', 
	\ (1 == s:ShowStatic ? '/*\1*/\2' : ''), '')

  " 3- Handle default params, if any. 
  "    0 -> ignored
  "    1 -> commented
  "    2 -> commented, spaces trimmed
  if     s:ShowDefaultParams == 0 | let pattern = ''
  elseif s:ShowDefaultParams == 1 | let pattern = '/*\1*/' 
  elseif s:ShowDefaultParams == 2 | let pattern = '/*=\2*/'
  else                            | let pattern = ''
  endif
  let impl = substitute(impl, '\s*\(=\s*\([^,)]\{1,}\)\)', pattern, 'g')
  let impl = substitute(impl, "\n\\(\\s*\\)\\*/", "\\*/\n\\1", 'g')

  " 4- Add '::' to the class name (if any).
  let className = a:className . (""!=a:className ? '::' : '')
  " if "" != className | let className = className . '::' | endif
  let impl = substitute(impl, '\<\i\+\>\('."\n".'\|\s\)*(', className.'\0', '')

  " 5- Remove last part
  let impl = substitute(impl, '\s*;\s*$', "\n{\n}", '')
  " 6- Return
  return impl
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:BuildRegexFromImpl {{{
" Build the regex that will be used to search the signature in the
" implementations file
function! s:BuildRegexFromImpl(impl,className)
  " trim spaces
  let impl2search = substitute(a:impl, "\\(\\s\\|\n\\)\\+", ' ', 'g')
  " class name
  let className = a:className . (""!=a:className ? '::' : '')
  let impl2search = substitute(impl2search, '\<\i\+\>\('."\n".'\|\s\)*(', className.'\0', '')
  " [, ], pointers 
  let impl2search = substitute(impl2search, '\s*\([[\]*]\)\s*', ' \\\1 ', 'g')
  "  <, >, =, (, ), ',' and references
  let impl2search = substitute(impl2search, '\s*\([<>=(),&]\)\s*', ' \1 ', 'g')
  " start and end
  let impl2search = substitute(impl2search, '^ \|\s*;\s*$', '', 'g')
  " default parameters
  let impl2search = substitute(impl2search, '\(=[^,)]\+\)', ' \\(/\\* \1 \\*/\\)\\= ', 'g')
  " virtual and static
  let impl2search = substitute(impl2search, '\(virtual\|static\)', '\\(/\\* \1 \\*/\\)\\=', 'g')
  " spaces -> '\\s*'
  let impl2search = substitute(impl2search, ' ', '\\_s*', 'g')
  " return the regex built
  " return '^\s*'.impl2search
  return '^\s*'.impl2search.'\_s*{'
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:GrabFromHeaderPasteInSource "{{{ 
" The default values for 'HowToShowVirtual', 'HowToShowStatic' and
" 'HowToShowDefaultParams' come from cpp_options.vim ; they can be overidden
" momentarily.
" Parameters: 'ShowVirtualon', 'ShowVirtualoff', 'ShowVirtual0', 'ShowVirtual1',
" 	      'ShowStaticon', '..off', '..0' or '..1'
" 	      'ShowDefaultParamson', '..off', '..0', '..1',  or '..2'
function! s:GrabFromHeaderPasteInSource(...)
  " 0- Check options {{{
  call s:CheckOptions()
  let s:ShowVirtual		= g:cpp_ShowVirtual
  let s:ShowStatic		= g:cpp_ShowStatic
  let s:ShowDefaultParams	= g:cpp_ShowDefaultParams
  if 0 != a:0
    let i = 0
    while i < a:0
      let i = i + 1
      let varname = substitute(a:{i}, '\(.*\)\(on\|off\|\d\+\)$', '\1', '') 
      if varname !~ 'ShowVirtual\|ShowStatic\|ShowDefaultParams' " Error {{{
	call s:ErrorMsg(
	      \ '<cpp_GotoFunctionImpl.vim::GrabFromHeaderPasteInSource> unknown parameter : <'.varname.'>')
	return
      endif " }}}
      let val = matchstr(a:{i}, '\(on\|off\|\d\+\)$')
      if     val == 'on'  | let val = 1
      elseif val == 'off' | let val = 0
      elseif val !~ '\d\+'
	call s:ErrorMsg(
	      \ '<cpp_GotoFunctionImpl.vim::GrabFromHeaderPasteInSource> invalid value for parameter : <'.varname.'>')
	return
      endif
      exe "let s:".varname."= val"
      " call confirm(s:{varname}.'='.val, '&ok', 1)
    endwhile
  endif
  " }}}

  " 1- Retrieve the context {{{
  " 1.1- Get the class name,if any -- thanks to cpp_FindContextClass.vim
  let className = Cpp_SearchClassDefinition(line('.'))
  " 1.2- Get the whole prototype of the function (even if on several lines)
  let proto = s:GetFunctionPrototype(line('.'))
  if "" == proto
    call s:ErrorMsg('<cpp_GotoFunctionImpl.vim> We are not within a function prototype!')
    return
  endif
  " }}}

  " 2- Build the result string {{{
  let impl        = s:BuildFunctionSignature4impl(proto,className)
  let impl2search = s:BuildRegexFromImpl(proto,className)
  " }}}

  " 3- Add the string to the implementation file {{{
  " neutralize mu-template {{{
  if exists('g:mt_jump_to_first_markers') && g:mt_jump_to_first_markers
    let mt_jump = 1
    let g:mt_jump_to_first_markers = 0
  endif " }}}
  if exists(':AS') " from a.vim
    silent AS cpp
  else
    let file = fnamemodify(expand('%'), ':r') . '.cpp'
    silent exe ":sp ".file
  endif
  " Search or insert the C++ implementation
  if !search(impl2search)
    " insert the C++ code at the end of the file
    silent $put=impl
    " reindent the newly inserted lines
    let nl = strlen(substitute(impl, "[^\n]", '', 'g'))
    exe (line('$')-nl).',$v/^$/normal! =='
  endif

  " call confirm(impl, '&ok', 1)
  " restore mu-template " {{{
  if exists('mt_jump')
    let g:mt_jump_to_first_markers = mt_jump
    unlet mt_jump
  endif " }}} 
  " }}}
endfunction 
" }}}
"------------------------------------------------------------------------
let &cpo=s:cpo_save
" }}}
"=============================================================================
" Documentation {{{
"***************************************************************** 
" given: 
"    virtual void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 

" Prototype: 
"GrabFromHeaderPasteInSource(VirtualFlag, StaticFlag, DefaultParamsFlag) 

" VirtualFlag: 
" 1:    if you want virtual commented in the implimentation: 
"    /*virtual*/ void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 
" else:    remove virtual and any spaces/tabs after it. 
"    void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 

" StaticFlag: 
" 1:    if you want static commented in the implementation: 
"    Same as virtual, save deal with static 
" else:    remove static and any spaces/tabs after it. 
"    Same as virtual, save deal with static 

" DefaultParamsFlag: 
" 1:    If you want to remove default param reminders, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2, char * _cpStr); 
" 2:    If you want to comment default param assignments, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2/*= 5*/, char * _cpStr/*= "Yea buddy!"*/); 
" 3:    Like 2 but, If you do not want the = in the comment, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
" 
" Examples: 
" smallest implementation: 
"    void Test_Member_Function_B3(int _iSomeNum2, char * _cpStr); 
":command! -nargs=0 GHPH call <SID>GrabFromHeaderPasteInSource(0,0,1) 
"    Verbose...: 
"    /*virtual*/ void Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
":command! -nargs=0 GHPH call <SID>GrabFromHeaderPasteInSource(1,1,3) 
"    What I like: 
"    void Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
" }}}
"=============================================================================
" vim60:fdm=marker 
