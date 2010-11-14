" File:		common_brackets.vim
" Author:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 		<URL:http://hermitte.free.fr/vim/>
" Last Update:	17th Sep 2003
" History:      {{{1
" Version 4.1:  * Uses InsertAroundVisual() in order to work even when
"                 'selection' is set to exclusive.
" Version 4.0:  * New option: b:cb_jump_on_close that specify weither the
"                 mappings for the closing brackets are defined or not
"                 default: true (1)
" Version 3.9:  * Updated to match changes within bracketing.base.vim
" 		 -> �xxx! mappings changed to !xxx!
" 		 [encodings issue]
" Version 3.8:  * Updated to match changes within bracketing.base.vim
" 		* Markers-mappings moved back to bracketing.base.vim
" Version 3.7:  * Brackets manipulation mappings for normal mode can be changed
" 		  They are now <Plug> mappings.
" 		  Same enhancement for mappings to �mark! and �jump!
" Version 3.6c: * Change every 'normal' to 'normal!'
" Version 3.6b: * address obfuscated for spammers
" Version 3.6:  * accept default value for b:usemarks
" Version 3.5:  * add continuation lines support ; cf 'cpoptions'
" Version 3.4:	* Works correctly when editing several files (like with 
" 		"vim foo1.x foo2.x").
" 		* ')' and '}' don't search for the end of the bracket when we
" 		are within a comment.
" Version 3.3:	* Add support for \{, \(, \[, \<
"               * Plus some functions to change the type of brackets and
"               toggle backslashes before brackets.
"               Inspired from AucTeX.vim.
" Version 3.2:	* Bugs fixed with {
" Version 3.1:	* Triggers.vim and help.vim used, but not required.
" Version 3.0:	* Pure VIM6
" Version 2.1a:	* Some little change with the requirements
" Version 2.1:	* Use b:usemarks in the mapping of curly-brackets
" Version 2.0:	* Lately, I've discovered (SR) Stephen Riehm's bracketing
" 		macros and felt in love with the markers feature. So, here is
" 		the ver 2.x based on his package.
" 		I still bring an original feature : a centralized way to
" 		customize these pairs regarding options specified within
" 		the ftplugins.
" 		Note that I planned to use this file with my customized
" 		version of Stephan Riehm's file.
" 
" Purpose:      {{{1
" 		This file defines a function (Brackets) that brings
" 		together several macros dedicated to insert pairs of
" 		caracters when the first one is typed. Typical examples are
" 		the parenthesis, brackets, <,>, etc. 
" 		One can choose the macro he wants to activate thanks to the
" 		buffer-relative options listed below.
"
" 		This function is used by different setting files
" 		(ftplugins) : <vim_set.vim>, <ML_set.vim>, <html_set.vim>,
" 		<php_set.vim> and <tex_set.vim> -- available on my VIM web
" 		site.
"
" 		BTW, they can be activated or desactivated by pressing <F9>
" 		Rem.: exe "noremap" is not yet supported by Triggers.vim
" 		Hence the trick with the intermediary functions.
"
" Options:      {{{1
" 	(*) b:cb_bracket			: [ -> [ & ]
"	(*) b:cb_cmp				: < -> < & >
"	    could be customized thanks to b:cb_ltFn and b:cb_gtFn [ML_set.vim]
"	(*) b:cb_acco				: { -> { & }
"	(*) b:cb_parent				: ( -> ( & )
"	(*) b:cb_mathMode			: $ -> $ & $	[tex_set.vim]
"	    type $$ in visual/normal mode
"	(*) b:cb_quotes				: ' -> ' & '
"		== 2  => non active within comment or strings
"	(*) b:cb_Dquotes			: " -> " & "
"	    could be customized thanks to b:cb_DqFn ;	[vim_set.vim]
"		== 2  => non active within comment or strings
"	(*) b:usemarks				: 
"		indicates the wish to use the marking feature first defined by
"		Stephan Riehm.
"	(*) b:cb_jump_on_close			: ), ], }
"	        == 0  => no mappings for ), ] and }
"	        == 1  => mappings for ), ] and } (default)
"
" Dependancies: {{{1
" 	Triggers.vim		(Not required)
" 	misc_map.vim		(required)
" 	bracketing.base.vim	(required)
" 	help.vim for vimrc_core.vim (:VimrcHelp)     (recognized and used.)
"
" Todo:         {{{1
" 	(*) Option b:cb_double that defines weither we must hit '(' or '(('
" 	(*) Support '\%(\)' for vim
" 	(*) Support '||', '\|\|' and '&&' (within eqnarray[*]) for LaTeX.
"	(*) Systematically use b:usemarks for opening and closing
" }}}1
"===========================================================================
"
"======================================================================
" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim

" ------------------------------------------------------------------
" The main function that defines all the key-bindings. " {{{
function! Brackets()
  " [ & ]
  if exists('b:cb_bracket') && b:cb_bracket
    " vnoremap <buffer> [ <esc>`>a]<esc>`<i[<esc>%
    vnoremap <buffer> [ :call InsertAroundVisual('[', ']', 0, 0)<cr>%
"        imap <buffer> [ <C-V>[<C-V>]!mark!<ESC>F]i
    inoremap <buffer> [ <C-R>=<sid>EscapableBrackets('[','\<C-V\>[','\<C-V\>]')<cr>
        nmap <buffer> [ viw[
	nmap <buffer> <M-[> viw[
	imap <buffer> <M-[> <esc><M-[>a
    "inoremap <buffer> ] <esc>/]/<cr>a
  endif
  "
  " < & >
  if exists('b:cb_cmp') && b:cb_cmp
    imap <buffer> < <c-r>=Brkt_lt()<cr>
    imap <buffer> > <c-r>=Brkt_gt()<cr>
    " vnoremap <buffer> < <esc>`>a><esc>`<i<<esc>`>ll
    vnoremap <buffer> < :call InsertAroundVisual('<', '>', 0, 0)<CR>`>ll
        "nmap <buffer> < viw<
	nmap <buffer> <M-<> viw<
	imap <buffer> <M-<> <esc><M-<>a
  endif
  "
  " { & }
  if exists('b:cb_acco') && b:cb_acco
    if &syntax == "tex"
      inoremap <buffer> { <C-R>=<sid>EscapableBrackets('{','{','}')<cr>
    else
      inoremap <buffer> { <C-R>=<sid>Def_Map1('{','{\<cr\>}\<esc\>O','{\<cr\>}!mark!\<esc\>O')<cr>
"      inoremap <buffer> { <C-R>=<sid>EscapableBracketsLn('{','{','}')<cr>
      inoremap <buffer> #{ <C-R>=<sid>Def_Map1('#{','{}\<esc\>i','{}!mark!\<esc\>F{a')<cr>
    endif
    " vnoremap <buffer> { <esc>`>a}<esc>`<i{<esc>%
    vnoremap <buffer> { :call InsertAroundVisual('{', '}', 0, 0)<cr>%
        nmap <buffer> { viw{
        ""nmap <buffer> <M-{> viw{
        ""imap <buffer> <M-{> <esc><M-{>a
    if !exists('b:cb_jump_on_close') || b:cb_jump_on_close
      " nnoremap <buffer> } /}\\|\.\\|&\\|]\\|\$/<CR>a
      nnoremap <buffer> } :call search('}\\|\.\\|&\\|]\\|\$')<CR>a
      ""imap <buffer> !find}! <esc>}
      ""inoremap <buffer> } <c-r>=MapNoContext('}',BuildMapSeq('!find}!'))<cr>
      " Next line does not work well (vim 6.1.362)
      inoremap <buffer> } <C-R>=MapNoContext('}', '\<c-o\>}\<left\>')<CR>
    endif
  endif
  "
  " ( & )
  if exists('b:cb_parent') && b:cb_parent
    inoremap <buffer> ( <C-R>=<sid>EscapableBrackets('(','(',')')<cr>
    if !exists('b:cb_jump_on_close') || b:cb_jump_on_close
      noremap <buffer> ) :call search(')')<cr>a
	 imap <buffer> ) <C-R>=MapNoContext(')', '\<c-o\>/)/e+1/\<cr\>')<CR>
	 " inoremap <buffer> ) <C-R>=MapNoContext(')', '\<esc\>:call search(")")\<cr\>a')<CR>
    endif
    " vnoremap <buffer> ( <esc>`>a)<esc>`<i(<esc>%
    vnoremap <buffer> ( :call InsertAroundVisual('(', ')', 0, 0)<cr>%
        nmap <buffer> ( viw(
        nmap <buffer> <M-(> viw(
        imap <buffer> <M-(> <esc><M-(>a
  endif

  " $ & $
  if exists('b:cb_mathMode') && b:cb_mathMode
    inoremap <buffer> $ <c-r>=Insert_LaTeX_Dollar()<cr>
    " vnoremap <buffer> $$ <ESC>`>a$<ESC>`<i$<ESC>`>ll
    vnoremap <buffer> $$ :call InsertAroundVisual('$', '$', 0, 0)<cr>`>ll
	nmap <buffer> $$ viw$$
	nmap <buffer> <M-$> viw$$
	imap <buffer> <M-$> <esc><M-$>
  endif
  "
  " quotes
  if exists('b:cb_quotes') && b:cb_quotes
    inoremap <buffer> ' <c-r>=Brkt_quote()<cr>
    " vnoremap <buffer> '' <esc>`>a'<esc>`<i'<esc>`>ll
    vnoremap <buffer> '' :call InsertAroundVisual("'", "'", 0, 0)<cr>`>ll
        nmap <buffer> ''    viw''
	nmap <buffer> <M-'> viw''
	" add quotes around the word under the cursor
	imap <buffer> <M-'> <esc><M-'>a
  endif
  "
  " double-quotes
  if exists('b:cb_Dquotes') && b:cb_Dquotes
    inoremap <buffer> " <c-r>=Brkt_Dquote()<cr>
    " vnoremap <buffer> "" <esc>`>a"<esc>`<i"<esc>`>ll
    vnoremap <buffer> "" :call InsertAroundVisual('"', '"', 0, 0)<cr>`>ll
	nmap <buffer> ""    viw""
	nmap <buffer> <M-"> viw""
	" add doqutes around the word under the cursor
	imap <buffer> <M-"> <esc><M-">a
  endif
endfunction " }}}

if !exists('b:usemarks') | let b:usemarks=1 | endif

" Defines a command and the mode switching mappings (with <F9>) {{{
if !exists("*Trigger_Function")
  runtime plugin/Triggers.vim
endif
if exists("*Trigger_Function")
  au Bufenter * :call <SID>LoadBrackets()
  let s:scriptname = expand("<sfile>:p")

  function! s:LoadBrackets()
    if !exists('b:usemarks') | let b:usemarks=1 | endif
    if exists("b:loaded_common_bracket_buff") | return | endif
    let b:loaded_common_bracket_buff = 1
    silent call Trigger_Function('<F9>', 'Brackets', s:scriptname,1,1)
    imap <buffer> <F9> <SPACE><ESC><F9>a<BS>
    silent call Trigger_DoSwitch('<M-F9>',
	  \ ':let b:usemarks='.b:usemarks,':let b:usemarks='.(1-b:usemarks),1,1)
    imap <buffer> <M-F9> <SPACE><ESC><M-F9>a<BS>
  endfunction
endif
" }}}
"======================================================================
" Global definitions : functions & mappings
if exists("g:loaded_common_brackets_vim") 
  let &cpo = s:cpo_save
  finish 
endif
let g:loaded_common_brackets_vim = 1

" ===========================================================================
" Tool functions {{{
" In order to define things like '{'
function! s:Def_Map1(key,expr1,expr2) " {{{
  if exists('b:usemarks') && b:usemarks
    return "\<c-r>=MapNoContext('".a:key."',BuildMapSeq('".a:expr2."'))\<cr>"
  else
    return "\<c-r>=MapNoContext('".a:key."', '".a:expr1."')\<cr>"
  endif
endfunction " }}}

" s:EscapableBrackets, and s:EscapableBracketsLn are two different functions
" in order to achieve a little optimisation
function! s:EscapableBrackets(key, left, right) " {{{
  let r = ((getline('.')[col('.')-2] == '\') ? '\\\\' : "") . a:right
  let expr1 = a:left.r.'\<esc\>i'
  let expr2 = a:left.r.'!mark!\<esc\>F'.a:key.'a'
  if exists('b:usemarks') && b:usemarks
    return "\<c-r>=MapNoContext('".a:key."',BuildMapSeq('".expr2."'))\<cr>"
  else
    return "\<c-r>=MapNoContext('".a:key."', '".expr1."')\<cr>"
  endif
endfunction " }}}

function! s:EscapableBracketsLn(key, left, right) " {{{
  let r = ((getline('.')[col('.')-2] == '\') ? '\\\\' : "") . a:right
  let expr1 = a:left.'\<cr\>'.r.'\<esc\>O'
  let expr2 = a:left.'\<cr\>'.r.'!mark!\<esc\>O'
  if exists('b:usemarks') && b:usemarks
    return "\<c-r>=MapNoContext('".a:key."',BuildMapSeq('".expr2."'))\<cr>"
  else
    return "\<c-r>=MapNoContext('".a:key."', '".expr1."')\<cr>"
  endif
endfunction " }}}
" Tool functions }}}
" ===========================================================================
" The core functions for the previous mappings {{{
" If a backslash precede the current cursor position, insert one dollar,
" and two otherwise.
function! Insert_LaTeX_Dollar() " {{{
  if getline('.')[col('.')-2] == '\'
    return '$'
  else
    return "\<c-v>$\<c-v>$\<c-r>=Marker_Txt()\<cr>\<esc>F$i"
  endif
endfunction " }}}

" Trick : to be switchable with Triggers.vim
" Calls a custom function or returns <> regarding the options
function! Brkt_lt() " {{{
  if exists('b:cb_ltFn')
    return "\<C-R>=" . b:cb_ltFn . "\<CR>"
  else
    return <SID>EscapableBrackets('<', '\<C-V\><', '\<C-V\>>')
  endif
endfunction " }}}

" Trick : to be switchable with Triggers.vim
" Calls a custom function, or search for the next '>', or return '>'
" regarding the options.
function! Brkt_gt() " {{{
  if exists('b:cb_gtFn')        | return "\<C-R>=" . b:cb_gtFn . "\<CR>"
  elseif exists('b:cb_gtFind')  | return "\<esc>/>/\<cr>a"
  else                          | return ">"
  endif
endfunction " }}}

" Centralize all the INSERT-mode mappings associated to quotes
function! Brkt_quote() " {{{
  if b:cb_quotes == 2
    if exists("b:usemarks") && b:usemarks == 1
      return "\<c-r>=MapNoContext(\"'\", " .
	\    "\"''\\<C-R\>=Marker_Txt()\\<CR\>\\<esc\>F'i\")\<cr>"
    else 
      return "\<c-r>=MapNoContext(\"'\", \"''\\<Left\>\")\<cr>"
    endif
  else
    if exists("b:usemarks") && b:usemarks == 1
      return "\<C-V>'\<C-V>'\<c-r>=Marker_Txt()\<cr>\<ESC>F'i"
    else 
      return "''\<left>"
    endif
  endif
endfunction " }}}

" Centralize all the INSERT-mode mappings associated to double-quotes
function! Brkt_Dquote() " {{{
  if b:cb_Dquotes == 2
    if exists("b:usemarks") && b:usemarks == 1
      return "\<c-r>=MapNoContext('\"', '" . '\"\"' . "'." . 
       \ '"\\<C-R\>=Marker_Txt()\\<CR\>\\<esc\>F\\\"i")' . "\<cr>"
    else 
      return "\<c-r>=MapNoContext('\"', '" . 
	\    '\"\"' . "'." . '"\\<Left\>")' . "\<cr>"
    endif
  else
    if exists('b:cb_DqFn')
      return "\<C-R>=" . b:cb_DqFn . "\<CR>"
    elseif exists("b:usemarks") && b:usemarks == 1
      return "\<C-V>\"\<C-V>\"\<c-r>=Marker_Txt()\<cr>\<ESC>F\"i"
    else 
      return "\"\"\<left>"
    endif
  endif
endfunction " }}}

" The core functions for the previous mappings }}}
"======================================================================

"======================================================================
" Matching Brackets Macros, From AuCTeX.vim (due to Saul Lubkin).   {{{
" Except, that I use differently the chanching-brackets functions.
" For normal mode.

" Bindings for the Bracket Macros {{{
if !exists('g:cb_want_mode ') | let g:cb_want_mode = 1 | endif
if g:cb_want_mode " {{{
  if !hasmapto('BracketsManipMode')
    noremap <silent> <M-b>	:call BracketsManipMode("\<M-b>")<cr>
  endif
  " }}}
else " {{{
  if !hasmapto('<Plug>DeleteBrackets')
    map <M-b>x		<Plug>DeleteBrackets
    map <M-b><Del>	<Plug>DeleteBrackets
  endif
  noremap <silent> <Plug>DeleteBrackets	:call <SID>DeleteBrackets()<CR>

  if !hasmapto('<Plug>ChangeToRoundBrackets')
    map <M-b>(		<Plug>ChangeToRoundBrackets
  endif
  noremap <silent> <Plug>ChangeToRoundBrackets	:call <SID>ChangeRound()<CR>

  if !hasmapto('<Plug>ChangeToSquareBrackets')
    map <M-b>[		<Plug>ChangeToSquareBrackets
  endif
  noremap <silent> <Plug>ChangeToSquareBrackets	:call <SID>ChangeSquare()<CR>

  if !hasmapto('<Plug>ChangeToCurlyBrackets')
    map <M-b>{		<Plug>ChangeToCurlyBrackets
  endif
  noremap <silent> <Plug>ChangeToCurlyBrackets	:call <SID>ChangeCurly()<CR>

  if !hasmapto('<Plug>ToggleBackslash')
    map <M-b>\		<Plug>ToggleBackslash
  endif
  noremap <silent> <Plug>ToggleBackslash	:call <SID>ToggleBackslash()<CR>
endif " }}}
" Bindings for the Bracket Macros }}}

"inoremap <C-Del> :call <SID>DeleteBrackets()<CR>
"inoremap <C-BS> <Left><C-O>:call <SID>DeleteBrackets()<CR>

" Then the procedures. {{{
function! s:DeleteBrackets() " {{{
  let s:b = getline(line("."))[col(".") - 2]
  let s:c = getline(line("."))[col(".") - 1]
  if s:b == '\' && (s:c == '{' || s:c == '}')
    normal! X%X%
  endif
  if s:c == '{' || s:c == '[' || s:c == '('
    normal! %x``x
  elseif s:c == '}' || s:c == ']' || s:c == ')'
    normal! %%x``x``
  endif
endfunction " }}}

function! s:ChangeCurly() " {{{
  let s:c = getline(line("."))[col(".") - 1]
  if s:c == '[' || s:c == '('
    exe "normal! i\<Esc>l%i\<Esc>lr}``r{"
  elseif s:c == ']' || s:c == ')'
    exe "normal! %i\<Esc>l%i\<Esc>lr}``r{%"
  endif
endfunction " }}}

function! s:ChangeRound() " {{{
  let s:c = getline(line("."))[col(".") - 1]
  if s:c =~ '[\|{'     | normal! %r)``r(
  elseif s:c =~ ']\|}' | normal! %%r)``r(%
  endif
endfunction " }}}

function! s:ChangeSquare() " {{{ " {{{
  let s:c = getline(line("."))[col(".") - 1]
  if s:c =~ '(\|{'     | normal! %r]``r[
  elseif s:c =~ ')\|}' | normal! %%r]``r[%
  endif
endfunction " }}} " }}}

function! s:ToggleBackslash() " {{{
  let s:b = getline(line("."))[col(".") - 2]
  let s:c = getline(line("."))[col(".") - 1]
  if s:b == '\'
    if s:c =~ '(\|{\|['     | normal! %X``X
    elseif s:c =~ ')\|}\|]' | normal! %%X``X%
    endif
  else
    if s:c =~ '(\|{\|['     | exe "normal! %i\\\<esc>``i\\\<esc>"
    elseif s:c =~ ')\|}\|]' | exe "normal! %%i\\\<esc>``i\\\<esc>%"
    endif
  endif
endfunction " }}}
 
function! BracketsManipMode(starting_key) " {{{
  redraw! " clear the msg line
  while 1
    echohl StatusLineNC
    echo "\r-- brackets manipulation mode (/x/(/[/{/\\/<F1>/q/)"
    echohl None
    let key = getchar()
    let bracketsManip=nr2char(key)
    if (-1 != stridx("x([{\\q",bracketsManip)) || 
	  \ (key =~ "\\(\<F1>\\|\<Del>\\)")
      if     bracketsManip == "x"      || key == "\<Del>" 
	call s:DeleteBrackets() | redraw! | return ''
      elseif bracketsManip == "("      | call s:ChangeRound()
      elseif bracketsManip == "["      | call s:ChangeSquare()
      elseif bracketsManip == "{"      | call s:ChangeCurly()
      elseif bracketsManip == "\\"     | call s:ToggleBackslash()
      elseif key == "\<F1>"
	redraw! " clear the msg line
	echo "\r *x* -- delete the current brackets pair\n"
	echo " *(* -- change the current brackets pair to round brackets ()\n"
	echo " *[* -- change the current brackets pair to square brackets []\n"
	echo " *{* -- change the current brackets pair to curly brackets {}\n"
	echo " *\\* -- toggle a backslash before the current brackets pair\n"
	echo " *q* -- quit the mode\n"
	continue
      elseif bracketsManip == "q"
	redraw! " clear the msg line
	return ''
      " else
      endif
      redraw! " clear the msg line
    else
      redraw! " clear the msg line
      return a:starting_key.bracketsManip
    endif
  endwhile
endfunction " }}}
" Then the procedures. }}}

" Matching Brackets Macros, From AuCTeX.vim (due to Saul Lubkin).   }}}
" ===========================================================================
  let &cpo = s:cpo_save
" ===========================================================================
" Implementation and other remarks : {{{
" (*) Whitin the vnoremaps, `>ll at the end put the cursor at the
"     previously last character of the selected area and slide left twice
"     (ll) to compensate the addition of the sourrounding characters.
" (*) The <M-xxx> key-binding used in insert mode apply on the word
"     currently under the cursor. There also exist the normal mode version
"     of these macros.
"     Unfortunately several of these are not accessible from the french
"     keyboard layout -> <M-{>, <M-[>, <M-`>, etc
" (*) nmap <buffer> " ... is a very bad idea, hence nmap ""
" (*) !mark! and !jump! can't be called yet from MapNoContext().
"     but <c-r>=Marker_Txt()<cr> can.
" }}}
" ===========================================================================
" vim600: set fdm=marker:
