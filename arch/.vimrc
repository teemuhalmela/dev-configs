set nocompatible

filetype indent plugin on
syntax on

" Kernel
set tabstop=8
set softtabstop=8
set shiftwidth=8
set noexpandtab
" set shiftwidth=4
" set softtabstop=4
" set expandtab

set hidden
set wildmenu
set showcmd
set hlsearch
 
set nomodeline
 
set ignorecase
set smartcase
 
set backspace=indent,eol,start
set autoindent

" Maybe not?
" set nostartofline
" set number

set ruler
set laststatus=2
set confirm
set visualbell
set t_vb=
set mouse=a
set cmdheight=2

set listchars=tab:——,trail:·,extends:>,precedes:<,space:·,nbsp:…
set list

" Disable arrow keys 😬
nnoremap <up>    <nop>
nnoremap <down>  <nop>
nnoremap <left>  <nop>
nnoremap <right> <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>

set t_Co=16
