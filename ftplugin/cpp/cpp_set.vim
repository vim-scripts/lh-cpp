" ========================================================================
" File:			cpp_set.vim
" Author:		Luc Hermitte <MAIL:hermitte at free.fr>
" 			<URL:http://hermitte.free.fr/vim/>
"
" Last Update:		21st jul 2002
"
" Purpose:		ftplugin for C++ programming
"
" Dependencies:		c.set, misc_map.vim, 
" 			cpp_InsertAccessors.vim,
" 			cpp_BuildTemplates.vim
" 			VIM >= 6.00 only
"
" TODO:		
"  * Menus & Help pour se souvenir des commandes possibles
"  * Support pour l'héritage vis-à-vis des constructeurs
"  * Reconnaître si la classe courante est template vis-à-vis des
"    implementations & inlinings
" ========================================================================


" ========================================================================
" Buffer local definitions
" ========================================================================
if exists("b:loaded_local_cpp_settings") | finish | endif
let b:loaded_local_cpp_settings = 1

  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim

" ------------------------------------------------------------------------
" Commands
" ------------------------------------------------------------------------
" Cf. cpp_BuildTemplates.vim
"
" ------------------------------------------------------------------------
" VIM Includes
" ------------------------------------------------------------------------
runtime! ftplugin/c/*.vim 
" --> need to be sure that some definitions are loaded first!
"     like maplocaleader.

""so $VIMRUNTIME/macros/misc_map.vim
""so <sfile>:p:h/cpp_InsertAccessors.vim
""so <sfile>:p:h/cpp_BuildTemplates.vim

"   
" ------------------------------------------------------------------------
" Options to set
" ------------------------------------------------------------------------
"  setlocal formatoptions=croql
"  setlocal cindent
"
"  Accepted comments are :
" /*     /**       /**@
"  *       *        *  
"  */      */       */
setlocal comments=f://,sl1b:/**,mb:*,el:*/,sr:/*,mb:*,el:*/
setlocal cinoptions=g0,t0,h1s

" ------------------------------------------------------------------------
" Some C++ abbreviated Keywords
" ------------------------------------------------------------------------
Inoreab <buffer> pub public:<CR>
Inoreab <buffer> pro protected:<CR>
Inoreab <buffer> pri private:<CR>

Iabbr <buffer> tpl template <><Left>

inoreab <buffer> vir virtual

inoremap <buffer> <m-s> std::

"--- try ----------------------------------------------------------------
"--try insert "try" statement
  Iabbr <buffer> try <C-R>=Def_Abbr("try ",
	\ '\<c-f\>try {\<cr\>} catch () {\<cr\>}\<up\>\<esc\>O',
	\ '\<c-f\>try {\<cr\>} catch (¡mark!) {¡mark!\<cr\>}¡mark!\<esc\>'
	\ .'?try\<cr\>o')<CR>
"--,try insert "try - catch" statement
  vnoremap <buffer> <LocalLeader>try 
	\ :call MapAroundVisualLines('try {',"} catch () {\n}", 1, 1)<cr>
	" \ ><esc>`>a<cr>} catch () {<c-t><cr>}<esc>`<itry {<c-f><cr><esc>/(<cr>a
      nmap <buffer> <LocalLeader>try V<LocalLeader>try

"--- catch --------------------------------------------------------------
"--catch insert "catch" statement
  Iabbr <buffer> catch <C-R>=Def_Abbr("catch ",
	\ '\<c-f\>catch () {\<cr\>}\<esc\>?(?\<cr\>a',
	\ '\<c-f\>catch () {¡mark!\<cr\>}¡mark!\<esc\>?(\<cr\>a')<CR>


" ------------------------------------------------------------------------
" Comments ; Javadoc/DOC++/Doxygen style
" ------------------------------------------------------------------------
"
" /**       inserts /** <cursor>
"                    */
" but only outside the scope of C++ comments and strings
  inoremap <buffer> /**  <c-r>=Def_Map('/**',
	\ '/** \<cr\>\<BS\>/\<up\>\<end\>',
	\ '/** \<cr\>\<BS\>/¡mark!\<up\>\<end\>')<cr>
" /*<space> inserts /**<cursor>*/
  inoremap <buffer> /*<space>  <c-r>=Def_Map('/* ',
	\ '/** */\<left\>\<left\>',
	\ '/** */¡mark!\<esc\>F*i')<cr>

" ------------------------------------------------------------------------
" std oriented stuff
" ------------------------------------------------------------------------
" in std::foreach and std::find algorithms, expand
"   'algo(container§)' into 'algo(container.begin(),container.end()§)', 
" '§' representing the current position of the cursor.
inoremap <c-x>be .<esc>%v%<left>o<right>y%%ibegin(),<esc>paend()<esc>a

" ========================================================================
" General definitions -> none here
" ========================================================================
"if exists("g:loaded_cpp_set_vim") | finish | endif
"let g:loaded_cpp_set_vim = 1

  let &cpo = s:cpo_save
