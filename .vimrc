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
" set scrolloff=5
set mouse=v
"autocmd BufWinLeave *.* mkview
"autocmd BufWinEnter *.* silent loadview
nmap Y y$
set ignorecase
set smartcase

nmap <Space><Space> <Plug>(easymotion-bd-f2)
vmap <Space><Space> <Plug>(easymotion-bd-f2)
map <C-f> <Plug>(easymotion-bd-f2)
nmap <Space>l <Plug>(easymotion-bd-jk)
vmap <Space>l <Plug>(easymotion-bd-jk)
map <C-l> <Plug>(easymotion-bd-jk)
set pastetoggle=<F2>

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

set scrolloff=999


" MAC OS bug fixing
" set clipboard=unnamed
set backspace=indent,eol,start
