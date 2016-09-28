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
setglobal sessionoptions-=options
setglobal laststatus=2
setglobal showtabline=2              " tablineを常時表示
setglobal guioptions-=e              " tablineをCUIで表示
setglobal wildmenu                   " コマンドラインモードでの補完を有効に
setglobal wildchar=<tab>             " コマンド補完を開始するキー
setglobal history=1000               " コマンド・検索パターンの履歴数
setglobal wildmode=list:longest,full
setglobal wildignorecase
setglobal completeopt=menuone,noselect,noinsert

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
if &compatible
  set nocompatible
endif
set runtimepath^=~/.cache/dein/repos/github.com/Shougo/dein.vim
autocmd vimrc VimEnter * call dein#call_hook('post_source')
let g:dein#install_progress_type='echo'

call dein#begin(expand('~/.cache/dein'))

call dein#add('Shougo/dein.vim')
call dein#add('Shougo/neocomplete.vim', { 'on_i': 1 })
if dein#tap('neocomplete.vim') "{{{2
  function! s:neocomplete_on_source() abort
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
  endfunction
  call dein#config({
        \ 'hook_source': function('s:neocomplete_on_source')
        \ })

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
endif "}}}
call dein#add('Shougo/neosnippet.vim', { 'depends': ['neocomplete.vim'] })
call dein#add('Shougo/neosnippet-snippets', { 'depends': ['neosnippet.vim'] })
call dein#add('rhysd/github-complete.vim')
if dein#tap('github-complete.vim') "{{{2
  autocmd vimrc FileType gitcommit setl omnifunc=github_complete#complete
endif "}}}

call dein#add('ctrlpvim/ctrlp.vim')
if dein#tap('ctrlp.vim') "{{{2
  let g:ctrlp_switch_buffer = 'ET'
  let g:ctrlp_path_nolim = 1
  let g:ctrlp_open_new_file = 't'
  " <F7>での削除を Shift + d に変更
  let g:ctrlp_prompt_mappings = {
      \ 'PrtDeleteEnt()':       ['<S-d>'],
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

  let g:ctrlp_funky_syntax_highlight = 1
  let g:ctrlp_funky_nolim = 1
endif "}}}
call dein#add('yami-beta/ctrlp-explorer')
call dein#add('yami-beta/ctrlp-session')
call dein#add('DeaR/ctrlp-tabpage')
" call dein#add('tacahiroy/ctrlp-funky')

call dein#add('Shougo/unite.vim', { 'depends': ['vimproc.vim'], 'lazy': 1 })
if dein#tap('unite.vim') "{{{2 
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
  call dein#config({'hook_source': function('s:unite_on_source')})

  function! AutoSelectUniteFileRec()
    if isdirectory(getcwd().'/.git')
      Unite -start-insert file_rec/git
    else
      Unite -start-insert file_rec/async
    endif
  endfunction
endif "}}}
call dein#add('yami-beta/unite-filters')
call dein#add('Shougo/unite-outline')
" call dein#add('Shougo/unite-session')
if dein#tap('unite-session') "{{{2
  let g:unite_source_session_path = $HOME . '/.vim/session'
  command! -nargs=? -complete=customlist,unite#sources#session#_complete
        \ SSave call s:unite_session_save(<q-args>)
  function! s:unite_session_save(filename, ...)
    if unite#util#is_cmdwin()
      return
    endif

    if !isdirectory(g:unite_source_session_path)
      call mkdir(g:unite_source_session_path, 'p')
    endif

    let filename = s:get_session_path(a:filename)

    " Check if this overrides an existing session
    if filereadable(filename) && a:0 && a:1
      call unite#print_error('Session already exists.')
      return
    endif

    execute 'silent mksession!' filename
  endfunction
  function! s:get_session_path(filename)
    let filename = a:filename
    if filename == ''
      let filename = v:this_session
    endif
    if filename == ''
      let filename = g:unite_source_session_default_session_name
    endif

    let filename = unite#util#substitute_path_separator(filename)

    if filename !~ '.vim$'
      let filename .= '.vim'
    endif

    if filename !~ '^\%(/\|\a\+:/\)'
      " Relative path.
      let filename = g:unite_source_session_path . '/' . filename
    endif

    return filename
  endfunction
endif "}}}
call dein#add('Shougo/neomru.vim', { 'depends': ['unite.vim'] })
call dein#add('Shougo/vimfiler.vim', { 'on_cmd': ['VimFiler'] })
if dein#tap('vimfiler.vim') "{{{2
  let g:vimfiler_edit_action = 'tabopen'
  let g:vimfiler_as_default_explorer = 1
endif "}}}

" 見た目
call dein#add('flazz/vim-colorschemes')
call dein#add('yami-beta/vim-colors-ruri')
" call dein#add('ap/vim-buftabline')
call dein#add('itchyny/lightline.vim')
if dein#tap('lightline.vim') "{{{2
  let g:lightline = {
        \ 'colorscheme': 'ruri',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'filename': 'LightLineFilename',
        \   'fileformat': 'LightLineFileformat',
        \   'filetype': 'LightLineFiletype',
        \   'fileencoding': 'LightLineFileencoding',
	      \   'mode': 'LightLineMode'
        \ }
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
endif "}}}
" call dein#add('lilydjwg/colorizer')

call dein#add('kana/vim-submode')
call dein#add('AndrewRadev/splitjoin.vim')
call dein#add('junegunn/vim-easy-align')
call dein#add('tyru/caw.vim')

call dein#add('kana/vim-operator-user')
call dein#add('machakann/vim-sandwich')
call dein#add('kana/vim-operator-replace', {'depends': ['vim-operator-user']})
"
call dein#add('kana/vim-textobj-user')
call dein#add('rhysd/vim-textobj-ruby', {'depends': ['vim-textobj-user']})
call dein#add('kana/vim-textobj-indent', {'depends': ['vim-textobj-user']})

call dein#add('othree/yajs.vim')
call dein#add('maxmellon/vim-jsx-pretty')
call dein#add('mattn/emmet-vim', { 'on_i': 1 })
if dein#tap('emmet-vim') "{{{2
  let g:user_emmet_leader_key = '<C-g>'
  let g:user_emmet_settings = {
        \   'variables': {
        \     'lang': 'ja'
        \   }
        \ }
endif "}}}
call dein#add('plasticboy/vim-markdown')
if dein#tap('vim-markdown') "{{{2
  let g:vim_markdown_folding_disabled=1
endif "}}}
" call dein#add('kannokanno/previm')
if dein#tap('previm') " {{{2
  if s:is_mac
    let g:previm_open_cmd = 'open -a Google\ Chrome'
  elseif s:is_windows
    let g:previm_open_cmd = 'C:/Program\ Files\ (x86)/Google/Chrome/Application/chrome.exe'
  endif
endif " }}}
call dein#add('elzr/vim-json')
" call dein#add('lervag/vimtex')
if dein#tap('vimtex') "{{{2
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif

  let g:neocomplete#sources#omni#input_patterns.tex = '\v\\\a*(ref|cite)\a*([^]]*\])?\{([^}]*,)*[^}]*'
endif "}}}
call dein#add('evanmiller/nginx-vim-syntax')

" 検索・置換を便利にする
call dein#add('tpope/vim-abolish')
call dein#add('haya14busa/incsearch.vim')
if dein#tap('incsearch.vim') "{{{2
  let g:incsearch#auto_nohlsearch = 1
  let g:incsearch#magic = '\v'
endif "}}}
call dein#add('haya14busa/incsearch-migemo.vim', { 'depends': ['incsearch.vim'] })
call dein#add('haya14busa/vim-asterisk')
call dein#add('osyo-manga/vim-anzu')
call dein#add('osyo-manga/vim-over', { 'on_cmd': ['OverCommandLine'] })

call dein#add('cohama/lexima.vim')
if dein#tap('lexima.vim') "{{{2
  let g:lexima_enable_space_rules = 0
  " lexima.vimはInsertEnter時に初期化されるため注意が必要
  " 初期化処理はautoload/lexima.vimにあるため，lexima#add_ruleを呼んだ時点で初期化が行われる
  " <CR>等のmappingは初期化処理で上書きされる
  function! s:lexima_mapping() abort
    imap <expr><TAB> pumvisible() ?
          \ "\<C-n>"
          \ : neosnippet#expandable_or_jumpable() ?
          \ "\<Plug>(neosnippet_expand_or_jump)"
          \ : lexima#expand('<LT>TAB>', 'i')
    imap <silent><expr> <CR> !pumvisible() ? lexima#expand('<LT>CR>', 'i') :
          \ neosnippet#expandable() ? "\<Plug>(neosnippet_expand)" :
          \ neocomplete#close_popup()
  endfunction
  function! s:lexima_on_post_source() abort
    call lexima#add_rule({'char': '<TAB>', 'at': '\%#[)}\]''"]', 'leave': 1})
    call lexima#insmode#map_hook('before', '<CR>', "\<C-r>=neocomplete#close_popup()\<CR>")
    call lexima#insmode#map_hook('before', '<BS>', "\<C-r>=neocomplete#smart_close_popup()\<CR>")
    " <TAB>と<CR>のマッピングを元に戻す
    call s:lexima_mapping()
  endfunction
  call dein#config({
        \ 'hook_post_source': function('s:lexima_on_post_source')
        \ })
endif "}}}

" vimproc
let g:vimproc#download_windows_dll = 1
call dein#add('Shougo/vimproc.vim', { 'build' : 'make' })
call dein#add('thinca/vim-quickrun')
if dein#tap('vim-quickrun') "{{{2
  let g:quickrun_config = {
        \ "_": {
        \   "outputter/buffer/split" : ":botright",
        \   "outputter/buffer/close_on_empty" : 1, 
        \   "runner": "vimproc",
        \   "runner/vimproc/updatetime": 60,
        \ },
        \ }
endif
" }}}
call dein#add('osyo-manga/shabadou.vim')
call dein#add('osyo-manga/vim-watchdogs')
if dein#tap('vim-watchdogs') " {{{2
  let g:watchdogs_check_BufWritePost_enable = 1
  let g:watchdogs_check_CursorHold_enable = 0
  if !exists("g:quickrun_config")
    let g:quickrun_config = {}
  endif
  let g:quickrun_config['watchdogs_checker/_'] = {
        \   'outputter/quickfix/open_cmd' : '',
        \   'hook/close_quickfix/enable_exit': 1,
        \ }
  if executable('eslint')
    let g:quickrun_config['javascript/watchdogs_checker'] = {
          \   'type': 'watchdogs_checker/eslint',
          \ }
  endif
endif " }}}
call dein#add('KazuakiM/vim-qfsigns')
if dein#tap('vim-qfsigns') "{{{2
  let g:qfsigns#AutoJump = 0
  let g:quickrun_config['watchdogs_checker/_']['hook/qfsigns_update/enable_exit'] = 1
  let g:quickrun_config['watchdogs_checker/_']['hook/qfsigns_update/priority_exit'] = 1
endif " }}}

call dein#end()
filetype plugin indent on


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
inoremap <C-l> <C-g>U<Right>
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
if dein#tap('vim-submode')
  call submode#enter_with('tabmove', 'n', '', '<S-t>l', ':<C-u>tabmove +1<CR>')
  call submode#enter_with('tabmove', 'n', '', '<S-t>h', ':<C-u>tabmove -1<CR>')
  call submode#map('tabmove', 'n', '', 'l', ':<C-u>tabmove +1<CR>')
  call submode#map('tabmove', 'n', '', 'h', ':<C-u>tabmove -1<CR>')
endif

" ウィンドウサイズ
if dein#tap('vim-submode')
  call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
  call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
  call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
  call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
  call submode#map('winsize', 'n', '', '>', '<C-w>>')
  call submode#map('winsize', 'n', '', '<', '<C-w><')
  call submode#map('winsize', 'n', '', '+', '<C-w>-')
  call submode#map('winsize', 'n', '', '-', '<C-w>+')
endif

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

call s:lexima_mapping()

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

nmap <CR> <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
vmap <CR> <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
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


" ------------
" インデント
" ------------
setglobal autoindent      " オートインデント
setglobal smartindent     " スマートインデント
setglobal cindent         " C プログラムの自動インデント
setglobal expandtab       " Tab文字を空白に展開
setglobal tabstop=4       " タブ幅
setglobal shiftwidth=4    " インデントの幅
setglobal softtabstop=-1  " Tab キー押下時に挿入される空白の量(マイナスでshiftwidthと同じ)

" ------------
" ファイル別設定
" ------------
augroup vimrc_filetype
  autocmd!
  autocmd FileType ruby,eruby setlocal tabstop=2 shiftwidth=2
  autocmd FileType vim        setlocal tabstop=2 shiftwidth=2
  autocmd FileType tex        setlocal tabstop=2 shiftwidth=2
  autocmd FileType html       setlocal tabstop=2 shiftwidth=2
  autocmd FileType css,scss   setlocal tabstop=2 shiftwidth=2
  autocmd FileType javascript setlocal tabstop=2 shiftwidth=2
augroup END


" ------------
" 表示
" ------------
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
setglobal background=dark
colorscheme ruri
" ハイライト確認コマンド
command! VimShowHlItem echo synIDattr(synID(line("."), col("."), 1), "name")
" vim kaoriyaで、txtファイルが自動改行されてしまうバグ対応
autocmd vimrc FileType text setlocal textwidth=0


" ------------
" 折り畳み
" ------------
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


" ------------
" local設定読み込み
" ------------
if filereadable(expand($HOME.'/.vimrc_local'))
  source $HOME/.vimrc_local
endif

" vim: expandtab softtabstop=-1 shiftwidth=2
