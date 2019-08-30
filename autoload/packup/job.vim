function! s:job_out_handler(channel, msg) abort
  if ch_status(a:channel) ==# "fail"
    echom 'packup: job: '.a:msg
  endif
endfunction

function! s:job_exit_handler(callback, channel, msg) abort
  if ch_status(a:channel) ==# "fail"
    echom 'packup: job: exit: '.a:msg
  endif
  call a:callback()
endfunction

function! s:job_err_handler(channel, msg) abort
  echom 'packup: job: err: '.a:msg
endfunction

function! packup#job#new(cmd, ...) abort
  let Callback = a:0 ? a:1 : {->''}
  if has('nvim')
    let job = jobstart(a:cmd, {
          \ 'on_stdout': function('s:job_out_handler'),
          \ 'on_stderr': function('s:job_err_handler'),
          \ 'on_exit': Callback,
          \})
    return job
  endif
  let cmd = join(a:cmd, ' ')
  let job = job_start(cmd, {
        \ 'in_io': 'null',
        \ 'out_mode': 'nl',
        \ 'out_cb': function('s:job_out_handler'),
        \ 'err_cb': function('s:job_err_handler'),
        \ 'exit_cb': function('s:job_exit_handler', [Callback])
        \})
  return job
endfunction
