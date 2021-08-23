# PackUp v0.2.0

A small wrapper around git for automating process of installing / updating
/ removing vim / neovim plugins

## Overview

Packup helps to automates adding / removing / updating `packages`
**synchronously** on vim / neovim startup if they haven't been installed
already and **asynchronously** when updating using the `PackupUpdate` command.

Additionall it also provides the following features :

* Lazy loading plugins
* Ability to Freeze plugins (skipping updates)
* Install plugins from a specific branch / ref
* Post installation hook

## Requirements

* Vim 8+ (preferably latest) or NeoVIM
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
