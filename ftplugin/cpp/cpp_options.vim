if !exists("g:do_load_cpp_options") | finish | endif
unlet g:do_load_cpp_options
"
exe 'command! -nargs=0 CppEditOptions :sp '.expand('<sfile>:p')
exe 'command! -nargs=0 CppReloadOptions :so '.expand('<sfile>:p')
" ====================================================================
" Preferences for the names of classes' attributes and their accessors {{{
" ====================================================================
"
" Luc's preferences
let g:setPrefix  = 'set_'
let g:getPrefix  = 'get_'
let g:refPrefix  = 'ref_'
let g:dataPrefix = 'm_'
let g:dataSuffix = ''
"
""" Very short style
""let g:setPrefix  = ''
""let g:getPrefix  = ''
""let g:refPrefix  = ''
""let g:dataPrefix = ''
""let g:dataSuffix = '_'
"
""" Herb Sutter's style
""let g:setPrefix  = 'Set'
""let g:getPrefix  = 'Get'
""let g:refPrefix  = 'Get'
""let g:dataPrefix = ''
""let g:dataSuffix = '_'
" }}}
" ====================================================================
" Preference regarding where methods definitions occur {{{
" ====================================================================
"
" Possible values:
"   0: Near the prototype/definition (Java's way)
"   1: Within the inline section of the header/inline/current file
"   2: Within the implementation file (.cpp)
"   3: Use the pimpl idiom
" Values ranging from 1 to 3 require you use cpp_FindContextClass.vim and
" have access to sed. Or else implement cpp_FindContextClass.vim in an
" other way and let us know.
let g:implPlace = 1
" }}}
" ====================================================================
" Preference regarding where inlines are written {{{
" ====================================================================
" Possible values:
"   0: In the inline section of the header/current file
"   1: In the inline section of a dedicated inline file
let g:inlinesPlace = 1

" Function used by Cpp_reachInlinePart()
function! Cpp_fileTypeRegardingOption()
  return g:inlinesPlace
endfunction
" }}}
" ====================================================================
" Preferences regarding what is shown in functions signatures {{{
" IE.: Should every element from the signature of a function be reminded along
" with the implementationof the function ?
"
" ShowVirtual = 0 -> '' ; 1 -> '/*virtual*/'
let g:cpp_ShowVirtual		= 1
" ShowStatic  = 0 -> '' ; 1 -> '/*static*/'
let g:cpp_ShowStatic 		= 1
" ShowDefaultParam = 0 -> '', 1 -> default value for params within comments
"                             2 -> within comment as well, but spaces are
"                             trimmed.
let g:cpp_ShowDefaultParams	= 1
" }}}
" ====================================================================
" File extensions {{{
" ====================================================================
function! Cpp_FileExtension4Inlines()
  return '.inl'
endfunction

function! Cpp_FileExtension4Implementation()
  return '.cpp'
endfunction
" }}}
" ====================================================================
" vim600: set fdm=marker:
