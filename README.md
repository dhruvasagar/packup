# PackUp

Yet another package manager for VIM, except that it's truly Minimal.

## Overview

Package manager so dope, you just packup and leave.
Leverage `packages` and `jobs` for easy & fast management.

> NOTE: This only supports VIM, support for NeoVIM is being added.

## Requirements

* Vim 8+ (preferably latest)
* Git 1.9+
* OS: Linux / OSX (Probably works on Windows but hasn't been tested)

## Installation

```sh
$ git clone git@github.com:dhruvasagar/packup.git ~/.vim/pack/packup/opt/packup
```

## Usage

You can add the following to your vimrc :

```vim
packadd packup

" Initialize packup
call packup#init()

" Let packup manage itself
call packup#add('git@github.com:dhruvasagar/packup.git', {'type': 'opt'})

" Add rest of your plugins
call packup#add('/usr/local/my_vim_plugin')
call packup#add('git@github.com:dhruvasagar/vim-zoom.git')
call packup#add('git@github.com:dhruvasagar/vim-procession.git', {'type': 'opt'})
call packup#add('git@github.com:pangloss/vim-javascript.git', {'for': 'javascript'})

" Remove any plugins not used anymore
call packup#autoremove()
```

## License

VIM License
