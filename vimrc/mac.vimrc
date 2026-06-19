" --- Visuals ---
syntax on               " Enable syntax highlighting
set number              " Show absolute line numbers
set cursorline          " Highlight the current line you are on

" --- Search ---
set incsearch           " Show search matches as you type
set hlsearch            " Highlight all search results
set ignorecase          " Ignore uppercase/lowercase in search...
set smartcase           " ...unless you type a capital letter

" --- Indentation & Tabs ---
set autoindent          " Copy indent from current line when starting a new line
set tabstop=4           " Show tabs as 4 spaces wide
set shiftwidth=4        " Indent by 4 spaces when using >> or <<
set expandtab           " Convert Tab key presses to spaces

" Toggle relative line numbers with zrl
nnoremap zrl :set relativenumber!<CR>
nnoremap zjson :%!jq .<CR>
nnoremap hh ^
inoremap hh <C-o>0
nnoremap zl $a
inoremap zl <C-o>$
nnoremap zcc ci"
