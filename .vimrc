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
setglobal ambiwidth=double           " □とか○等の文字でカーソル位置がずれないようにする
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
setglobal completeopt=menuone,noselect,noinsert
if executable('rg')
  set grepprg=rg\ -i\ --vimgrep
endif
function! s:all_grep(...)
  let orig_grepprg=&grepprg
  set grepprg=rg\ --hidden\ -i\ --vimgrep

  try
    execute ":grep! ".a:1
  finally
    let &grepprg=orig_grepprg
  endtry
endfunction
command! -nargs=? AllGrep call s:all_grep(<f-args>)

" ウィンドウ移動時に変更チェック
autocmd vimrc WinEnter,FocusGained * checktime

" htmlタグ移動
packadd matchit

" https://github.com/Shougo/dein.vim/issues/107
if isdirectory(expand('$HOME/.vim/pack/plugins/opt/vimtex'))
  packadd vimtex
endif

" 自動pasteモード
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

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


" --------------------------------
" プラグイン
" --------------------------------
call plug#begin('~/.vim/plug')

Plug 'vim-jp/vimdoc-ja'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
let g:asyncomplete_remove_duplicates = 1
let g:asyncomplete_smart_completion = 0
Plug 'prabirshrestha/vim-lsp'
let g:lsp_insert_text_enabled = 0
Plug 'prabirshrestha/asyncomplete-lsp.vim'
if executable('typescript-language-server')
  autocmd vimrc User lsp_setup call lsp#register_server({
  \ 'name': 'typescript-language-server',
  \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
  \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
  \ 'whitelist': ['typescript', 'typescript.jsx', 'javascript', 'javascript.jsx']
  \ })
endif
if executable('solargraph')
  autocmd vimrc User lsp_setup call lsp#register_server({
  \ 'name': 'solargraph',
  \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
  \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'Gemfile'))},
  \ 'whitelist': ['ruby', 'eruby'],
  \ })
endif
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-emoji.vim'
Plug 'yami-beta/asyncomplete-omni.vim'

function! s:asyncomplete_on_post_source() abort
  call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
  \ 'name': 'omni',
  \ 'whitelist': ['*'],
  \ 'blacklist': ['sql', 'ruby'],
  \ 'completor': function('asyncomplete#sources#omni#completor')
  \  }))

  call asyncomplete#register_source(asyncomplete#sources#emoji#get_source_options({
  \ 'name': 'emoji',
  \ 'whitelist': ['markdown', 'gitcommit'],
  \ 'completor': function('asyncomplete#sources#emoji#completor'),
  \ }))

  call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
  \ 'name': 'file',
  \ 'whitelist': ['*'],
  \ 'completor': function('asyncomplete#sources#file#completor')
  \ }))

  call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
  \ 'name': 'buffer',
  \ 'whitelist': ['*'],
  \ 'blacklist': ['go'],
  \ 'priority': -1,
  \ 'completor': function('asyncomplete#sources#buffer#completor'),
  \ }))
endfunction
autocmd vimrc User plug_on_load call s:asyncomplete_on_post_source()

" 補完候補の括弧、クオートを補完する
" Plug 'Shougo/neopairs.vim'

function! s:complete_done_hendler(item) abort
  if !exists('a:item') || empty(a:item)
    return
  endif

  let word = a:item.word
  let pos = getpos('.')
  let cursor_pos = pos[2] - 1
  let complete_start_pos = cursor_pos - len(word)

  let lastchar = word[len(word)-1]
  if lastchar ==# '('
    let line = getline('.')
    let pre_text = line[0:complete_start_pos - 1]
    let suf_text = line[cursor_pos:]
    call setline('.', pre_text.word.')'.suf_text)
  endif
endfunction
autocmd vimrc CompleteDone * call s:complete_done_hendler(v:completed_item)

" Plug 'rhysd/github-complete.vim'
" autocmd vimrc FileType gitcommit setl omnifunc=github_complete#complete

Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
command! -bang FZFRelative call fzf#vim#files(expand('%:p:h'), <bang>0)
Plug 'yami-beta/fzf-session.vim'

Plug 'ctrlpvim/ctrlp.vim'
" Open in current window if current window has no file
function! Ctrlp_open_handler(action, line)
  let action = a:action
  let alt_bufnr = winbufnr(winnr('#'))
  let alt_bufname = getbufinfo(alt_bufnr)[0].name
  if alt_bufname ==# '' && action == 't'
    let action = 'e'
  endif
  call ctrlp#acceptfile(action, a:line)
endfunction
let g:ctrlp_open_func = {
\ 'files': 'Ctrlp_open_handler',
\ }
let g:ctrlp_switch_buffer = 'ET'
let g:ctrlp_match_window = 'order:ttb,results:50'
let g:ctrlp_open_new_file = 'r'
" <F7>での削除を Ctrl + d に変更
let g:ctrlp_prompt_mappings = {
\ 'PrtDeleteEnt()':       ['<c-d>', '<F7>'],
\ 'ToggleByFname()':      ['<c-s>'],
\ }
" 詳細: http://leafcage.hateblo.jp/entry/2013/09/26/234707
autocmd vimrc CursorMoved ControlP let w:lightline = 0

if executable('pt')
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = 'pt %s --nocolor --nogroup --follow --hidden -g .'
elseif executable('rg')
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = 'rg %s --color never --no-heading --hidden --iglob "!.git/" --files'
elseif executable('ag')
  let g:ctrlp_use_caching=0
  let g:ctrlp_user_command='ag %s -i --nocolor --nogroup -g ""'
endif

Plug 'yami-beta/ctrlp-explorer'

Plug 'Shougo/unite.vim'
let g:unite_force_overwrite_statusline = 0

if executable('ag')
  " Use ag (the silver searcher)
  " https://github.com/ggreer/the_silver_searcher
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts =
        \ '-i --vimgrep --hidden --ignore ' .
        \ '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
  let g:unite_source_grep_recursive_opt = ''
  let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '']
endif

function! s:unite_on_source() abort
  autocmd vimrc FileType unite imap <buffer> <C-c> <Plug>(unite_insert_leave)<Plug>(unite_all_exit)
  autocmd vimrc FileType unite nmap <buffer> <C-c> <Plug>(unite_all_exit)
  autocmd vimrc FileType unite inoremap <buffer><expr><silent> <C-t> unite#do_action('tabswitch')
  autocmd vimrc FileType unite nnoremap <buffer><expr><silent> t unite#do_action('tabswitch')

  call unite#custom#profile('default', 'context', {
        \   'start_insert': 1,
        \   'winheight': 10,
        \   'prompt': '» ',
        \   'direction': 'botright',
        \   'prompt_direction': 'top',
        \ })
endfunction
autocmd vimrc User plug_on_load call s:unite_on_source()

Plug 'Shougo/unite-outline'

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
\   'left': [ [ 'mode', 'paste' ], [ 'filename' ] ]
\ },
\ 'component_function': {
\   'filename': 'LightLineFilename',
\   'fileformat': 'LightLineFileformat',
\   'filetype': 'LightLineFiletype',
\   'fileencoding': 'LightLineFileencoding',
\   'mode': 'LightLineMode'
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

Plug 'kana/vim-operator-user'
Plug 'machakann/vim-sandwich'
Plug 'kana/vim-operator-replace'
"
Plug 'kana/vim-textobj-user'
Plug 'rhysd/vim-textobj-ruby'
Plug 'kana/vim-textobj-indent'

Plug 'w0rp/ale'
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_markdown_prettier_use_global = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\ 'javascript': ['eslint', 'prettier'],
\ 'typescript': ['eslint', 'prettier'],
\ 'scss': ['prettier'],
\ 'ruby': ['rubocop']
\ }

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_fmt_command = "goimports"

Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'MaxMEllon/vim-jsx-pretty', { 'for': ['javascript', 'typescript'] }
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

Plug 'hail2u/vim-css3-syntax'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

Plug 'digitaltoad/vim-pug', { 'for': 'pug' }
Plug 'mattn/emmet-vim'
let g:user_emmet_leader_key = '<C-g>'
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
" Plug 'lervag/vimtex'

Plug 'lambdalisue/gina.vim'

" 検索・置換を便利にする
Plug 'haya14busa/vim-asterisk'
Plug 'osyo-manga/vim-anzu'
Plug 'osyo-manga/vim-over'

Plug 'cohama/lexima.vim'
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~ '\s'
endfunction
" lexima.vimはInsertEnter時に初期化されるため注意が必要
" 初期化処理はautoload/lexima.vimにあるため，lexima#add_ruleを呼んだ時点で初期化が行われる
" <CR>等のmappingは初期化処理で上書きされる
function! s:lexima_on_post_source() abort
  call lexima#add_rule({'char': '<TAB>', 'at': '\%#[)}\]''"]', 'leave': 1})
  " for todo list (e.g. `- [ ] todo`)
  call lexima#add_rule({'char': '<Space>', 'at': '\[\%#]', 'input': '<Space>', 'filetype': 'markdown'})
  " call lexima#insmode#map_hook('after', '<BS>', "\<C-r>=asyncomplete#force_refresh()\<CR>")
  " <TAB>と<CR>のマッピングを元に戻す
  imap <silent><expr><TAB> pumvisible() ? "\<C-n>"
  \ : <SID>check_back_space() ? lexima#expand('<LT>TAB>', 'i')
  \ : asyncomplete#force_refresh()
  imap <silent><expr><CR> pumvisible() ? "\<C-y>"
  \ : lexima#expand('<LT>CR>', 'i')
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
nnoremap <silent> <Space>d :<C-u>NERDTreeFind<CR>

nnoremap <silent> <Space>f :<C-u>Files<CR>
nnoremap <silent> <Space>r :<C-u>FZFRelative<CR>
nnoremap <silent> <Space>b :<C-u>Buffers<CR>
nnoremap <silent> <Space>w :<C-u>Windows<CR>
nnoremap <silent> <Space>s :<C-u>FZFSession<CR>

nnoremap <silent> <Space>o :<C-u>Unite outline -direction=botright -vertical -winwidth=40<CR>

nmap <C-k> <Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
vmap <C-k> <Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)

nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
map *  <Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
map g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)
map #  <Plug>(asterisk-z#)
map g# <Plug>(asterisk-gz#)

nnoremap <silent> <Space>m :OverCommandLine %s/\v<CR>
vnoremap <silent> <Space>m :OverCommandLine s/\v<CR>


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
