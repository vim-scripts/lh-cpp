" -*- vim -*-
" FILE: "/home/joze/.vim/fold/c.vim"
" LAST MODIFICATION: "Sun, 04 Nov 2001 15:54:28 +0100 (joze)"
" (C) 2001 by Johannes Zellner, <johannes@zellner.org>
" $Id: c.vim,v 1.8 2001/11/05 19:34:01 joze Exp $
"
" setlocal foldmethod=syntax
" finish

" [-- local settings --]
setlocal foldexpr=CFold(v:lnum)
setlocal foldtext=CFoldText()

if exists('*CFold')
    setlocal foldmethod=expr
    finish
endif

fun! CFold(lnum)
    let lnum = a:lnum
    let lastline = line('$')

    while lnum <= lastline
	let line = substitute(getline(lnum), '{[^}]*}', '', 'g')
	if '#' == line[0]
	    " preprocessor line
	    return '='
	endif
	if line =~ '^\s*\(\/\/\|\*\)'
	    " pure c++ comment line or c comment continuation line
	    let lnum = lnum + 1
	    continue
	endif
	let line = substitute(line, '"[^"]*"', '', 'g')
	let line = substitute(line, "'[^']*'", '', 'g')
	let line = substitute(line, '\/\/.*$', '', 'g')
	if line =~ '}[ \t;]*$'
	    " let ind = (indent(lnum) / &sw)
	    " exe 'return "<'.ind.'"'
	    if lnum == a:lnum
		return 's1'
	    else
		return '='
	    endif
	elseif line =~ '[;:]\s*$' || line =~ '^\s*$'
	    " lines ending with a ';', empty lines or labels -- keep folding level
	    " auch: return -1
	    " oder: return '='
	    " return ind
	    return '='
	elseif line =~ '{\s*$'
	    let ind = (indent(lnum) / &sw) + 1
	    exe 'return '.ind
	endif
	let lnum = lnum + 1
    endwhile
endfun

fun! CFoldText()
    if 8 = &ts
	let ts = '        '
    else
	" assume 4 == ts
	let ts = '    '
    endif
    let lnum = v:foldstart
    let lastline = line('$')
    if lastline - lnum > 5
	" use at most 5 lines
	let lastline = lnum + 5
    endif
    let line = ''
    while lnum <= lastline
	let current = getline(lnum)
	if current =~ '^\s*\(\/\/\|\/\*\|\*\)'
	    " don't use pure comment lines or comment continuation lines
	    let lnum = lnum + 1
	    continue
	endif
	let current = substitute(current, '{{{\d\=.*$', '', 'g')
	let current = substitute(current, '\/\*.*\*\/', '', 'g')
	if current =~ '{\s*$'
	    let current = substitute(current, '{\s*$', '', 'g')
	    let break = 1
	else
	    let break = 0
	endif
	if '' == line
	    " preserve indention: substitute leading tabs by spaces
	    let leading_tabs = strlen(substitute(current, "[^\t].*$", '', 'g'))
	    if leading_tabs > 0
		let leading = ''
		let i = leading_tabs
		while i > 0
		    let leading = leading . ts
		    let i = i - 1
		endwhile
		let current = leading . strpart(current, leading_tabs, 999999)
	    endif
	else
	    " remove leading white space
	    let current = substitute(current, '^\s*', '', 'g')
	endif
	if '' != line && '' != current
	    " add a separator
	    let line = line . ' '
	endif
	let line = line . current
	if break
	    break
	endif
	let lnum = lnum + 1
    endwhile
    return substitute(line, "\t", ' ', 'g')
    " let lines = v:folddashes . '[' . (v:foldend - v:foldstart + 1) . ']'
    " let len = 10 - strlen(lines)
    " while len > 0
    "     let lines = lines . ' '
    "     let len = len - 1
    " endwhile
    " return lines . line
endfun

setlocal foldmethod=expr

command! -nargs=0 CFold setlocal foldmethod=expr | setlocal foldmethod=manual

" if exists(":CFolds") | finish | endif

" command! -nargs=0 CFolds call <SID>CCreateFolds()

" TODO:
"
" START PATTERN:
"
" /^\s*\S\_[^{};]*)\_[^);]*{/
"
" END PATTERN:
"
" /???/
"
" :setlocal foldmethod=manual
" :g/START/.,/END/fold
"

" fun! <SID>CCreateFolds()
"     setlocal foldmethod=manual
"     silent! normal zE
"     " functions starting in col 1 only
"     " g/^{/.,/^}/fold
"     g/^[a-zA-Z:_]\_[^{};]*)\_[^);]*\n{/.,/^}/fold
"     "                              ^^     ^
" endfun
