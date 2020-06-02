set encoding=utf-8
scriptencoding utf-8

" --------------------------------
" 初期化
" --------------------------------
augroup vimrc
  autocmd!
augroup END

let s:is_windows = has('win32') || has('win64')
let s:is_mac = has('mac') || system('uname') =~? '^darwin'
let s:is_linux = !s:is_mac && has('unix')


" --------------------------------
" 基本設定
" --------------------------------
setglobal confirm
setglobal cmdheight=2                " 画面下部のコマンドラインの高さ
setglobal showcmd
setglobal scrolloff=5
setglobal fileformats=unix,dos,mac   " 改行文字
setglobal modeline
setglobal splitright
setglobal splitbelow
setglobal lazyredraw                 " 高速化
setglobal ttyfast                    " 高速化
setglobal mouse=a                    " 全モードでマウスを有効化
setglobal ttymouse=sgr               " マウスコードの設定
setglobal shellslash                 " パス区切りをスラッシュにする
setglobal formatoptions+=mM          " 整形オプションにマルチバイト系を追加
setglobal clipboard+=unnamed         " クリップボードと無名レジスタを共有
" setglobal ambiwidth=double           " □とか○等の文字でカーソル位置がずれないようにする
" setglobal ambiwidth=single           " powerline patched font を使用するため
setglobal backspace=indent,eol,start " BSで，インデント・改行の削除，挿入モード開始位置での削除を有効
setglobal whichwrap+=h,l,<,>         " カーソルを行頭、行末で止まらないようにする
setglobal hidden                     " 未保存状態でバッファの切り替えを可能にする
setglobal autoread                   " 自動読み込み
setglobal noswapfile                 " スワップファイルを作成しない
setglobal nobackup                   " backupファイル(file.txt~)を作成しない
setglobal backupcopy=yes             " noで動作する場合samba上のファイルを書き込んだ際にgroupのパーミッションが変わる
setglobal wrapscan                   " 最後まで検索したら先頭に戻る
setglobal ignorecase                 " 大文字小文字を無視する
setglobal smartcase                  " 検索文字列に大文字が含まれている場合は区別して検索する
setglobal hlsearch                   " 検索語を強調表示
setglobal incsearch                  " インクリメンタルサーチを有効化
setglobal shortmess-=S               " 検索合致数を表示
setglobal wrap
set breakindent                      " 折り返しにインデントを反映する
setglobal directory=~/.vim/tmp       " swpファイルの作成先
setglobal undodir=~/.vim/tmp         " undoファイルの作成先
set undofile                         " persistent_undoを有効化
setglobal sessionoptions-=options
setglobal sessionoptions-=blank
setglobal laststatus=2
setglobal showtabline=2              " tablineを常時表示
setglobal guioptions-=e              " tablineをCUIで表示
setglobal wildmenu                   " コマンドラインモードでの補完を有効に
setglobal wildchar=<tab>             " コマンド補完を開始するキー
setglobal history=1000               " コマンド・検索パターンの履歴数
setglobal wildmode=list:longest,full
setglobal wildignorecase
setglobal completeopt=menuone,popup,noselect,noinsert
setglobal termwinkey=<C-g>
if executable('rg')
  set grepprg=rg\ -i\ --vimgrep
endif

" ウィンドウ移動時に変更チェック
autocmd vimrc WinEnter,FocusGained * checktime

function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

if s:is_mac
  " ターミナルでカーソル形状変更
  let &t_SI .= WrapForTmux("\<Esc>]50;CursorShape=1\x7")
  let &t_SR .= WrapForTmux("\<Esc>]50;CursorShape=2\x7")
  let &t_EI .= WrapForTmux("\<Esc>]50;CursorShape=0\x7")
endif

" :terminal を現在のバッファのパスで開く
function s:start_termianl_bufpath() abort
  let l:cwd = expand('%:p:h')
  botright new
  call term_start(&shell, { 'cwd': l:cwd, 'term_finish': 'close', 'curwin': 1 })
endfunction
command! TermCurBufPath call s:start_termianl_bufpath()

" --------------------------------
" プラグイン
" --------------------------------
call plug#begin('~/.vim/plug')

Plug 'vim-jp/vimdoc-ja'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
let g:lsp_diagnostics_enabled = 0
let g:lsp_fold_enabled=0
function! s:on_lsp_buffer_enabled() abort
  nmap <buffer> <C-]> <plug>(lsp-peek-definition)
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gD <plug>(lsp-declaration)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gs <plug>(lsp-document-symbol)
  nmap <buffer> gS <plug>(lsp-workspace-symbol)
  nmap <buffer> gQ <plug>(lsp-document-format)
  xmap <buffer> gQ <plug>(lsp-document-range-format)
  nmap <buffer> K <plug>(lsp-hover)
  nmap <buffer> <F1> <plug>(lsp-implementation)
  nmap <buffer> <F2> <plug>(lsp-rename)

  setlocal omnifunc=lsp#complete
endfunction
augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-emoji.vim'
Plug 'yami-beta/asyncomplete-omni.vim'

function! s:asyncomplete_on_post_source() abort
  call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
  \ 'name': 'omni',
  \ 'whitelist': ['*'],
  \ 'blacklist': ['sql', 'ruby', 'go', 'typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
  \ 'completor': function('asyncomplete#sources#omni#completor')
  \  }))

  call asyncomplete#register_source(asyncomplete#sources#emoji#get_source_options({
  \ 'name': 'emoji',
  \ 'whitelist': ['markdown', 'gitcommit'],
  \ 'completor': function('asyncomplete#sources#emoji#completor'),
  \ }))

  call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
  \ 'name': 'buffer',
  \ 'whitelist': ['*'],
  \ 'blacklist': ['go', 'typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
  \ 'priority': -1,
  \ 'completor': function('asyncomplete#sources#buffer#completor'),
  \ }))
endfunction
autocmd vimrc User plug_on_load call s:asyncomplete_on_post_source()

Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
command! -bang FZFRelative call fzf#vim#files(expand('%:p:h'), <bang>0)
function! s:fzf_repo() abort
  function! s:repo_cb(line) abort
    let l:basepath = trim(system('ghq root'))
    let l:path = fnamemodify(l:basepath.'/'.a:line, ':p')
    call execute('cd '.l:path)
  endfunction
  call fzf#run({
  \ 'source': systemlist('ghq list'),
  \ 'sink': function('s:repo_cb')
  \ })
endfunction
command! Repo call s:fzf_repo()
Plug 'yami-beta/fzf-session.vim'

Plug 'mattn/vim-sonictemplate'
let g:sonictemplate_vim_template_dir = [
\ '$HOME/dev/src/github.com/yami-beta/dotfiles/vim/template'
\ ]

Plug 'scrooloose/nerdtree'

" 見た目
Plug 'flazz/vim-colorschemes'
Plug 'yami-beta/vim-colors-yuzu'
Plug 'yami-beta/vim-colors-ruri'
Plug 'yami-beta/vim-colors-nouvelle-tricolor'
" Plug 'ap/vim-buftabline'

Plug 'yami-beta/vim-responsive-tabline'

Plug 'itchyny/lightline.vim'
let g:lightline = {
\ 'colorscheme': 'nouvelle_tricolor',
\ 'active': {
\   'left': [ [ 'mode', 'paste' ], [ 'filename' ] ],
\   'right': [ [ 'lineinfo' ], [ 'linter_warnings', 'linter_errors', 'linter_ok' ], [ 'fileformat', 'fileencoding', 'filetype' ] ]
\ },
\ 'component_function': {
\   'filename': 'LightLineFilename',
\   'fileformat': 'LightLineFileformat',
\   'filetype': 'LightLineFiletype',
\   'fileencoding': 'LightLineFileencoding',
\   'mode': 'LightLineMode'
\ },
\ 'component_expand': {
\   'linter_warnings': 'LightlineLinterWarnings',
\   'linter_errors': 'LightlineLinterErrors',
\   'linter_ok': 'LightlineLinterOK'
\ },
\ 'enable': { 'tabline': 0 },
\ }

function! LightLineModified()
  return &ft =~ 'help\|vimfiler' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &readonly ? "RO" : ''
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:.') ? expand('%:.') : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? (&fileformat.' '.WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype.' '.WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

let s:ale_linting = 0
function! s:update_ale_linting(val) abort
  let s:ale_linting = a:val
  call lightline#update()
endfunction
augroup LightLineOnALE
  autocmd!
  autocmd User ALEFixPre  call s:update_ale_linting(1)
  autocmd User ALEFixPost call s:update_ale_linting(0)
  autocmd User ALELintPre  call s:update_ale_linting(1)
  autocmd User ALELintPost call s:update_ale_linting(0)
augroup end

function! LightlineLinterWarnings()
  return s:lightline_ale_string('warn')
endfunction

function! LightlineLinterErrors()
  return s:lightline_ale_string('error')
endfunction

function! LightlineLinterOK()
  return s:lightline_ale_string('ok')
endfunction

function! s:lightline_ale_string(mode)
  if s:ale_linting
    " ok のフィールドでのみ実行中アイコンを返す
    return a:mode == 'ok' ? nr2char(0xf46a).' ' : ''
  endif

  if a:mode == 'ok'
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors
    return l:counts.total == 0 ? nr2char(0xf4a1).' ' : ''
  elseif a:mode == 'warn'
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors
    return l:counts.total == 0 ? '' : all_non_errors . ' ' . nr2char(0xf420).' '
  elseif a:mode == 'error'
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors
    return l:counts.total == 0 ? '' : all_errors . ' ' . nr2char(0xf421).' '
  else
    return ''
  endif
endfunction

function! LightLineMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

Plug 'kana/vim-submode'
Plug 'junegunn/vim-easy-align'
Plug 'tyru/caw.vim'
Plug 'andymass/vim-matchup' " matchit.vim の改善版

Plug 'kana/vim-operator-user'
Plug 'machakann/vim-sandwich'
Plug 'kana/vim-operator-replace'
"
Plug 'kana/vim-textobj-user'
Plug 'rhysd/vim-textobj-ruby'
Plug 'kana/vim-textobj-indent'

Plug 'dense-analysis/ale'
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'never'
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_markdown_prettier_use_global = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\ 'javascript': ['eslint', 'prettier'],
\ 'typescript': ['eslint', 'prettier'],
\ 'typescriptreact': ['eslint', 'prettier'],
\ 'scss': ['prettier'],
\ 'ruby': ['rubocop']
\ }

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_fmt_command = "goimports"

Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascriptreact'] }
Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
Plug 'MaxMEllon/vim-jsx-pretty', { 'for': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'] }

Plug 'jparise/vim-graphql', { 'for': ['javascript', 'typescript'] }

Plug 'hail2u/vim-css3-syntax'
" Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

Plug 'delphinus/vim-firestore'

Plug 'digitaltoad/vim-pug', { 'for': 'pug' }
Plug 'mattn/emmet-vim'
let g:user_emmet_leader_key = '<C-z>'
let g:user_emmet_settings = {
\   'html': {
\     'snippets': {
\       'html:5': "<!DOCTYPE html>\n"
\                ."<html lang=\"${lang}\">\n"
\                ."<head>\n"
\                ."\t<meta charset=\"${charset}\">\n"
\                ."\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">\n"
\                ."\t<title></title>\n"
\                ."</head>\n"
\                ."<body>\n\t${child}|\n</body>\n"
\                ."</html>",
\     },
\   },
\   'javascript': {
\     'extends': 'jsx',
\   },
\   'javascript.jsx': {
\     'extends': 'jsx',
\   },
\   'typescript': {
\     'extends': 'jsx',
\   },
\   'typescript.jsx': {
\     'extends': 'jsx',
\   },
\   'variables': {
\     'lang': 'ja',
\   }
\ }

Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
let g:vim_markdown_folding_disabled=1
Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'chr4/nginx.vim', { 'for': 'nginx' }

Plug 'elzr/vim-json', { 'for': 'json' }

Plug 'lambdalisue/gina.vim'

Plug 'lilydjwg/colorizer'

" 検索・置換を便利にする
Plug 'haya14busa/vim-asterisk'
Plug 'markonm/traces.vim'

Plug 'cohama/lexima.vim'
" lexima.vimは初回のInsertEnter時に初期処理が実行されるため注意が必要
" 1. InsertEnterで lexima#init() が呼ばれる
" 2. lexima#init() の中身は空だが autoload/lexima.vim の lexima#set_default_rules() が呼ばれる
" 3. 各種 mapping が設定されるので、これ以前の mapping は上書きされる
"     - <CR> 等は g:lexima#newline_rules で mapping がされる
"
" InsertEnterが呼ばれる前に lexima#add_rule() を呼び出すと autoload/lexima.vim が実行され
" 各種 mapping が設定されるので、この後 map して上書きを回避している
function! s:lexima_on_post_source() abort
  call lexima#add_rule({'char': '<TAB>', 'at': '\%#[)}\]''"]', 'leave': 1})
  " for todo list (e.g. `- [ ] todo`)
  call lexima#add_rule({'char': '<Space>', 'at': '\[\%#]', 'input': '<Space>', 'filetype': 'markdown'})
  " <TAB>と<CR>のマッピングを元に戻す
  inoremap <silent><expr><TAB> pumvisible() ? "\<C-n>" : lexima#expand('<LT>TAB>', 'i')
  inoremap <silent><expr><CR> pumvisible() ? asyncomplete#close_popup() : lexima#expand('<LT>CR>', 'i')
endfunction
autocmd vimrc User plug_on_load call s:lexima_on_post_source()

" 最後に読み込む必要あり
Plug 'ryanoasis/vim-devicons'
call plug#end()
" trigger plug_on_load event to execute function after plugin is loaded
" プラグイン読み込み後に実行する設定(on_post_source)
" 例：lexima.vim が設定するマッピングを上書きしたいため
" https://github.com/junegunn/vim-plug/issues/432
doautocmd User plug_on_load

" --------------------------------
" キーマッピング
" --------------------------------
noremap ; :
noremap : ;

" 無名レジスタをペースト
inoremap <C-^> <C-r>"
" 整形
nnoremap <Leader>f gg=<S-g><C-o><C-o>zz

" カーソルを表示行で移動する。物理行移動は<C-n>,<C-p>
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up>   gk
" 行頭・行末移動
noremap <C-a> ^
noremap <C-e> $

" inoremap <C-j> <Down>
" inoremap <C-k> <Up>
inoremap <C-b> <C-g>U<Left>
" inoremap <C-l> <C-g>U<Right>
" lexima.vimによって自動入力された括弧・引用符内にいる場合は，lexima.vimのleaveで右移動
" それ以外は<C-G>U<RIGHT>による右移動
" 以下のような，閉じ括弧を入力した際に括弧を抜ける挙動を<C-l>で実現する
"   before      input        after
"    (|)          )           ()|
inoremap <silent><C-f> <C-r>=lexima#insmode#leave(1, '<LT>C-G>U<LT>RIGHT>')<CR>
inoremap <Left>  <C-G>U<Left>
inoremap <Right> <C-G>U<Right>

" 挿入モードでの行頭，行末移動
" 日本語を含む行でinsertモードで行末移動を行うため，whichwrapから'[, ]'を除外する必要あり
inoremap <expr> <C-a> col('.') == match(getline('.'), '\S') + 1 ?
      \ repeat('<C-G>U<Left>', col('.') - 1) :
      \ (col('.') < match(getline('.'), '\S') ?
      \     repeat('<C-G>U<Right>', match(getline('.'), '\S') + 0) :
      \     repeat('<C-G>U<Left>', col('.') - 1 - match(getline('.'), '\S')))
inoremap <expr> <C-e> repeat('<C-G>U<Right>', col('$') - col('.'))

" :terminal
nnoremap <Space><S-t> :<C-u>TermCurBufPath<CR>
nnoremap <Space>t :<C-u>:botright terminal<CR>

" タブ移動
nnoremap <S-h> gT
nnoremap <S-l> gt
call submode#enter_with('tabmove', 'n', '', '<S-t>l', ':<C-u>tabmove +1<CR>')
call submode#enter_with('tabmove', 'n', '', '<S-t>h', ':<C-u>tabmove -1<CR>')
call submode#map('tabmove', 'n', '', 'l', ':<C-u>tabmove +1<CR>')
call submode#map('tabmove', 'n', '', 'h', ':<C-u>tabmove -1<CR>')

" ウィンドウサイズ
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>-')
call submode#map('winsize', 'n', '', '-', '<C-w>+')

" インクリメント・デクリメント
noremap + <C-a>
noremap - <C-x>

" インデント時に選択を解除しない
vnoremap < <gv
vnoremap > >gv

" Esc の 2 回押しでハイライトを消去
nnoremap <Esc><Esc> :<C-u>nohlsearch<CR><ESC>

" コメントアウト
nmap <C-_> <Plug>(caw:hatpos:toggle)
vmap <C-_> <Plug>(caw:hatpos:toggle)
" 現在行がインデントのみの場合は，<Plug>(caw:hatpos:comment)を実行
imap <expr><C-_> getline('.') =~# '\v^\s*$' ? "\<C-o><Plug>(caw:hatpos:comment)"
      \ : "\<C-o><Plug>(caw:hatpos:toggle)"

inoremap <expr><C-c> pumvisible() ? "\<C-e>" : "\<C-c>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

vmap , <Plug>(EasyAlign)

nmap <silent> s <Plug>(operator-replace)

nnoremap <silent> <Space>e :<C-u>NERDTreeFocus<CR>
function s:open_nerdtree() abort
  if expand('%') ==# ''
    execute "NERDTree"
  else
    execute "NERDTreeFind"
  endif
endfunction
command! OpenNerdTree call s:open_nerdtree()
nnoremap <silent> <Space>d :<C-u>OpenNerdTree<CR>

nnoremap <silent> <Space>f :<C-u>Files<CR>
nnoremap <silent> <Space>r :<C-u>FZFRelative<CR>
nnoremap <silent> <Space>b :<C-u>Buffers<CR>
nnoremap <silent> <Space>w :<C-u>Windows<CR>
nnoremap <silent> <Space>s :<C-u>FZFSession<CR>

nmap <C-k> <Plug>(asterisk-z*)
vmap <C-k> <Plug>(asterisk-z*)

map *  <Plug>(asterisk-z*)
map g* <Plug>(asterisk-gz*)
map #  <Plug>(asterisk-z#)
map g# <Plug>(asterisk-gz#)

" --------------------------------
" インデント
" --------------------------------
setglobal autoindent      " オートインデント
setglobal smartindent     " スマートインデント
setglobal cindent         " C プログラムの自動インデント
setglobal expandtab       " Tab文字を空白に展開
setglobal tabstop=2       " タブ幅
setglobal shiftwidth=2    " インデントの幅
setglobal softtabstop=-1  " Tab キー押下時に挿入される空白の量(マイナスでshiftwidthと同じ)

" システムvimrcでインデント設定が`set`で行われている場合があるため
" Vim起動時のみグローバル値に設定し直し
if has("vim_starting")
  set expandtab<
  set tabstop<
  set shiftwidth<
  set softtabstop<
endif

" --------------------------------
" ファイル別設定
" --------------------------------
augroup vimrc_filetype
  autocmd!
  autocmd FileType markdown,gitcommit setlocal tabstop=4 shiftwidth=4
  autocmd FileType tex setlocal formatexpr=""
  autocmd FileType tex let &formatprg="pandoc --from=markdown --to=latex --top-level-division=chapter"
  autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4
  autocmd FileType typescript,javascript setlocal iskeyword+=@-@
augroup END

let g:vim_indent_cont = 0

" --------------------------------
" 表示
" --------------------------------
set number " 行番号を表示
set cursorline
set cursorcolumn
set list
setglobal listchars=tab:»\ ,space:･,eol:⏎
setglobal showmatch " 括弧の対応をハイライト
setglobal showmode "現在のモードを表示
set conceallevel=0
let g:vim_json_syntax_conceal = 0
" texのconcealを無効化
let g:tex_conceal=''

" ウィンドウタイトルの保存・復元
let &t_ti .= "\e[22;0t"
let &t_te .= "\e[23;0t"

" カラー設定
syntax on " シンタックスハイライト
setglobal synmaxcol=1024
set t_Co=256 " 256色ターミナルでVimを使用する
" tmux上でvimを起動した際に余白部分の背景色が描画されないため
set t_ut=
setglobal termguicolors " ターミナルでtrue colorを使用する
if &term =~# '^screen'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
setglobal background=dark
colorscheme nouvelle-tricolor
autocmd vimrc VimEnter,WinEnter,ColorScheme * hi! link WhiteSpaceEOL Todo
autocmd vimrc VimEnter,WinEnter * match WhiteSpaceEOL /\S*\zs\s\+\ze$/
" ハイライト確認コマンド
command! VimShowHlItem echo synIDattr(synID(line("."), col("."), 1), "name")
" vim kaoriyaで、txtファイルが自動改行されてしまうバグ対応
autocmd vimrc FileType text setlocal textwidth=0


" --------------------------------
" 折り畳み
" --------------------------------
setglobal nofoldenable
setglobal foldmethod=manual

set foldtext=MyFoldText()
function! MyFoldText()
  let mark = get(split(&foldmarker, ','), 0, '')
  let line = getline(v:foldstart)
  let line_removed = substitute(split(line, mark)[0], '^\s\+', '', '')
  let indent = matchstr(line, '^\s\+', 0)

  return indent . '+ ' . line_removed
endfunction


" --------------------------------
" local設定読み込み
" --------------------------------
if filereadable(expand($HOME.'/.vimrc_local'))
  source $HOME/.vimrc_local
endif

" vim: expandtab softtabstop=-1 shiftwidth=2
