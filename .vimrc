set nocompatible 

filetype off
colorscheme desert 
filetype plugin indent on
syntax on

autocmd FileType yaml setlocal et ts=2 ai sw=2 nu sts=0
set tabstop=4

set background=dark
set mouse=v
nmap Y y$
set ignorecase
set smartcase
set pastetoggle=<F2>

" Center cursor
set scrolloff=999

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" MAC OS bug fixing
set backspace=indent,eol,start

set history=1000 " vim command history
