" vimrc is utf-8 encoded
scriptencoding utf-8

" Disable defaults
let skip_defaults_vim=1

" Disable viminfo
set viminfo=""

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
" Enable file type plugin
filetype plugin on

" Enable mouse
" set mouse=a

" Disable arrow keys
nnoremap <left> <nop>
nnoremap <right> <nop>
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>

" Show line numbers
set number
set relativenumber
highlight LineNr ctermfg=gray ctermbg=black
highlight CursorLineNr ctermfg=black ctermbg=white

" Underline current line in the insert mode
autocmd InsertEnter * set cul
autocmd InsertLeave * set nocul

" Spell check toggle = F5
nnoremap <F5> :setlocal spell! spelllang=en_us<CR>
" Build = F7
nnoremap <F7> :w<CR>:make<CR>

"""" General
" Show position in file
set ruler
" Show commands as they are being typed in
set showcmd
" Show editing mode
set showmode
" Flash matching delimiters
set showmatch
" Bash-like path autocomplete
set wildmode=longest:full,full
" Display all matching files on tab-complete
set wildmenu

""" Plugins
runtime ftplugin/man.vim
set keywordprg=:Man

"""" Tags and autocomplete
" Create the 'tags' file
command! MakeTags !ctags -R .

"""" Search
" Do not persist search highlight
set nohlsearch
" Show search highlight while typing search
set incsearch

"""" Security
set nomodeline
set modelines=0

"""" Syntax highlighting and indentation
" Syntax
syntax enable
" Enable file-type-specific indentation
"filetype plugin indent on
" Carry indentation
set autoindent
" Resize tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
" Expand tabs by default
set expandtab

" Show trailing white spaces
set list
set listchars=trail:·,tab:\ \ 

" Turn on syntax highlighting for tikz files
au BufNewFile,BufRead *.tikz set filetype=tex

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GUI-specific setting
if has('gui_running')
	" Remove the toolbar
	set guioptions-=T
	" Remove scroll bars
	set guioptions-=r
	set guioptions-=L
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File type specific

"""" Makefile
" Do not expand tabs
autocmd FileType make setlocal noexpandtab

"""" LaTex
" Always use LaTex flavor
let g:tex_flavor = "latex"
" Text formatting
autocmd FileType tex setlocal textwidth=80
autocmd FileType tex setlocal tabstop=4
autocmd FileType tex setlocal noexpandtab
" Key mapping
autocmd FileType tex inoremap ;; <Esc>/<++><CR>c4l
autocmd FileType tex inoremap ;b \textbf{}<++><Esc>4hi
autocmd FileType tex inoremap ;e \emph{}<++><Esc>4hi
autocmd FileType tex inoremap ;tt \texttt{}<++><Esc>4hi
autocmd FileType tex inoremap ;r \autoref{}<++><Esc>4hi
autocmd FileType tex inoremap ;re \eqref{eq:}<++><Esc>4hi
autocmd FileType tex inoremap ;rf \autoref{fig:}<++><Esc>4hi
autocmd FileType tex inoremap ;rt \autoref{tab:}<++><Esc>4hi
autocmd FileType tex inoremap ;rch \autoref{ch:}<++><Esc>4hi
autocmd FileType tex inoremap ;rs \autoref{sec:}<++><Esc>4hi
autocmd FileType tex inoremap ;rss \autoref{subsec:}<++><Esc>4hi
autocmd FileType tex inoremap ;rsss \autoref{subsubsec:}<++><Esc>4hi
autocmd FileType tex inoremap ;l \label{}<++><Esc>4hi
autocmd FileType tex inoremap ;le \label{eq:}<++><Esc>4hi
autocmd FileType tex inoremap ;lf \label{fig:}<++><Esc>4hi
autocmd FileType tex inoremap ;lt \label{tab:}<++><Esc>4hi
autocmd FileType tex inoremap ;lch \label{ch:}<++><Esc>4hi
autocmd FileType tex inoremap ;ls \label{sec:}<++><Esc>4hi
autocmd FileType tex inoremap ;lss \label{subsec:}<++><Esc>4hi
autocmd FileType tex inoremap ;lsss \label{subsubsec:}<++><Esc>4hi
autocmd FileType tex inoremap ;ch \chapter{}<++><Esc>4hi
autocmd FileType tex inoremap ;s \section{}<++><Esc>4hi
autocmd FileType tex inoremap ;ss \subsection{}<++><Esc>4hi
autocmd FileType tex inoremap ;sss \subsubsection{}<++><Esc>4hi
autocmd FileType tex inoremap ;s \section{}<++><Esc>4hi
autocmd FileType tex inoremap ;eq \begin{equation}<CR>\end{equation}<CR><++><Esc>kO
autocmd FileType tex inoremap ;al \begin{align}<CR>\end{align}<CR><++><Esc>kO
autocmd FileType tex inoremap ;fig \begin{figure}<CR>\end{figure}<CR><++><Esc>kO
autocmd FileType tex inoremap ;tab \begin{table}<CR>\end{table}<CR><++><Esc>kO
autocmd FileType tex inoremap ;item \begin{itemize}<CR>\end{itemize}<CR><++><Esc>kO
autocmd FileType tex inoremap ;enum \begin{enumerate}<CR>\end{enumerate}<CR><++><Esc>kO
autocmd FileType tex inoremap ;frame \begin{frame}{}<CR><++><CR>\end{frame}<CR><++><Esc>3k2f{a

"""" Markdown
autocmd FileType markdown setlocal textwidth=80

"""" PHP
autocmd FileType php setlocal textwidth=80

""" Bash

""" Python
autocmd FileType python nnoremap <F7> :w<CR>:! nosetests --with-coverage<CR>

""" PHP
autocmd FileType php nnoremap <F7> :wa<CR>:! phpunit % \| less<CR><CR>

"""" Auto parenthesis and brackets completion (C, C++, PHP)
autocmd FileType c,cpp,php inoremap <expr> ( col(".") == col("$") ? '()<Esc>i' : '('
autocmd FileType c,cpp,php inoremap <expr> [ col(".") == col("$") ? '[]<Esc>i' : '['
autocmd FileType c,cpp,php inoremap <expr> { col(".") == col("$") ? '{<CR>}<Esc>O<Tab>' : '{'

""" Git commit message
autocmd FileType gitcommit setlocal spell spelllang=en_us
autocmd FileType gitcommit nnoremap <F2> :! GIT_PAGER="less -+FX" git diff --cached<CR><CR>
autocmd FileType gitcommit nnoremap <F3> :! GIT_PAGER="less -+FX" git log<CR><CR>
autocmd FileType gitcommit nnoremap <F4> :.-1r !git show -s --format="\%s" HEAD \| grep -oE '\w+(\(\w+\))?: ?' <CR>


