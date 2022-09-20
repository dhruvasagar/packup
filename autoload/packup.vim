function! packup#init() abort
  let s:plugins = {}
  let g:plugins = s:plugins
  call mkdir(g:packup_path.'/opt', 'p')
  call mkdir(g:packup_path.'/start', 'p')
  filetype plugin indent on
endfunction

function! packup#add(plugin_url, ...) abort
  let args = copy(a:000)
  call insert(args, a:plugin_url)
  let plugin = call('packup#plugin#new', args)
  let s:plugins[a:plugin_url] = plugin
endfunction

function! packup#install() abort
  " process newly added / removed plugins
  source $MYVIMRC
endfunction

function! packup#update() abort
  for plugin in values(s:plugins)
    call plugin.update()
  endfor
endfunction

function! packup#autoremove() abort
  let packup_list = ['/opt/*', '/start/*']
  let plugin_paths = map(values(copy(s:plugins)), {_, v -> v['path']})
  for pl in packup_list
    for f in glob(g:packup_path.pl, 1, 1)
      if f =~# '\/opt\/packup' | continue | endif
      if index(plugin_paths, f) < 0
        echom 'Removing '.f
        call packup#job#new('autoremove', ['rm -rf', f])
      endif
    endfor
  endfor
endfunction
