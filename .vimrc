set nocompatible              " be iMproved, required
filetype off                  " required
colorscheme desert 

filetype plugin indent on    " required
syntax on
set tabstop=4
set expandtab
set shiftwidth=2
set softtabstop=2
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
