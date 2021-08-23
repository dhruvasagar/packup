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

function! s:nvim_job_handler(callback, job_id, data, event) abort
  if !empty(a:data) && (type(a:data) == v:t_list && !empty(a:data[0]))
    if a:event == "stderr"
      echom 'nvim packup: job: err: '.string(a:data)
    elseif a:event == "exit"
      echom 'nvim packup: job: exit: '.string(a:data)
      call a:callback()
    endif
  else
    call a:callback()
  endif
endfunction

function! packup#job#new(cmd, ...) abort
  let Callback = a:0 ? a:1 : {->''}
  let cmd = join(a:cmd, ' ')
  if has('vim_starting')
    call system(cmd)
  else
    if has('nvim')
      let job = jobstart(a:cmd, {
            \ 'on_stdout': function('s:nvim_job_handler', [Callback]),
            \ 'on_stderr': function('s:nvim_job_handler', [Callback]),
            \ 'on_exit': function('s:nvim_job_handler', [Callback])
            \})
      return job
    endif
    let job = job_start(cmd, {
          \ 'in_io': 'null',
          \ 'out_mode': 'nl',
          \ 'out_cb': function('s:job_out_handler'),
          \ 'err_cb': function('s:job_err_handler'),
          \ 'exit_cb': function('s:job_exit_handler', [Callback])
          \})
    return job
  endif
endfunction
