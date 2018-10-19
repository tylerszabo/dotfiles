let s:colorschemes = uniq(sort(split(substitute(globpath(&rtp, 'colors/*.vim'), '[^\n]*[\\/]colors[\\/]\([^\\/]*\)\.vim', '\1', 'g'))))

function! s:SetColorScheme(idx)
  let l:color_name = get(s:colorschemes, a:idx, "default")
  execute 'colorscheme' l:color_name
  let g:colors_name = l:color_name " workaround for themes like codeschool that sets to 'Code School 3'
  redraw | echo g:colors_name
endfunction

function! ColorSchemeNext()
  let l:idx = index(s:colorschemes, g:colors_name) + 1

  if l:idx >= len(s:colorschemes)
    let l:idx = 0
    echo "reset"
  endif

  call s:SetColorScheme(l:idx)
endfunction

function! ColorSchemePrev()
  let l:idx = index(s:colorschemes, g:colors_name) - 1

  if l:idx <= 0
    let l:idx = len(s:colorschemes) - 1
  endif

  call s:SetColorScheme(l:idx)
endfunction

noremap <F8> :call ColorSchemeNext()<CR>
noremap <S-F8> :call ColorSchemePrev()<CR>
