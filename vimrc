set number
syntax on
set spell
set hlsearch
set t_Co=256

colorscheme desert
set statusline=%f%m%r%h%w\ [Format=%{&ff}]\ [Type=%Y]%=[%v,%l]
set laststatus=2

set autoindent
set expandtab
set shiftwidth=2
set tabstop=2
set smarttab
set smartindent
set tildeop

imap <f1> <esc>
map <f12> :set spell!<CR>
map <f11> :nohl<CR>
set mouse=a

set guifont=Consolas:h9:cANSI
set guioptions=egm
