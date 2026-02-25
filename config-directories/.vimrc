" === Basic behavior ===
set nocompatible                " don't try to be vi compatible
filetype plugin indent on       " load filetype-specific indent files
syntax enable                   " enable syntax highlighting

" === Indentation & Tabs ===
set tabstop=2                   " visual spaces per TAB
set softtabstop=2               " number of spaces in tab when editing
set shiftwidth=2                " number of spaces to use for autoindent
set expandtab                   " tabs are spaces
set smartindent                 " try to be smart about indenting
set autoindent                  " copy indent from current line

" === Line number ===
set number                      " show absolute line number on current line
set relativenumber              " show relative line numbers

" === UI / Visual improvements ===
set showcmd                     " show last command in bottom bar
"set cursorline                  " highlight current line
autocmd InsertEnter * set nocursorline
autocmd InsertLeave * set cursorline
set wildmenu                    " visual autocomplete for command menu
set showmatch                   " highlight matching [{()}]
set laststatus=2                " always show status line
set ruler                       " show line/col position
set showmatch
set scrolloff=5


" === Search ===
set incsearch                   " search as characters are entered
set hlsearch                    " highlight matches
set ignorecase                  " case insensitive search...
set smartcase                   " ... unless uppercase is used

" === Performance / UX ===
set hidden                      " allow switching buffers without saving
set scrolloff=5                 " keep some lines above/below cursor
set mouse=a                     " enable mouse (very useful in 2025)
set encoding=utf-8
set fileencoding=utf-8
set nobackup                    " no backup files (use git instead)
set nowritebackup
set noswapfile                  " no swap files



" === Colorscheme === "
set bg=dark
" Try these in order (use the first one that exists)
if exists('+termguicolors')
  set termguicolors
endif

" Good built-in / near-universal options:
try
  colorscheme nord
catch
endtry

" Better modern choices (uncomment one if you have it installed):
" colorscheme gruvbox
" colorscheme solarized
" colorscheme nord
" colorscheme tokyonight
" colorscheme catppuccin 
" colorscheme rose-pine
" colorscheme desert


" === Common key mappings ===
" Clear search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Quick save
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>

" Move line up/down (visual mode)
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
