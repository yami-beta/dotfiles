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
setglobal mouse=a                    " 全モードでマウスを有効化
setglobal ttymouse=xterm2
setglobal iskeyword+=-               " '-'を単語区切りに追加
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
setglobal sessionoptions-=black
setglobal laststatus=2
setglobal showtabline=2              " tablineを常時表示
setglobal guioptions-=e              " tablineをCUIで表示
setglobal wildmenu                   " コマンドラインモードでの補完を有効に
setglobal wildchar=<tab>             " コマンド補完を開始するキー
setglobal history=1000               " コマンド・検索パターンの履歴数
setglobal wildmode=list:longest,full
setglobal wildignorecase
setglobal completeopt=menuone,noselect,noinsert

" ウィンドウ移動時に変更チェック
autocmd vimrc WinEnter * checktime

" htmlタグ移動
packadd matchit

" https://github.com/Shougo/dein.vim/issues/107
if isdirectory(expand('$HOME/.vim/pack/plugins/opt/vimtex'))
  packadd vimtex
endif

" 自動pasteモード
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

if s:is_mac
  " ターミナルでカーソル形状変更
  let &t_SI .= WrapForTmux("\<Esc>]50;CursorShape=1\x7")
  let &t_SR .= WrapForTmux("\<Esc>]50;CursorShape=2\x7")
  let &t_EI .= WrapForTmux("\<Esc>]50;CursorShape=0\x7")
endif


" --------------------------------
" セッションの自動保存
" --------------------------------
augroup SessionAutoCommands
  autocmd!
  " autocmd VimLeave * execute ':mks! Session.vim'
  autocmd VimEnter * nested call <SID>RestoreSessionWithConfirm()
augroup END
" command! SSave :mks! Session.vim

function! s:RestoreSessionWithConfirm()
  let msg = 'Do you want to restore previous session?'

  if !argc() && filereadable('Session.vim') && confirm(msg, "&Yes\n&No", 1, 'Question') == 1
    execute ':source Session.vim'
  endif
endfunction


" --------------------------------
" プラグイン
" --------------------------------
call plug#begin('~/.vim/plug')

Plug 'Shougo/neocomplete.vim'
" Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions'
      \ }
  

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h[[:alnum:]_:-]*'
let g:neocomplete#keyword_patterns['javascript'] = '\h[[:alnum:]_:-]*'

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'rhysd/github-complete.vim'
autocmd vimrc FileType gitcommit setl omnifunc=github_complete#complete

Plug 'ctrlpvim/ctrlp.vim'
function! Ctrlp_open_handler(action, line)
  let action = a:action
  let alternate_bufnr = winbufnr(winnr('#'))
  let altername_bufname = getbufinfo(alternate_bufnr)[0].name
  echomsg altername_bufname
  if altername_bufname ==# '' && action == 't'
    let action = 'e'
  endif

  call ctrlp#acceptfile(action, a:line)
endfunction
let g:ctrlp_open_func = {
  \ 'files'     : 'Ctrlp_open_handler',
  \ }
let g:ctrlp_switch_buffer = 'ET'
let g:ctrlp_path_nolim = 1
let g:ctrlp_open_new_file = 't'
" <F7>での削除を Ctrl + d に変更
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>', '<2-LeftMouse>'],
    \ 'AcceptSelection("t")': ['<cr>'],
    \ 'PrtDeleteEnt()':       ['<c-d>', '<F7>'],
    \ 'ToggleByFname()':      ['<c-s>'],
    \ }
" 詳細: https://github.com/ctrlpvim/ctrlp.vim/issues/196
let g:ctrlp_abbrev = {
      \   'gmode': 'i',
      \   'abbrevs': [
      \     {
      \       'pattern': '\(^@.\+\|\\\@<!:.\+\)\@<! ',
      \       'expanded': '',
      \       'mode': 'pfrz',
      \     },
      \   ]
      \ }
" 詳細: http://leafcage.hateblo.jp/entry/2013/09/26/234707
autocmd vimrc CursorMoved ControlP let w:lightline = 0

if executable('pt')
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = 'pt %s --nocolor --nogroup --follow --hidden -g .'
elseif executable('ag')
  let g:ctrlp_use_caching=0
  let g:ctrlp_user_command='ag %s -i --nocolor --nogroup -g ""'
endif

Plug 'yami-beta/ctrlp-explorer'
Plug 'yami-beta/ctrlp-session'
Plug 'yami-beta/ctrlp-tabpage'
" Plug 'tacahiroy/ctrlp-funky'

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

  call unite#custom#default_action('file, buffer', 'tabswitch')
  call unite#custom#profile('default', 'context', {
        \   'start_insert': 1,
        \   'winheight': 10,
        \   'prompt': '» ',
        \   'direction': 'botright',
        \   'prompt_direction': 'top',
        \ })
  call unite#custom#source('file, file_rec/async, file_rec/git', 'converters', ['converter_simplify_file_directory'])
  call unite#custom#source('file', 'white_globs', ['..'])
  call unite#custom#source('file_rec,file_rec/async', 'sorters', ['sorter_word'])
  call unite#custom#source('file_rec,file_rec/async', 'ignore_pattern', join([
        \ '\.\(git\|svn\|vagrant\)\/', 
        \ 'tmp\/',
        \ 'app\/storage\/',
        \ 'bower_components\/',
        \ 'fonts\/',
        \ 'sass-cache\/',
        \ 'node_modules\/',
        \ 'vendor/bundle\/',
        \ '.bundle\/',
        \ '\.\(jpe?g\|gif\|png\)$',
        \ ], 
        \ '\|'))
endfunction
autocmd vimrc User plug_on_load call s:unite_on_source()

function! AutoSelectUniteFileRec()
  if isdirectory(getcwd().'/.git')
    Unite -start-insert file_rec/git
  else
    Unite -start-insert file_rec/async
  endif
endfunction

Plug 'yami-beta/unite-filters'
Plug 'Shougo/unite-outline'
Plug 'Shougo/neomru.vim'
Plug 'Shougo/vimfiler.vim'
let g:vimfiler_edit_action = 'tabopen'
let g:vimfiler_as_default_explorer = 1

" 見た目
Plug 'flazz/vim-colorschemes'
Plug 'yami-beta/vim-colors-yuzu'
" Plug 'ap/vim-buftabline'
Plug 'osyo-manga/vim-brightest'
let g:brightest#highlight = { "group": "BrightestUnderline" }

Plug 'yami-beta/vim-responsive-tabline'
Plug 'itchyny/lightline.vim'
let g:lightline = {
      \ 'colorscheme': 'yuzu',
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
      \ 'enable': { 'tabline': 0 }
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
        \  &ft == 'unite' ? MyUniteGetStatusString() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:.') ? expand('%:.') : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
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

function! MyUniteGetStatusString() abort
  if !exists('b:unite')
    return ''
  endif

  return unite#view#_get_status_plane_string()
        \ . ' | '. s:unite_get_status_tail_string()
endfunction

function! s:unite_get_status_tail_string() abort
  if !exists('b:unite')
    return ''
  endif

  return b:unite.context.path != '' ? '['. simplify(b:unite.context.path) .']' :
        \    (get(b:unite.msgs, 0, '') == '') ? '' :
        \    substitute(get(b:unite.msgs, 0, ''), '^\[.\{-}\]\s*', '', '')
endfunction

" Plug 'lilydjwg/colorizer'

Plug 'kana/vim-submode'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'junegunn/vim-easy-align'
Plug 'tyru/caw.vim'

Plug 'kana/vim-operator-user'
Plug 'machakann/vim-sandwich'
Plug 'kana/vim-operator-replace'
"
Plug 'kana/vim-textobj-user'
Plug 'rhysd/vim-textobj-ruby'
Plug 'kana/vim-textobj-indent'

Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'mattn/emmet-vim'
let g:user_emmet_leader_key = '<C-g>'
let g:user_emmet_settings = {
      \   'variables': {
      \     'lang': 'ja'
      \   }
      \ }

Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled=1

" Plug 'kannokanno/previm'
" if s:is_mac
"   let g:previm_open_cmd = 'open -a Google\ Chrome'
" elseif s:is_windows
"   let g:previm_open_cmd = 'C:/Program\ Files\ (x86)/Google/Chrome/Application/chrome.exe'
" endif

Plug 'elzr/vim-json'
" Plug 'lervag/vimtex'
" if !exists('g:neocomplete#sources#omni#input_patterns')
"   let g:neocomplete#sources#omni#input_patterns = {}
" endif
"
" let g:neocomplete#sources#omni#input_patterns.tex = '\v\\\a*(ref|cite)\a*([^]]*\])?\{([^}]*,)*[^}]*'

Plug 'evanmiller/nginx-vim-syntax'

" 検索・置換を便利にする
Plug 'tpope/vim-abolish'
Plug 'haya14busa/incsearch.vim'
let g:incsearch#auto_nohlsearch = 1
let g:incsearch#magic = '\v'

Plug 'haya14busa/incsearch-migemo.vim'
Plug 'haya14busa/vim-asterisk'
Plug 'osyo-manga/vim-anzu'
Plug 'osyo-manga/vim-over'

Plug 'cohama/lexima.vim'
let g:lexima_enable_space_rules = 0
" lexima.vimはInsertEnter時に初期化されるため注意が必要
" 初期化処理はautoload/lexima.vimにあるため，lexima#add_ruleを呼んだ時点で初期化が行われる
" <CR>等のmappingは初期化処理で上書きされる
function! s:lexima_on_post_source() abort
  call lexima#add_rule({'char': '<TAB>', 'at': '\%#[)}\]''"]', 'leave': 1})
  call lexima#insmode#map_hook('before', '<CR>', "\<C-r>=neocomplete#close_popup()\<CR>")
  call lexima#insmode#map_hook('before', '<BS>', "\<C-r>=neocomplete#smart_close_popup()\<CR>")
  " <TAB>と<CR>のマッピングを元に戻す
  imap <expr><TAB> pumvisible() ?
        \ "\<C-n>"
        \ : neosnippet#jumpable() ?
        \ "\<Plug>(neosnippet_jump)"
        \ : lexima#expand('<LT>TAB>', 'i')
  imap <silent><expr> <CR> !pumvisible() ? lexima#expand('<LT>CR>', 'i') :
        \ neosnippet#expandable() ? "\<Plug>(neosnippet_expand)" :
        \ neocomplete#close_popup()
endfunction
autocmd vimrc User plug_on_load call s:lexima_on_post_source()

" vimproc
let g:vimproc#download_windows_dll = 1
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'thinca/vim-quickrun'
let g:quickrun_config = {
      \ "_": {
      \   "outputter/buffer/split" : ":botright",
      \   "outputter/buffer/close_on_empty" : 1, 
      \   "runner": "job",
      \ },
      \ }

" Plug 'osyo-manga/shabadou.vim'
" Plug 'osyo-manga/vim-watchdogs'
" let g:watchdogs_check_BufWritePost_enable = 1
" let g:watchdogs_check_CursorHold_enable = 0
" if !exists("g:quickrun_config")
"   let g:quickrun_config = {}
" endif
" let g:quickrun_config['watchdogs_checker/_'] = {
"       \   'outputter/quickfix/open_cmd' : '',
"       \   'hook/close_quickfix/enable_exit': 1,
"       \ }
" if executable('eslint')
"   let g:quickrun_config['javascript/watchdogs_checker'] = {
"         \   'type': 'watchdogs_checker/eslint',
"         \ }
"   let g:quickrun_config['javascript.jsx/watchdogs_checker'] = {
"         \   'type': 'watchdogs_checker/eslint',
"         \ }
" endif
"
" Plug 'KazuakiM/vim-qfsigns'
" let g:qfsigns#AutoJump = 0
" let g:quickrun_config['watchdogs_checker/_']['hook/qfsigns_update/enable_exit'] = 1
" let g:quickrun_config['watchdogs_checker/_']['hook/qfsigns_update/priority_exit'] = 1

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

inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <C-g>U<Left>
" inoremap <C-l> <C-g>U<Right>
" lexima.vimによって自動入力された括弧・引用符内にいる場合は，lexima.vimのleaveで右移動
" それ以外は<C-G>U<RIGHT>による右移動
" 以下のような，閉じ括弧を入力した際に括弧を抜ける挙動を<C-l>で実現する
"   before      input        after
"    (|)          )           ()|
inoremap <C-l> <C-r>=lexima#insmode#leave(1, '<LT>C-G>U<LT>RIGHT>')<CR>
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

" 行ごと移動
vnoremap <S-Up> "zx<Up>"zP`[V`]
vnoremap <S-Down> "zx"zp`[V`]

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

inoremap <expr><C-g>     neocomplete#undo_completion()
" inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplete#close_popup()
" inoremap <expr><C-e> pumvisible() ? neocomplete#cancel_popup() : "\<End>"
inoremap <expr><C-c> pumvisible() ? neocomplete#cancel_popup() : "\<C-c>"

xmap <Tab>     <Plug>(neosnippet_expand_target)
smap <expr><TAB> pumvisible() ?
      \ "\<C-n>"
      \ : neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \ : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

imap <expr><C-s> !pumvisible() ?
      \ "\<C-s>"
      \ : "\<Plug>(neosnippet_expand_or_jump)"
smap <expr><C-s> !pumvisible() ?
      \ "\<C-s>"
      \ : "\<Plug>(neosnippet_expand_or_jump)"

vmap , <Plug>(EasyAlign)

nmap <silent> <Leader>r <Plug>(operator-replace)

" nnoremap <Space>o :<C-u>CtrlPFunky<CR>
" nnoremap <Space>f :<C-u>CtrlPExplorer<CR>
nnoremap <silent> <Space>f :<C-u>CtrlPExplorerWithBufDir<CR>
nnoremap <silent> <Space>s :<C-u>CtrlPSession<CR>
nnoremap <silent> <Space>b :<C-u>CtrlPBuffer<CR>
nnoremap <silent> <Space>t :<C-u>CtrlPTabpage<CR>

nnoremap <silent> <Space>u :<C-u>UniteWithBufferDir -multi-line file file/new<CR>
nnoremap <silent> <Space><C-u> :<C-u>Unite file file/new<CR>
nnoremap <silent> <Space>i :<C-u>call AutoSelectUniteFileRec()<CR>
" nnoremap <silent> <Space>i :<C-u>Unite file_rec/async<CR>
" nnoremap <silent> <Space>b :<C-u>Unite buffer -force-redraw<CR>
" nnoremap <silent> <Space>t :<C-u>Unite tab -force-redraw<CR>
nnoremap <silent> <Space>o :<C-u>Unite outline -direction=botright -vertical -winwidth=40<CR>
" nnoremap <silent> <Space>s :<C-u>Unite session<CR>
nnoremap <silent> <Space>r :<C-u>Unite file_mru<CR>
nnoremap <silent> <Space>g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent> <Space>gd :<C-u>Unite grep -buffer-name=search-buffer<CR>
nnoremap <silent> <Space>gr :<C-u>UniteResume search-buffer<CR>

nnoremap <silent> <Space>d :<C-u>VimFilerExplorer -toggle -winwidth=30<CR>

nmap <C-k> <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
vmap <C-k> <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
autocmd vimrc FileType qf nnoremap <buffer><CR> <CR>

noremap <Leader>/ /

map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
nmap n <Plug>(incsearch-nohl)<Plug>(anzu-n-with-echo)
nmap N <Plug>(incsearch-nohl)<Plug>(anzu-N-with-echo)
map *  <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
map g* <Plug>(incsearch-nohl0)<Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)
map #  <Plug>(incsearch-nohl0)<Plug>(asterisk-z#)
map g# <Plug>(incsearch-nohl0)<Plug>(asterisk-gz#)

map m/ <Plug>(incsearch-migemo-/)
map m? <Plug>(incsearch-migemo-?)
map mg/ <Plug>(incsearch-migemo-stay)

nnoremap <silent> <Space>m :OverCommandLine %s/\v<CR>
vnoremap <silent> <Space>m :OverCommandLine s/\v<CR>


" --------------------------------
" インデント
" --------------------------------
setglobal autoindent      " オートインデント
setglobal smartindent     " スマートインデント
setglobal cindent         " C プログラムの自動インデント
setglobal expandtab       " Tab文字を空白に展開
setglobal tabstop=4       " タブ幅
setglobal shiftwidth=4    " インデントの幅
setglobal softtabstop=-1  " Tab キー押下時に挿入される空白の量(マイナスでshiftwidthと同じ)


" --------------------------------
" ファイル別設定
" --------------------------------
augroup vimrc_filetype
  autocmd!
  autocmd FileType ruby,eruby setlocal tabstop=2 shiftwidth=2
  autocmd FileType vim        setlocal tabstop=2 shiftwidth=2
  autocmd FileType tex        setlocal formatexpr=""
  autocmd FileType tex        let &formatprg="pandoc --from=markdown --to=latex --top-level-division=chapter"
  autocmd FileType tex        setlocal tabstop=2 shiftwidth=2
  autocmd FileType html       setlocal tabstop=2 shiftwidth=2
  autocmd FileType css,scss   setlocal tabstop=2 shiftwidth=2
  autocmd FileType javascript setlocal tabstop=2 shiftwidth=2
augroup END


" --------------------------------
" 表示
" --------------------------------
set number " 行番号を表示
set cursorline
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
setglobal t_Co=256 " 256色ターミナルでVimを使用する
" tmux上でvimを起動した際に余白部分の背景色が描画されないため
set t_ut=
setglobal termguicolors " ターミナルでtrue colorを使用する
if &term =~# '^screen'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
setglobal background=dark
colorscheme yuzu
" ハイライト確認コマンド
command! VimShowHlItem echo synIDattr(synID(line("."), col("."), 1), "name")
" vim kaoriyaで、txtファイルが自動改行されてしまうバグ対応
autocmd vimrc FileType text setlocal textwidth=0


" --------------------------------
" 折り畳み
" --------------------------------
setglobal foldlevel=100
setglobal foldmethod=indent

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
