" markdown Text with R statements
" Language: markdown with R code chunks
" Homepage: https://github.com/jalvesaq/R-Vim-runtime
" Last Change: Wed Apr 21, 2021  09:55AM
"
"   For highlighting pandoc extensions to markdown like citations and TeX and
"   many other advanced features like folding of markdown sections, it is
"   recommended to install the vim-pandoc filetype plugin as well as the
"   vim-pandoc-syntax filetype plugin from https://github.com/vim-pandoc.


if exists("b:current_syntax")
  finish
endif

" Highlight the header of the chunks as R code
let g:qmd_syn_hl_chunk = get(g:, 'qmd_syn_hl_chunk', 0)

" Pandoc-syntax has more features, but it is slower.
" https://github.com/vim-pandoc/vim-pandoc-syntax
let g:pandoc#syntax#codeblocks#embeds#langs = get(g:, 'pandoc#syntax#codeblocks#embeds#langs', ['r', 'python'])
runtime syntax/pandoc.vim
if exists("b:current_syntax")
  " Recognize inline R code
  syn region qmdrInline matchgroup=qmdInlineDelim start="`r "  end="`" contains=@R containedin=pandocLaTeXRegion,yamlFlowString keepend
  hi def link qmdInlineDelim Delimiter

  " Fix recognition of language chunks (code adapted from pandoc, 2021-03-28)
  " Knitr requires braces in the block's header
  for s:lng in g:pandoc#syntax#codeblocks#embeds#langs
    let s:nm = matchstr(s:lng, '^[^=]*')
    exe 'syn clear pandocDelimitedCodeBlock_'.s:nm
    exe 'syn clear pandocDelimitedCodeBlockinBlockQuote_'.s:nm
    if g:qmd_syn_hl_chunk
      exe 'syn region qmd'.s:nm.'ChunkDelim matchgroup=qmdCodeDelim start="^\s*```\s*{\s*'.s:nm.'\>" matchgroup=qmdCodeDelim end="}$" keepend containedin=qmd'.s:nm.'Chunk contains=@R'
      exe 'syn region qmd'.s:nm.'Chunk start="^\s*```\s*{\s*'.s:nm.'\>.*$" matchgroup=qmdCodeDelim end="^\s*```\ze\s*$" keepend contains=qmd'.s:nm.'ChunkDelim,@'.toupper(s:nm)
    else
      exe 'syn region qmd'.s:nm.'Chunk matchgroup=qmdCodeDelim start="^\s*```\s*{\s*'.s:nm.'\>.*$" matchgroup=qmdCodeDelim end="^\s*```\ze\s*$" keepend contains=@'.toupper(s:nm)
    endif
  endfor
  unlet s:lng
  unlet s:nm
  hi def link qmdInlineDelim Delimiter
  hi def link qmdCodeDelim Delimiter
  let b:current_syntax = "qmd"
  finish
endif

" Configuration if not using pandoc syntax:
" Add syntax highlighting of YAML header
let g:qmd_syn_hl_yaml = get(g:, 'qmd_syn_hl_yaml', 1)
" Add syntax highlighting of citation keys
let g:qmd_syn_hl_citations = get(g:, 'qmd_syn_hl_citations', 1)

let s:cpo_save = &cpo
set cpo&vim

" R chunks will not be highlighted by syntax/markdown because their headers
" follow a non standard pattern: "```{lang" instead of "^```lang".
" Make a copy of g:markdown_fenced_languages to highlight the chunks later:
if exists('g:markdown_fenced_languages')
  if !exists('g:qmd_fenced_languages')
    let g:qmd_fenced_languages = deepcopy(g:markdown_fenced_languages)
    let g:markdown_fenced_languages = []
  endif
else
  let g:qmd_fenced_languages = ['r', 'python']
endif

runtime syntax/markdown.vim

" Now highlight chunks:
for s:type in g:qmd_fenced_languages
  if s:type =~ '='
    let s:ft = substitute(s:type, '.*=', '', '')
    let s:nm = substitute(s:type, '=.*', '', '')
  else
    let s:ft = s:type
    let s:nm  = s:type
  endif
  unlet! b:current_syntax
  exe 'syn include @qmd'.s:nm.' syntax/'.s:ft.'.vim'
  if g:qmd_syn_hl_chunk
    exe 'syn region qmd'.s:nm.'ChunkDelim matchgroup=qmdCodeDelim start="^\s*```\s*{\s*'.s:nm.'\>" matchgroup=qmdCodeDelim end="}$" keepend containedin=qmd'.s:nm.'Chunk contains=@qmdr'
    exe 'syn region qmd'.s:nm.'Chunk start="^\s*```\s*{\s*'.s:nm.'\>.*$" matchgroup=qmdCodeDelim end="^\s*```\ze\s*$" keepend contains=qmd'.s:nm.'ChunkDelim,@qmd'.s:nm
  else
    exe 'syn region qmd'.s:nm.'Chunk matchgroup=qmdCodeDelim start="^\s*```\s*{\s*'.s:nm.'\>.*$" matchgroup=qmdCodeDelim end="^\s*```\ze\s*$" keepend contains=@qmd'.s:nm
    exe 'syn region qmd'.s:nm.'Options matchgroup=qmdID start="^#|\s" end="$" keepend containedin=qmd'.s:nm.'Chunk contains=yamlFlowString,qmdYamlFieldTtl,qmdYamlBool'
  endif
endfor
unlet! s:type

hi link qmdID Constant
hi link qmdCodeDelim Keyword

" Recognize inline R code
syn region qmdrInline matchgroup=qmdInlineDelim start="`r "  end="`" contains=@qmdr keepend

" You don't need this if either your markdown/syntax.vim already highlights
" the YAML header or you are writing standard markdown
if g:qmd_syn_hl_yaml
  " Minimum highlighting of yaml header
  syn keyword qmdYamlBool true false
  syn match qmdYamlFieldTtl /\s*\zs.*\ze:/ contained
  syn match qmdYamlFieldTtl /\s*-\s*\zs\w*\ze:/ contained
  syn match qmdYamlFieldTtl /\s*-\s*\zs\w*\ze:/ contained
  syn region yamlFlowString matchgroup=yamlFlowStringDelimiter start='"' skip='\\"' end='"' contains=yamlEscape,qmdrInline contained
  syn region yamlFlowString matchgroup=yamlFlowStringDelimiter start="'" skip="''"  end="'" contains=yamlSingleEscape,qmdrInline contained
  syn match  yamlEscape contained '\\\%([\\"abefnrtv\^0_ NLP\n]\|x\x\x\|u\x\{4}\|U\x\{8}\)'
  syn match  yamlSingleEscape contained "''"
  syn region pandocYAMLHeader matchgroup=qmdYamlBlockDelim start=/\%(\%^\|\_^\s*\n\)\@<=\_^-\{3}\ze\n.\+/ end=/^\([-.]\)\1\{2}$/ keepend contains=qmdYamlFieldTtl,yamlFlowString
  hi def link qmdYamlBool Boolean
  hi def link qmdYamlBlockDelim Delimiter
  hi def link qmdYamlFieldTtl Identifier
  hi def link yamlFlowString String
endif

" You don't need this if either your markdown/syntax.vim already highlights
" citations or you are writing standard markdown
if g:qmd_syn_hl_citations
  " From vim-pandoc-syntax
  " parenthetical citations
  syn match pandocPCite /\^\@<!\[[^\[\]]\{-}-\{0,1}@[[:alnum:]_][[:alnum:]à-öø-ÿÀ-ÖØ-ß_:.#$%&\-+?<>~\/]*.\{-}\]/ contains=pandocEmphasis,pandocStrong,pandocLatex,pandocCiteKey,@Spell,pandocAmpersandEscape display
  " in-text citations with location
  syn match pandocICite /@[[:alnum:]_][[:alnum:]à-öø-ÿÀ-ÖØ-ß_:.#$%&\-+?<>~\/]*\s\[.\{-1,}\]/ contains=pandocCiteKey,@Spell display
  " cite keys
  syn match pandocCiteKey /\(-\=@[[:alnum:]_][[:alnum:]à-öø-ÿÀ-ÖØ-ß_:.#$%&\-+?<>~\/]*\)/ containedin=pandocPCite,pandocICite contains=@NoSpell display
  syn match pandocCiteAnchor /[-@]/ contained containedin=pandocCiteKey display
  syn match pandocCiteLocator /[\[\]]/ contained containedin=pandocPCite,pandocICite
  hi def link pandocPCite Operator
  hi def link pandocICite Operator
  hi def link pandocCiteKey Label
  hi def link pandocCiteAnchor Operator
  hi def link pandocCiteLocator Operator
endif

let b:current_syntax = "qmd"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2
