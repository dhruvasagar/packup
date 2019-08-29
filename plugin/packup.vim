if exists('g:packup_loaded')
  finish
endif
let g:packup_loaded = 1

if !exists('g:packup_path')
  let g:packup_path = expand('~/.vim/pack/packup')
endif

command! -bar PackupInstall call packup#install_all()
command! -bar PackupUpdate call packup#update_all()
