" ========================================================================
" File:			cpp_InsertAccessors.vim
" Author:		Luc Hermitte <MAIL:hermitte at free.fr>
" 			<URL:http://hermitte.free.fr/vim/>
"
" Last Update:		09th oct 2002
"
" Dependencies:		cpp_options.vim,
" 			cpp_FindContextClass.vim,
" 			a.vim	(alternate files -> :AS())
" 			VIM 6.0 +
" Options:		cf. cpp_options.vim
"
" TODO:		{{{
"  * Clean up the inline file generated when mu-template is installed.
"  * Better place the members in respect of the different options.
"  * Extend the accessors feature to any member, and jump from a definition to
"    an implementation, and vice-versa.
"  * Use Cpp_FileExtensionXXX()
"  * Understand const, mutable, volatile as particular type specifiers ; and
"    then adapt the accessors : for instance, a const data can't have a
"    reference accessor ; a reference attribute must be defined in the
"    constructor (no parameter-less constructor), ...
"  * Do something about the pimpl idiom.
" }}}
" ==========================================================================

if exists("g:loaded_cpp_InsertAccessors_vim") | finish | endif
  let g:loaded_cpp_InsertAccessors_vim = 1
  "
  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim

" ==========================================================================
" VIM Includes {{{
" ==========================================================================
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
" Dependencies {{{
if !exists('*Cpp_SearchClassDefinition')
  runtime ftplugin/cpp/cpp_FindContextClass.vim
  if !exists('*Cpp_SearchClassDefinition')
    if has('gui_running')
      call confirm(
	    \ '<cpp_InsertAccessors.vim> requires <cpp_FindContextClass.vim>',
	    \ '&Ok', '1', 'Error')
    else
      " echohl ErrorMsg
      echoerr '<cpp_InsertAccessors.vim> requires <cpp_FindContextClass.vim>'
      " echohl None
    endif
  endif
endif
" }}}
" }}}
" ==========================================================================
" ==========================================================================
" Insertion of accessors {{{
"
  ""so <sfile>:p:h/cpp_FindContextClass.vim

" Function:	s:ExtractPattern(str, pat) : str	{{{
" Note:		Internal, used by IsBaseType
function! s:ExtractPattern(expr, pattern)
  return substitute(a:expr, '^\s*\('. a:pattern .'\)\s*', '', 'g')
endfunction
" }}}
" Function:	s:IsBaseType(typeName) : bool	{{{
" Note:		Do not test for aberrations like long float
function! s:IsBaseType(type, pointerAsWell)
  let sign  = '\(unsigned\)\|\(signed\)'
  let size  = '\(short\)\|\(long\)\|'
  let types = '\(void\)\|\(char\)\|\(int\)\|\(float\)\|\(double\)'

  let expr = s:ExtractPattern( a:type, sign )
  let expr = s:ExtractPattern( expr,   size )
  let expr = s:ExtractPattern( expr,   types )
  if a:pointerAsWell==1
    if match( substitute(expr,'\s*','','g'), '\(\*\|&\)\+$' ) != -1
      return 1
    endif 
  endif
  return strlen(expr) == 0
endfunction
" }}}
" Function:	s:ConstCorrectType(type) : string	{{{
" Purpose:	Returns the correct expression of the type regarding the
" 		const-correctness issue ; cf Herb Sutter's
" 		_Exceptional_C++_ - Item 43.
function! s:ConstCorrectType(type)
  if s:IsBaseType(a:type,1) == 1
    return a:type
  else
    return 'const ' . a:type . '&'
  endif
endfunction
" }}}

function! s:InsertComment(text) "{{{
  silent put = a:text
  silent normal! ==<<
endfunction
" }}}
function! s:InsertLine(text) "{{{
  silent put = a:text
  silent normal! ==
endfunction
" }}}

" Function: s:WriteAccessor	{{{
function! s:WriteAccessor(returnType, signature, instruction, comment)
  let old_foldenable = &foldenable
  set nofoldenable
  call s:InsertComment( a:comment)
  if strlen(a:instruction) != 0
    if a:returnType =~ "^inline"
      call s:InsertLine('inline')
      call s:InsertLine( substitute(a:returnType,"inline.",'','')
	    \ . "\<tab>" . a:signature ."\<tab>{")
    else
      call s:InsertLine( a:returnType . "\<tab>" . a:signature ."\<tab>{")
    endif
    call s:InsertLine( a:instruction )
    call s:InsertLine( '}' )
  else
    " normal! ==<<
    call s:InsertLine( a:returnType . "\<tab>" . a:signature .";" )
  endif
  let &foldenable = old_foldenable
endfunction
" }}}
" Function: s:InsertAccessor {{{
function! s:InsertAccessor(className, returnType, signature, instruction, comment)
  let old_foldenable = &foldenable
  set nofoldenable
  if g:implPlace == 0 " within the class definition /à la/ Java
    call s:WriteAccessor(a:returnType, a:signature, a:instruction, a:comment)
  else
    let returnType  = a:returnType
    let instruction = a:instruction
    " 1- Insert the prototype
    call s:WriteAccessor(a:returnType, a:signature, '', a:comment)
    let fn = expand("%")
    let l_line = line('.')
    " 2- Find the right place
      if exists('g:mt_jump_to_first_markers') && g:mt_jump_to_first_markers
	let mt_jump = 1
	let g:mt_jump_to_first_markers = 0
      endif
    if     g:implPlace == 1 " Inline section of the right file {{{
      let returnType = "inline\n" . returnType
      call Cpp_ReachInlinePart(a:className)
      " }}}
    elseif g:implPlace == 2 " Within implementation file {{{
      silent AS cpp
      normal! G
      " }}}
    elseif g:implPlace == 3 " use the pimpl idiom {{{
      silent AS cpp
      normal! G
      if exists('*Brkt_Mark') && 
	    \ ( (exists('b:usemarks') && b:usemarks) || !exists('b:usemarks'))
	let instruction = '«;;»'
      else
	let instruction = ';;'
      endif
      " does nothing !!!
      " }}}
    endif
    " 3- Insert the implementation
    let signature = a:className."::".a:signature
    call s:WriteAccessor(returnType, signature, instruction, a:comment)
    " 4- go back after the last prototype inserted
    call FindOrCreateBuffer(fn,1)
    exe ":".(l_line)
    if exists('mt_jump')
      let g:mt_jump_to_first_markers = mt_jump
      unlet mt_jump
    endif
  endif
  let &foldenable = old_foldenable
endfunction
" Nb: the mt_jump stuff is required in order to not mess things up with
" automatically (by the mean of mu-template) built .cpp files.
" }}}

" Function:	AddAttribute			{{{
" Options:	g:getPrefix (default = "get_")
" 		g:setPrefix (default = "set_")
" 		g:refPrefix (default = "ref_")
function! Cpp_AddAttribute()
  call s:CheckOptions()
  " Todo: factorize and move this elsewhere
  " GUI : request name and type  {{{
  echo "--------------------------------------------"
  echo "Adding an attribute to the current class ..."
  echo "--------------------------------------------"
  let type = input("Type of the new attribute : ")
  echo "\n"
  if strlen(type)==0 | call input("Aborting...") | return | endif
  let name = input("Name of the new attribute : ")
  echo "\n"
  if strlen(name)==0 | call input("Aborting...") | return | endif
  " }}}
  "
  " TODO: Place the cursor where the attribute must be defined

  " Insert the attribute itself
  let attrName = g:dataPrefix.name.g:dataSuffix
  call s:InsertComment( '/** ' . name . '... */')
  call s:InsertLine(type . "\<tab>" . attrName . ';')

  " TODO: Place the cursor where accessors must be defined
  let l_line = line('.')
  let c_col  = col('.')
  let className = Cpp_SearchClassDefinition(l_line)

    let ccType      = s:ConstCorrectType(type)
  " Insert the get accessor {{{
    let proxyType   = 0
    let choice = confirm('Do you want a get accessor ?', "&Yes\n&No\n&Proxy", 1) 
  if choice == 1
    let comment     = '/** Get accessor to ' . name . ' */'
    let signature   = g:getPrefix . name .  "()\<tab>const"
    let instruction = 'return ' . attrName . ';'
    call s:InsertAccessor(className, ccType, signature, instruction, comment)
  elseif choice == 3
    let proxyType = input( 'Proxy type                : ') | echo "\n"
    let comment     = '/** Proxy-Get accessor to ' . name . ' */'
    let signature   = g:getPrefix . name .  "()\<tab>const"
    let instruction = 'return ' . proxyType.'('.attrName . ' /*,this*/);'
    call s:InsertAccessor(className, 'const '.proxyType, signature, instruction, comment)
  endif " }}}

  " Insert the set accessor {{{
  if confirm('Do you want a set accessor ?', "&Yes\n&No", 1) == 1
    let comment     = '/** Set accessor to ' . name . ' */'
    let signature   = g:setPrefix.name . '('. ccType .' '. name .')'
    let instruction = attrName . ' = '.name.';'
    call s:InsertAccessor(className, 'void', signature, instruction, comment)
    if proxyType != ""
      let comment     = '/** Set accessor from proxy to ' . name . ' */'
      let signature   = g:setPrefix.name . '('. proxyType .'& '. name .')'
      let instruction = attrName . ' = '.name.';'
      call s:InsertAccessor(className, 'void', signature, instruction, comment)
    endif
  endif " }}}

  " Insert the ref accessor {{{
  if confirm('Do you want a reference accessor ?', "&Yes\n&No", 1) == 1
    if proxyType == ""
      let comment     = '/** Ref. accessor to ' . name . ' */'
      let signature   = g:refPrefix . name .  "()\<tab>"
      let instruction = 'return ' . attrName . ';'
      call s:InsertAccessor(className, type.'&', signature, instruction, comment)
    else
      let comment     = '/** Proxy-Ref accessor to ' . name . ' */'
      let signature   = g:getPrefix . name .  "()\<tab>"
      let instruction = 'return ' . proxyType.'('.attrName . ' /*,this*/);'
      call s:InsertAccessor(className, proxyType, signature, instruction, comment)
    endif
  endif " }}}

  " TODO: Go back to the class initial cursor's position
  " -> l_line, l_col...
  exe ":" . l_line
endfunction
" }}}
" }}}
  let &cpo = s:cpo_save
" ========================================================================
" vim60: set fdm=marker:
