function! packup#init() abort
  if !isdirectory(g:packup_path.'/opt')
    call mkdir(g:packup_path.'/opt', 'p')
  endif
  if !isdirectory(g:packup_path.'/start')
    call mkdir(g:packup_path.'/start', 'p')
  endif
endfunction

let s:plugins = {}
function! packup#add(plugin_url, ...) abort
  let args = copy(a:000)
  call insert(args, a:plugin_url)
  let plugin = call('packup#plugin#new', args)
  let s:plugins[a:plugin_url] = plugin
endfunction
let g:plugins = s:plugins

function! packup#install_all() abort
  for plugin in values(s:plugins)
    call plugin.install()
  endfor
endfunction

function! packup#update_all() abort
  for plugin in values(s:plugins)
    call plugin.update()
  endfor
endfunction
