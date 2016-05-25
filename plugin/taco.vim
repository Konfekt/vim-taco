" Vimscript Setup
if exists("g:loaded_taco") || v:version < 703 || &compatible
  finish
endif
let g:loaded_taco = 1

let g:taco_completions = {
  \ 'file':  {'rank': 10,
  \           'keys': "\<C-x>\<C-f>",
  \           'pattern': '\v' . (has('win32') ? '\f\\' : '\/') . '\f*$' },
  \ 'omni':  {'rank': 20,
  \           'keys': "\<C-x>\<C-o>",
  \           'pattern': '\m\<\v\k+(\.|->|::)\k*$' },
  \ 'user':  {'rank': 30,
  \           'keys': "\<C-x>\<C-u>",
  \           'pattern': 0 },
  \ 'line':  {'rank': 40,
  \           'keys': "\<C-x>\<C-l>",
  \           'pattern': '0' },
  \ 'spell': {'rank': 50,
  \           'keys': "\<C-x>\<C-s>",
  \           'pattern': 0 },
  \ 'vim':   {'rank': 60,
  \           'keys': "\<C-x>\<C-v>",
  \           'pattern': 0 },
  \ 'gen':   {'rank': 99,
  \           'keys': "\<C-n>",
  \           'pattern': '\m\<\v\k+$' },
  \ }

function! s:rank(i1, i2)
  let rank1 = b:taco_completions[a:i1].rank
  let rank2 = b:taco_completions[a:i2].rank
	return rank1 == rank2 ? 0 : rank1 > rank2 ? 1 : -1
endfunction

function! s:complete(shift)
  let Ctrl_PN = a:shift ? "\<C-p>" : "\<C-n>"

  if pumvisible()
    return Ctrl_PN
  endif
  
  " Cursor after whitespace => indent
  let pos = getpos('.')
  let textBeforeCursor = strpart(getline(pos[1]), 0, pos[2]-1)
  if textBeforeCursor =~ '\v(\s+|^)$'
    return a:shift ? "\<C-W>" : "\<tab>"
  endif

  " Completion tried => Vim's generic keyword completion
  if get(b:,'taco_completion_tried') && (get(b:, 'tab_complete_pos', []) == pos)
    let b:taco_completion_tried = 0
    return "\<C-e>" . Ctrl_PN
  endif

  " Start completing => keep record for fallback
  let b:tab_complete_pos = pos
  let b:taco_completion_tried = 1

  " User is typing a path or omnicomplete or tabcomplete pattern?
  for c in b:taco_completions_ranked 
    let is_pattern = ( (b:taco_completions[c].pattern isnot 0)  && match(textBeforeCursor, b:taco_completions[c].pattern) >= 0)
    if is_pattern
      return b:taco_completions[c].keys
    endif
  endfor
endfunction

function! s:unsetUndefinedCompletions()
  if empty(&l:omnifunc) && !empty(&l:syntax)
    setlocal omnifunc=syntaxcomplete#Complete
  endif
  if empty(&l:omnifunc) && exists('b:taco_completions.omni')
    let b:taco_completions.omni.pattern = 0
  elseif empty(&l:completefunc) && exists('b:taco_completions.user')
    let b:taco_completions.user.pattern = 0
  elseif !&l:spell && exists('b:taco_completions.spell')
    let b:taco_completions.spell.pattern = 0
  endif
  let b:taco_completions_ranked = sort(keys(b:taco_completions), 's:rank')
endfunction

augroup VCM
  autocmd!
  autocmd InsertEnter * let b:taco_completion_tried = 0
  if v:version > 703 || v:version == 703 && has('patch598')
    autocmd CompleteDone * let b:taco_completion_tried = 0
  endif
  autocmd VimEnter,BufWinEnter,FileType *     if !exists('b:taco_completions') |
                                   \   let b:taco_completions = deepcopy(g:taco_completions) |
                                   \ endif
  autocmd VimEnter *
\ autocmd BufWinEnter,FileType * call s:unsetUndefinedCompletions()
augroup END

inoremap <expr> <plug>vim_completes_me_forward  <sid>complete(0)
inoremap <expr> <plug>vim_completes_me_backward <sid>complete(1)
inoremap <expr> <plug>vim_completes_me_slash
              \ (pumvisible() && <SID>cursorBehindPath()) ?
              \ "\<C-y>\<C-x><C-f>" : "\\"
inoremap <expr> <plug>vim_completes_me_backslash
              \ (pumvisible() && <SID>cursorBehindPath()) ?
              \ "\<C-y>\<C-x><C-f>" : "/"

function! <SID>cursorBehindPath()
  let pos = getpos('.')
  let textBeforeCursor = strpart(getline(pos[1]), 0, pos[2]-1)
  return  textBeforeCursor =~ '\v\f+' . (has('win32') ? '\\' : '\/')
endfunction

if !(exists('g:taco_no_default_maps') && g:taco_no_default_maps)
  imap   <Tab>   <plug>vim_completes_me_forward
  imap   <S-Tab> <plug>vim_completes_me_backward
  if has('win32')
    imap \       <plug>vim_completes_me_slash
  else
    imap /       <plug>vim_completes_me_backslash
  endif
endif
