" ========================================================================
" File:			c_set.vim
" Author:		Luc Hermitte <MAIL:hermitte@free.fr>
" 			<URL:http://hermitte.free.fr/vim/>
"
" Last Update:		11th jul 2002
"
" Purpose:		ftplugin for C (-like) programming
"
" Dependancies:		misc_map.vim
" 			common_brackets.vim
" 			a.vim			-- alternate files
" 			LoadHeaderFile.vim	
" 			flist & flistmaps.vim	-- Dr Chips
" 			VIM >= 6.00 only
" ========================================================================




" ========================================================================
" Buffer local definitions {{{
" ========================================================================
if exists("b:loaded_local_c_settings") | finish | endif
let b:loaded_local_c_settings = 1

  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim

" ------------------------------------------------------------------------
" Options to set {{{
" ------------------------------------------------------------------------
setlocal formatoptions=croql
setlocal cindent
setlocal comments=sr:/*,mb:*,el:*/
setlocal cinoptions=g0,t0

setlocal ch=2
setlocal nosmd

" Dictionary from Dr.-Ing. Fritz Mehner 
let s:dictionary=expand("<sfile>:p:h").'/word.list'
if filereadable(s:dictionary)
  let &dictionary=s:dictionary
  setlocal complete+=k
endif

if !exists('maplocalleader')
  let maplocalleader = ','
endif

" }}}
" ------------------------------------------------------------------------
" Brackets & all {{{
" ------------------------------------------------------------------------
if !exists('*Brackets')
  runtime plugin/common_brackets.vim
endif
if exists('*Brackets')
  let b:cb_parent  = 1
  let b:cb_bracket = 1
  let b:cb_acco    = 1
  let b:cb_quotes  = 2
  let b:cb_Dquotes = 1
  " Re-run brackets() in order to update the mappings regarding the different
  " options.
  call Brackets()
endif

" }}}
" ------------------------------------------------------------------------
" File loading {{{
" ------------------------------------------------------------------------
"
" Things on :A and :AS
""so $VIM/macros/a.vim
"
""so <sfile>:p:h/LoadHeaderFile.vim
if exists("*LoadHeaderFile")
  nnoremap <buffer> <buffer> <C-F12> 
	\ :call LoadHeaderFile(getline('.'),0)<cr>
  inoremap <buffer> <buffer> <C-F12> 
	\ <esc>:call LoadHeaderFile(getline('.'),0)<cr>
endif

" flist (Dr Chips)
""so <sfile>:p:h/flistmaps.vim
if filereadable(expand("hints"))
  au BufNewFile,BufReadPost *.h,*.ti,*.inl,*.c,*.C,*.cpp,*.CPP,*.cxx
	\ so hints<CR>
endif

" }}}
" ------------------------------------------------------------------------
" C keywords {{{
" ------------------------------------------------------------------------
" Pre-processor
"
"-- insert "#define" at start of line
  iab  <buffer> <m-d>  <C-R>=MapNoContext("\<M-d> ",'\<esc\>0i#define')<CR>
  iab  <buffer> #d     <C-R>=MapNoContext("#d ",'\<esc\>0i#define')<CR>
"-- insert "#include" at start of line
  iab  <buffer> <m-i>  <C-R>=MapNoContext("\<M-i> ",'\<esc\>0i#include')<CR>
  iab  <buffer> #n    <C-R>=MapNoContext("#n ",'\<esc\>0i#include')<CR>

"-- insert "#ifdef/endif" at start of line
  iab  <buffer> #i    <C-R>=MapNoContext('#i ','\<esc\>0i#ifdef')<CR>
  iab  <buffer> #e    <C-R>=MapNoContext("#e ",'\<esc\>0i#endif')<CR>

"}}}
" ------------------------------------------------------------------------
" Control structures {{{
" ------------------------------------------------------------------------
"
" --- if -----------------------------------------------------------------
"--if    insert "if" statement
"  inoremap <buffer> if<space> <C-R>=Def_Map("if ",
  Iabbr <buffer> if <C-R>=Def_Abbr("if ",
      \ '\<c-f\>if () {\<cr\>}\<esc\>?)\<cr\>i',
      \ '\<c-f\>if () {\<cr\>¡mark!\<cr\>}¡mark!\<esc\>?)\<cr\>i')<cr>
"--,if    insert "if" statement
  vnoremap <buffer> <LocalLeader>if 
	\ :call MapAroundVisualLines('if () {','}', 1, 1)<cr>
	" \ ><esc>`>a<cr>}<c-t><esc>`<iif<c-V> () {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>if V<LocalLeader>if

"--elif  insert else clause of if statement with following if statement
  Iabbr <buffer> elif <C-R>=Def_Abbr("elif ",
      \ '\<c-f\>else if () {\<cr\>}\<esc\>?)\<cr\>i',
      \ '\<c-f\>else if () {\<cr\>¡mark!\<cr\>}¡mark!\<esc\>?)\<cr\>i')<cr>
"--,elif  insert else clause of if statement with following if statement
  vnoremap <buffer> <LocalLeader>elif 
	\ :call MapAroundVisualLines('else if () {','}', 1, 1)<cr>
	" \ ><esc>`>a<cr>}<c-t><esc>`<ielse if () {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>elif V<LocalLeader>elif

"--else  insert else clause of if statement
  Iabbr <buffer> else <C-R>=Def_Abbr("else ",
      \ '\<c-f\>else {\<cr\>}\<esc\>O',
      \ '\<c-f\>else {\<cr\>}¡mark!\<esc\>O')<cr>
"--,else  insert else clause of if statement
  vnoremap <buffer> <LocalLeader>else 
	\ :call MapAroundVisualLines('else {','}', 1, 1)<cr>
	" \ ><esc>`>a<cr>}<c-t><esc>`<ielse {<c-f><cr><esc>?{<cr>
      nmap <buffer> <LocalLeader>else V<LocalLeader>else

"--- for ----------------------------------------------------------------
"--for   insert "for" statement
  Iabbr <buffer> for <C-R>=Def_Abbr("for ",
      \ '\<c-f\>for (;;) {\<cr\>}\<esc\>?(\<cr\>a',
      \ '\<c-f\>for (;¡mark!;¡mark!) {\<cr\>¡mark!\<cr\>}¡mark!\<esc\>?(\<CR\>a')<cr>
"--,for   insert "for" statement
  vnoremap <buffer> <LocalLeader>for 
	\ :call MapAroundVisualLines('for (;;) {','}', 1, 1)<cr>
	" \ ><esc>`>a<cr>}<c-t><esc>`<ifor (;;) {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>for V<LocalLeader>for

"--- while --------------------------------------------------------------
"--while insert "while" statement
  Iabbr <buffer> while <C-R>=Def_Abbr("while ",
      \ '\<c-f\>while () {\<cr\>}\<esc\>?(\<cr\>a',
      \ '\<c-f\>while () {\<cr\>¡mark!\<cr\>}¡mark!\<esc\>?(\<CR\>a')<cr>
"--,while insert "while" statement
  vnoremap <buffer> <LocalLeader>while 
	\ :call MapAroundVisualLines('while () {','}', 1, 1)<cr>
	" \ ><esc>`>a<cr>}<c-t><esc>`<iwhile () {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>while V<LocalLeader>while

"--- switch -------------------------------------------------------------
"--switch insert "switch" statement
  Iabbr <buffer> switch <C-R>=Def_Abbr("switch ",
      \ '\<c-f\>switch () {\<cr\>}\<esc\>?(\<cr\>a',
      \ '\<c-f\>switch () {\<cr\>¡mark!\<cr\>}¡mark!\<esc\>?(\<CR\>a')<cr>
"--,switch insert "switch" statement
  vnoremap <buffer> <LocalLeader>switch 
	\ :call MapAroundVisualLines("switch () {\ncase __:",'}', 1, 1)<cr>
	" \ ><esc>`>a<cr>}<c-t><esc>`<iswitch () {<c-f><cr>case __:<c-d><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>switch V<LocalLeader>switch

"--- main ---------------------------------------------------------------
"--Ymain  insert "main" routine
  Iabbr  <buffer> Ymain  int main (int argc, char **argv)<cr>{
"--,main  insert "main" routine
  map <buffer> <LocalLeader>main  iint main (int argc, char **argv)<cr>{


" --- return -------------------------------------------------------------
"-- <m-r> insert "return ;"
  inoremap <buffer> <m-r> <c-r>=BuildMapSeq('return;¡mark!\<esc\>F;i')<cr>

" --- ?: -------------------------------------------------------------
"-- ?: insert "return ;"
  inoremap <buffer> ?: <c-r>=BuildMapSeq('() ?¡mark!:¡mark!\<esc\>F(a')<cr>

"--- Commentaires automatiques -------------------------------------------
"--/* insert /* <curseur>
"             */
  if &syntax !~ "^\(cpp\|java\)$"
    inoreab <buffer> /*  <c-r>=Def_Abbr('/*',
	  \ '/*\<cr\>\<BS\>/\<up\>\<end\>',
	  \ '/*\<cr\>\<BS\>/¡mark!\<up\>\<end\>')<cr>
  endif

"--/*- insert /*-----[  ]-------*/
  inoreab <buffer> /*- 0<c-d>/*<esc>75a-<esc>a*/<esc>45<left>R[

"--/*= insert /*=====[  ]=======*/
  inoreab <buffer> /*0 0<c-d>/*<esc>75a=<esc>a*/<esc>45<left>R[

"}}}
"}}}
" ========================================================================
" General definitions {{{
" ========================================================================
if exists("g:loaded_c_set_vim") 
  let &cpo = s:cpo_save
  finish 
endif
let g:loaded_c_set_vim = 1

" exported function !
function! Def_Map(key,expr1,expr2)
  if exists('b:usemarks') && b:usemarks
    return "\<c-r>=MapNoContext2('".a:key."',BuildMapSeq('".a:expr2."'))\<cr>"
    " return "\<c-r>=MapNoContext2('".a:key."',BuildMapSeq(\"".a:expr2."\"))\<cr>"
  else
    return "\<c-r>=MapNoContext2('".a:key."', '".a:expr1."')\<cr>"
    " return "\<c-r>=MapNoContext2('".a:key."', \"".a:expr1."\")\<cr>"
  endif
endfunction

function! Def_Abbr(key,expr1,expr2)
  if exists('b:usemarks') && b:usemarks
    return "\<c-r>=MapNoContext('".a:key."',BuildMapSeq('".a:expr2."'))\<cr>"
    " return "\<c-r>=MapNoContext('".a:key."',BuildMapSeq(\"".a:expr2."\"))\<cr>"
  else
    return "\<c-r>=MapNoContext('".a:key."', '".a:expr1."')\<cr>"
    " return "\<c-r>=MapNoContext('".a:key."', \"".a:expr1."\")\<cr>"
  endif
endfunction
  let &cpo = s:cpo_save
" }}}
"=============================================================================
" vim600: set fdm=marker:
