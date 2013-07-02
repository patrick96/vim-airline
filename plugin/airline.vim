if !exists('g:airline_left_sep')
  let g:airline_left_sep = exists('g:airline_powerline_fonts')?"":">"
endif
if !exists('g:airline_right_sep')
  let g:airline_right_sep = exists('g:airline_powerline_fonts')?"":"<"
endif
if !exists('g:airline_enable_fugitive')
  let g:airline_enable_fugitive = 1
endif
if !exists('g:airline_enable_syntastic')
  let g:airline_enable_syntastic = 1
endif
if !exists('g:airline_fugitive_prefix')
  let g:airline_fugitive_prefix = exists('g:airline_powerline_fonts')?'   ':'  '
endif
if !exists('g:airline_readonly_symbol')
  let g:airline_readonly_symbol = exists('g:airline_powerline_fonts')?'':'RO'
endif
if !exists('g:airline_linecolumn_prefix')
  let g:airline_linecolumn_prefix = exists('g:airline_powerline_fonts')?' ':':'
endif
if !exists('g:airline_theme')
  let g:airline_theme = 'default'
endif

set laststatus=2

let s:airline_colors_normal = g:airline#themes#{g:airline_theme}#normal
let s:airline_colors_insert = g:airline#themes#{g:airline_theme}#insert
let s:airline_colors_visual = g:airline#themes#{g:airline_theme}#visual

let s:airline_mode_map = {
      \ 'n'  : '  NORMAL ',
      \ 'i'  : '  INSERT ',
      \ 'R'  : '  RPLACE ',
      \ 'v'  : '  VISUAL ',
      \ 'V'  : '  V-LINE ',
      \ 'c'  : '  CMD    ',
      \ '' : '  V-BLCK ',
      \ }
let s:airline_highlight_map = {
      \ 'mode'           : 'User2',
      \ 'mode_seperator' : 'User3',
      \ 'info'           : 'User4',
      \ 'info_seperator' : 'User5',
      \ 'statusline'     : 'StatusLine',
      \ 'statusline_nc'  : 'StatusLineNC',
      \ 'file'           : 'User6',
      \ 'inactive'       : 'User9',
      \ }

function! s:highlight(mode, keys)
  for key in a:keys
    let colors = s:airline_colors_{a:mode}[key]
    let cmd = printf('hi %s %s %s %s %s %s %s',
          \ s:airline_highlight_map[key],
          \ colors[0] != '' ? 'guifg='.colors[0] : '',
          \ colors[1] != '' ? 'guibg='.colors[1] : '',
          \ colors[2] != '' ? 'ctermfg='.colors[2] : '',
          \ colors[3] != '' ? 'ctermbg='.colors[3] : '',
          \ colors[4] != '' ? 'gui='.colors[4] : '',
          \ colors[4] != '' ? 'term='.colors[4] : '')
    exec cmd
  endfor
endfunction

function! s:update_statusline(active)
  let l:mode_color = a:active ? "%2*" : "%9*"
  let l:mode_sep_color = a:active ? "%3*" : "%9*"
  let l:info_color = a:active ? "%4*" : "%9*"
  let l:info_sep_color = a:active ? "%5*" : "%9*"
  let l:status_color = a:active ? "%*" : "%9*"
  let l:file_flag_color = a:active ? "%6*" : "%9*"

  let sl = a:active ? l:mode_color."%{AirlineModePrefix()}".l:mode_sep_color : l:mode_color." NORMAL %9*"
  let sl.="%{g:airline_left_sep}".l:info_color
  let sl.="%{g:airline_enable_fugitive&&exists('g:loaded_fugitive')? g:airline_fugitive_prefix.fugitive#head():''}\ "
  let sl.=l:info_sep_color."%{g:airline_left_sep}"
  if a:active
    let sl.=l:status_color.(exists('g:bufferline_loaded')?"\ %{bufferline#generate_string()}\ ":"\ %f%m\ ")
  else
    let sl.=" ".bufname(winbufnr(winnr()))
  endif
  let sl.="%#warningmsg#"
  let sl.="%{g:airline_enable_syntastic&&exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}"
  let sl.=l:status_color."%<%=".l:file_flag_color."%{&ro? g:airline_readonly_symbol :''}"
  let sl.="%q%{&previewwindow?'[preview]':''}"
  let sl.=l:status_color."\ %{strlen(&filetype)>0?&filetype:''}\ "
  let sl.=l:info_sep_color."%{g:airline_right_sep}".l:info_color."\ "
  let sl.="%{strlen(&fileencoding)>0?&fileencoding:''}"
  let sl.="%{strlen(&fileformat)>0?'['.&fileformat.']':''}"
  let sl.="\ ".l:mode_sep_color."%{g:airline_right_sep}"
  let sl.=l:mode_color."\ %3p%%\ ".g:airline_linecolumn_prefix."%3l:%3c\ "
  call setwinvar(winnr(), '&statusline', sl)
endfunction

function! AirlineModePrefix()
  let l:mode = mode()

  call <sid>highlight('normal', ['statusline','statusline_nc','inactive','mode','mode_seperator','info','info_seperator','file'])

  if l:mode ==# "i" || l:mode ==# "R"
    call <sid>highlight('insert', ['statusline','mode','mode_seperator','info','info_seperator'])
  elseif l:mode ==? "v" || l:mode ==# ""
    call <sid>highlight('visual', ['statusline','mode','mode_seperator','info','info_seperator'])
  endif

  if has_key(s:airline_mode_map, l:mode)
    return s:airline_mode_map[l:mode]
  endif
  return l:mode
endfunction

" init colors on startup
call AirlineModePrefix()

augroup airline
  au!
  autocmd WinLeave * call <sid>update_statusline(0)
  autocmd VimEnter,WinEnter,BufWinEnter * call <sid>update_statusline(1)
  autocmd ColorScheme * hi clear StatusLine | hi clear StatusLineNC

  " if you know why lazyredraw affects statusline rendering i'd love to know!
  if !&lazyredraw
    autocmd InsertLeave * :redrawstatus
  endif
augroup END