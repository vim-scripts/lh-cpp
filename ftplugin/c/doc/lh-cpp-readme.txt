# VIM: let g:VS_language = 'american' 
*lh-cpp-readme.txt*	For Vim version 6.0+	Last change: 08th oct 2002

		C & C++ ftplugins short presentation	by Luc Hermitte


------------------------------------------------------------------------------
This a very short guide to the archive lh-cpp.tar.gz

Contents~
|lh-cpp-features|	The features proposed by the ftplugins
|Files-from-lh-cpp|	The files that compose the archive

------------------------------------------------------------------------------
							*lh-cpp-features*
Features~
    							*brackets-for-C*
    Bracketing system~
    Files:  	|bracketing.base.vim| & |common_brackets.vim|
    Requires:	|misc_map.vim| (needed); |Triggers.vim| (supported)
    Help:   	<http://hermitte.free.fr/vim/settings.php3>
    
    Options:	
	|b:usemarks|           (0/[1]) : to enable the insertion of |markers|
	|g:brkt_prefer_select| (0/[1]) : select or echo the text within markers
	|g:select_empty_marks| (0/[1]) : select or delete markers on ¡jump¡
        and many more that are pointless here
    
    Mappings defined in this particular configuration:
	¡mark¡  inserts a |marker| -- default : «»
	¡jump¡  jumps to the next marker
	<M-Ins> shortcut to ¡mark¡  
	<M-Del> shortcut to ¡jump¡  
	{       {\n\n}	+ |markers| (if |b:usemarks|==1) and cursor positioned
	[       []	+ |markers| (if |b:usemarks|==1) and cursor positioned
	"       ""	+ |markers| (if |b:usemarks|==1) and cursor positioned
	'       ''	+ |markers| (if |b:usemarks|==1) and cursor positioned
	<F9>	toggles the 4 previous mappings   ; requires |Triggers.vim|
	<M-F9>	toggles the value of |b:usemarks| ; requires |Triggers.vim|
    
    + some mappings from auxtex.vim to manipulate brackets
	<M-b>x <M-b><Delete> : delete a pair of brackets
	<M-b>(	replaces the current pair of brackets with parenthesis
	<M-b>[	replaces the current pair of brackets with square brackets
	<M-b>{	replaces the current pair of brackets with curly brackets
	<M-b>\	toggles the backslash on a pair of brackets
    
    NB: the brackets mappings only insert the markers when |b:usemarks| == 1,
        and they are buffer relative.
	
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							*C_control-statements*
    C Control statements~
    File:	*c_set.vim*
    Requires:	|misc_map.vim| (needed); |brackets-for-C| (supported)
    Help:   	  <http://hermitte.free.fr/vim/settings.php3>
    	   	& <http://hermitte.free.fr/vim/c.php3>
    
    Mappings and abbreviations defined: [always buffer-relative]
     abbr: if	 if {\n}	+ |markers| (if |b:usemarks|==1)   *C_if*
     				+ cursor positioned
     abbr: elif	 else if {\n}	   + ...                           *C_elif*
     abbr: else	 else {\n}	   + ...                           *C_else*
     abbr: while while {\n}	   + ...                           *C_while*
     abbr: for	 for(;;) {\n}	   + ...                           *C_for*
     abbr: main	 int main() \n{\n} + ...			   *C_main*
 
     n&vmap: <LocalLeader>if , elif, else, while, for & main
          	Insert the previous text around the current line (/visual
 		selection).

    NB:* |b:usemarks| is still taken into account 
       * Works even if the bracketing system is not installed or deactivated
         (with <F9>)
       * Not tested with other bracketing systems than the one I propose.
       * Within comment, string or character context, the abbreviations are
         not expanded. Variables like 'tarif' can be used with no problem.
       * Also contains my different settings.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							*C++_control-statements*
    C++ Control statements~
    Files:	*cpp_set.vim*
    Requires:	|c-control-statements|
    Help:   	  <http://hermitte.free.fr/vim/general.php3>
    	   	& <http://hermitte.free.fr/vim/c.php3>

    Mappings and abbreviations defined: [always buffer-relative]
     abbr: try	 try{\n}catch(){\n} + markers and cursor pos.	*C_try*
     abbr: catch catch(){\n}	+ markers and cursor positioned	*C_catch*
     abbr: pub	public:						*C_pub*
     abbr: pro	protected:					*C_pro*
     abbr: pri	private:					*C_pri*
     abbr: tpl	template<>					*C_tpl*
     abbr: virt	virtual						*C_virt*
     imap: <M-s>	std::					*Ci_META-s*
 
     imap: <c-x>be	duplicates the text within parenthesis,	*Ci_CTRL-X_be*
		  add a comma between the two occurrences, and append
		  '.begin()' and '.end()' to each.
     imap: /*<space>	/** */¡mark¡				*C++_comments*
     imap: /**		/**\n*/¡mark¡

    NB: * All the remarks from |C_control-statements| apply

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    					*C++_accessors* *getter* *setter*
    C++ accessors & some templates~
    Files:   cpp_BuildTemplates, cpp_FindContextClass & cpp_InsertAccessor
    Help:    <http://hermitte.free.fr/vim/c.php3>
    Options: *cpp_options.vim*

    Commands:		Mappings to them:
	:HEADER	{name}	    ;HE		Header file template
	:CLASS	{name}	    ;CL		Class declaration template
	:BLINES	{name}	    ;BL		Inserts rulers
	:GROUP	{name}	    ;GR		Inserts a Doc++ group
	:MGROUP	{name}	    ;MGR	Inserts a Doc++ group + a ruler
	:ADDATTRIBUTE	    ;AA		(do it, cursor on the "private" line)
	:REACHINLINE {name} ;RI		Reaches the place where inlines are
					defined
    Notes:
    	* Every thing here match my preferences regarding code presentation
	* The ADDATTRIBUTE command (that inserts an attribute and accessors
	  and mutators (getters and setters)) requires that some formating is
	  respected -- you will certainly have to adapt it.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    					*C++_jump_implementation*
    Jumping to functions' implementation~
    Files:   cpp_FindContextClass & cpp_GotoFunctionImpl.vim
    Help:    <http://hermitte.free.fr/vim/c.php3>
    Options: cpp_options.vim

    Commands:		Mappings to them:
	:GIMPL	{options}   ;GI		Go to function's implementation from
			    <C-W>i	function's prototype
			    <C-X>i	[Insert mode default mapping]

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								*mu-template*
    Gergely Kontra's mu-template~
    Files:   *mu-template.vim* template/template.*
    Purpose: Load a file template 

    Options:
	g:mt_jump_to_first_markers		*g:mt_jump_to_first_markers*
	    Specifies whether we want to jump automatically to the first 
	    |marker| inserted.
	g:author	([$USER/$USERNAME]/"")	*g:author*
	    Used by some templates.
	
    Commands:
	Automatically executed when opening a new file for whom there exists a
	template.&filetype file in the $$/template/ directory.

	:MuTemplate {extension}	 				*MuTemplate*
	    Load the template whose filename has the extension : {extension}.

    Notes:
	* Not required by anything, but supported by the other scripts.
	* This a custom version that I've numbered 0.22

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    Michael Sharpe's a.vim~
    File: a.vim

    Notes:
    * An old version of this plugin is required by cpp_BuildTemplates.vim
       latest version don't suit as I use the private function...
    * Otherwise, it is really nice with C programming

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    Georgi Slavchev's previewWord.vim~
    File:  *previewWord.vim*
    Notes: From a vim tip on sourceforge. ; Not required by anything

    Option: 
    	g:previewIfHold ([0]/1) 	*g:previewIfHold*
	    Automatic search when the cursor hold its position ?

    Mappings:
	<C-Space>	Looks for the declaration of the function name under
			the cursor.
	<M-Space>	Toggles on/off the automatic search when the cursor
			hold its position.
			Defined only if |Triggers.vim| is installed.
    
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    						*C_folding* *C++_folding*
    C & C++ folding~
    Files: fold/c-fold.vim fold/cpp-fold.vim
    Notes:  
	* Developed by Johannes Zellner
    	* To test and use them, drop them your ftplugin folders or look at
	    cleaner solutions like the one used by Johannes Zellner.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
			*search-in-directories-list* *search-in-runtimepath* 
    SearchInRuntime~
    File:     *searchInRuntime.vim*
    Help:     <http://hermitte.free.fr/vim/general.php3>
    
    Commands:
	:SearchInRuntime   {cmd} {pattern}		*:SearchInRuntime*
	:SearchInEnv {ENV} {cmd} {pattern}		*:SearchInEnv*
	:SearchInPATH	   {cmd} {pattern}		*:SearchInPATH*
    
    Tips: >
	:SearchInEnv $INCLUDE sp vector
<	    Will (if $INCLUDE is correctly set) open in a |split| window (:sp)
	    the C++ header file vector.
>
	:SearchInEnv $INCLUDE Echo *
<	    Will echo the name of all the files present in the directories
	    specified in $INCLUDE.


------------------------------------------------------------------------------
							*Files-from-lh-cpp*
Files~
$HOME/.vim/  (/$HOME/vimfiles/ ; cf. 'runtimepath')
+-> doc/
|   +-> |lh-map-tools.txt|  : more precise help regaring the |bracketing| system
|        Don't forget to execute ':helptags $HOME/plugin/doc'
|
+-> ftplugin/
|   +-> c/
|   |   +-> |c_set.vim|					required by cpp_set.vim
|   |   +-> |previewWord.vim|				standalone
|   |   |    Stolen from vim tips
|   |   |    Can take advantage of |Triggers.vim|
|   |   +-> doc/
|   |       +-> |lh-cpp-readme.txt| : this file
|   +-> cpp/
|       +-> |cpp_set.vim|					
|       +-> cpp_FindContextClass.vim 			required by IA
|       +-> cpp_options.vim				required by BT & IA
|       +-> cpp_BuildTemplates.vim [BT]			required by IA
|       +-> cpp_InsertAccessor.vim [IA]
|       +-> cpp_GotoFunctionImpl.vim [GFi]
|     
+-> plugin/
|   +-> |bracketing.base.vim|				supported
|   |   | defines markers to insert after brackets
|   +---+-> |common_brackets.vim|			supported
|   |        defines brackets mappings
|   |
|   +-> |Triggers.vim| 					optional
|   |   | supported by common_brackets.vim to enable/disable |markers|
|   +---+-> fileuptodate.vim				required by Triggers
|   |   |   checks whether a file is more recent than another
|   +---+-> ensurepath.vim				required by Triggers
|   |   |   ensures a directory exists
|   +---+-> fix_d_name.vim				required by Triggers
|   |       changes a path name to respect the shell settings
|   +-> a.vim						required by IA
|   |     old version ; manipulates buffers and windows
|   |
|   +-> |misc_map.vim|
|   |	 required by c(pp)_set.vim and common_brackets.vim
|   |    defines all the functions used to implement the context aware
|   |    mappings from c_set.vim and cpp_set.vim
|   +-> |searchInRuntime.vim|				supported by mu-template
|   |    extends :runtime to other commands
|   |    used by mu-template 0.22 to correctly search in 'runtimepath'
|   +-> homeLikeVC++.vim				independant
|	 toggles the position of the cursor when pressing <home>.
|        behaves like VC++ does.
|
+-> after/plugin/
|   +-> |mu-template.vim|(v0.22)			supported by IA
|        inserts template files
|        IA is compatible with this version : no undesired behaviors
+-> template/
    +-> template.*	template files for |mu-template|


------------------------------------------------------------------------------
 © Luc Hermitte, 2001-2002 <http://hermitte.free.fr/vim/>
 vim:ts=8:sw=4:tw=78:fo=tcq2:isk=!-~,^*,^\|,^\":ft=help:
