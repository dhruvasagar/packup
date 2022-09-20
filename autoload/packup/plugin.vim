function! s:is_git(plugin_path) abort
  return a:plugin_path =~# '\.git$'
endfunction

function! s:is_local(plugin_path) abort
  return isdirectory(a:plugin_path)
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
  if !s:is_local(path) && s:is_git(path)
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
    let l:pwd = getcwd()
    exec 'noautocmd chdir' self['path']
    try
      echom 'packup: ' .self['name'] . ' executing Do Callback'
      if type(self['do']) == v:t_string
        exec self['do']
      elseif type(self['do']) == v:t_func
        call self['do']()
      endif
    catch
      echohl ErrorMsg | echom v:throwpoint | echom v:exception | echohl None
    finally
      exec 'noautocmd chdir' l:pwd
    endtry
  endif
endfunction

function! s:plugin_methods.load() dict abort
  if !empty(self['for'])
    exec 'autocmd FileType' self['for'] '++once packadd' self['name']
    exec 'autocmd BufNewFile,BufRead * filetype detect'
  else
    if !empty(self['rtp'])
      exec 'set runtimepath+='.self['path'].'/'.self['rtp']
    endif
    if has('vim_starting')
      packloadall
    else
      packloadall!
    endif
  endif
endfunction

function! s:plugin_methods.finalize_install() dict abort
  call self.load()
  silent! exec 'helptags' self['path'].'/doc'
  call self.exec_do()
endfunction

function! s:plugin_methods.post_install() dict abort
  if empty(self['rev'])
    call self.finalize_install()
    return
  endif

  let cmd = [
        \ 'git',
        \ '-C',
        \ self['path'],
        \ 'reset',
        \ '--hard',
        \ self['rev']
        \]
  call packup#job#new(self['name'], cmd, self.finalize_install)
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
    call packup#job#new(self['name'], cmd, self.post_install)
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
  if self['frozen'] || !empty(self['rev']) | return | endif
  let cmd = [
        \ 'git',
        \ '-C',
        \ self['path'],
        \ 'pull',
        \ '--quiet',
        \ '--ff-only'
        \]
  call packup#job#new(self['name'], cmd, self.post_install)
endfunction

function! packup#plugin#new(plugin_url, ...) abort
  let default_options = {
        \ 'do': '',
        \ 'for': '',
        \ 'rtp': '',
        \ 'rev': '',
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
