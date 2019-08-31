function! s:is_git(plugin_path) abort
  return a:plugin_path =~# '\.git$'
endfunction

function! s:get_name(plugin_path) abort
  let name = a:plugin_path
  if s:is_git(name)
    let name = matchstr(name, '^.\{-}\/\zs.*\ze\.git$')
  endif
  return name
endfunction

function! s:get_path(plugin_path, type) abort
  let path = a:plugin_path
  if s:is_git(path)
    let path = g:packup_path.'/'.a:type.'/'.s:get_name(path)
  endif
  return path
endfunction

let s:plugin_methods = {}
function! s:plugin_methods.exists() dict abort
  return isdirectory(self['path'])
endfunction

function! s:plugin_methods.is_local() dict abort
  return isdirectory(self['url']) || !s:is_git(self['url'])
endfunction

function! s:plugin_methods.exec_do() dict abort
  if !empty(self['do'])
    if type(self['do']) == v:t_string
      echom 'executing '.self['do']
      exec self['do']
    elseif type(self['do']) == v:t_func
      call self['do']()
    endif
  endif
endfunction

function! s:plugin_methods.load() dict abort
  if !empty(self['for'])
    exec 'autocmd FileType' self['for'] 'packadd' self['name']
  else
    packloadall
  endif
endfunction

function! s:plugin_methods.post_install() dict abort
  call self.load()
  silent! exec 'helptags' self['path'].'/doc'
  call self.exec_do()
endfunction

function! s:plugin_methods.clone() dict abort
  if self.is_local() | return | endif
  if !self.exists()
    echom 'Installing '.self['name']
    let cmd = [
          \ 'git clone --quiet',
          \ self['url'],
          \ self['path'],
          \]
    if !empty(self['branch'])
      let cmd += ['--branch=' . self['branch']]
    endif
    if has('vim_starting')
      call system(join(cmd, ' '))
      call self.post_install()
    else
      call packup#job#new(cmd, self.post_install)
    endif
  endif
endfunction

function! s:plugin_methods.install() dict abort
  if self.is_local()
    exec 'set runtimepath+='.self['url']
  endif
  if !empty(self['for']) | call self.load() | endif
  if self.exists() | return | endif
  call self.clone()
endfunction

function! s:plugin_methods.update() dict abort
  if self.is_local() | return | endif
  if !self.exists()
    return self.install()
  endif
  if self['frozen'] | return | endif
  let cmd = [
        \ 'git',
        \ '-C',
        \ self['path'],
        \ 'pull',
        \ '--quiet',
        \ '--ff-only'
        \]
  call packup#job#new(cmd, self.post_install)
endfunction

function! packup#plugin#new(plugin_url, ...) abort
  let default_options = {
        \ 'do': '',
        \ 'for': '',
        \ 'branch': '',
        \ 'frozen': 0,
        \ 'type': 'start',
        \}
  let options = extend(default_options, get(a:000, 0, {}))
  if !empty(options['for']) | let options['type'] = 'opt' | endif
  let plugin = {
        \ 'url': a:plugin_url,
        \ 'name': s:get_name(a:plugin_url),
        \ 'path': s:get_path(a:plugin_url, options['type']),
        \}
  call extend(plugin, options)
  call extend(plugin, s:plugin_methods)
  call plugin.install()
  return plugin
endfunction
