" A silly script to add color to "Christmas", "X-Mas", and "Noël"
"
" Install into ~/.vim/plugin and enjoy festive editing in December.
"
" Author: Tyler Szabo
" Last Update: 2020-12-20
"
" This is free and unencumbered software released into the public domain.
"
" Anyone is free to copy, modify, publish, use, compile, sell, or
" distribute this software, either in source code form or as a compiled
" binary, for any purpose, commercial or non-commercial, and by any
" means.
"
" In jurisdictions that recognize copyright laws, the author or authors
" of this software dedicate any and all copyright interest in the
" software to the public domain. We make this dedication for the benefit
" of the public at large and to the detriment of our heirs and
" successors. We intend this dedication to be an overt act of
" relinquishment in perpetuity of all present and future rights to this
" software under copyright law.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
" IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
" OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
" ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
" OTHER DEALINGS IN THE SOFTWARE.
"
" For more information, please refer to <http://unlicense.org/>
"

function s:X_Mas()
  highlight xmasSyntax guifg=#00ff00 guibg=#800000 ctermfg=LightGreen ctermbg=Red term=italic cterm=italic gui=italic
  highlight xmasSyntax2 guifg=#00e000 guibg=#600000 ctermfg=LightGreen ctermbg=DarkRed term=italic cterm=italic gui=italic

  syntax clear xmasSyntax
  syntax clear xmasSyntax2

  if strftime("%m") == 12
    syntax match xmasSyntax containedin=ALL /\c\<\(Christmas\|Noël\|X[ -]\?mas\)\>/
    syntax match xmasSyntax2 containedin=xmasSyntax contained /\c[crsmxnë]/
  endif
endfunction

augroup x_mas
  autocmd!
  autocmd FileType * call s:X_Mas()
  autocmd BufEnter * call s:X_Mas()
augroup END

call s:X_Mas()
