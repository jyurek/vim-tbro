if exists("g:loaded_tbro") || &cp || v:version < 700
  finish
endif

let g:loaded_tbro = 1

" Default pane to send commands to
if !exists("g:tbro_pane")
  let g:tbro_pane = 1
endif

function! tbro#send(command, ...) abort
  let g:tbro_last_command = a:command

  let command = substitute(a:command, "'", "'\\\\''", 'g')

  if match(command, "\n$") == -1
    let command = command."\r"
  end

  if a:0 == 1
    let pane_id = a:1
  else
    let pane_id = g:tbro_pane
  end

  call system("tmux set-buffer '".command."'")
  let output = system("tmux paste-buffer -d -t '".pane_id."'")

  if v:shell_error
    echohl WarningMsg | echo output[0:-2] | echohl None
  endif
endfunction

function! tbro#redo()
  call tbro#send(g:tbro_last_command)
endfunction

function! tbro#set_pane(pane_string)
  let g:tbro_pane = a:pane_string
endfunction

function! tbro#pane_complete(...)
  return system('tmux list-panes -F "#S:#I.#P"')
endfunction

command! -nargs=1 Tbro call tbro#send(<q-args>)
command! -nargs=1 -complete=custom,tbro#pane_complete TbroPane
      \ call tbro#set_pane('<args>')
command! TbroRedo call tbro#redo()

if !exists("g:tbro_skip_maps")
  vmap <silent> <Leader>t "ty :call tbro#send(@t)<cr>
  nmap <silent> <Leader>t :call tbro#send(getline('.'))<cr>
endif
