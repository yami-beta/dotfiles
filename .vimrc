set encoding=utf-8
scriptencoding utf-8

" 初期化 "{{{1
augroup vimrc
  autocmd!
augroup END

let s:is_windows = has('win32') || has('win64')
let s:is_mac = has('mac') || system('uname') =~? '^darwin'
let s:is_linux = !s:is_mac && has('unix')

" 基本設定 "{{{1
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
setglobal backspace=indent,eol,start " BSで，インデント・改行の削除，挿入モード開始位置での削除を有効
setglobal whichwrap=b,s,h,l,<,>,[,]  " カーソルを行頭、行末で止まらないようにする
setglobal hidden                     " 未保存状態でバッファの切り替えを可能にする
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
setglobal completeopt=menu,menuone

" htmlタグ移動
source $VIMRUNTIME/macros/matchit.vim

" vimproc
let g:vimproc#download_windows_dll = 1

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

" セッションの自動保存 "{{{1
augroup SessionAutoCommands
  autocmd!
  " autocmd VimLeave * execute ':mks! Session.vim'
  autocmd VimEnter * nested call <SID>RestoreSessionWithConfirm()
augroup END
command! SSave :mks! Session.vim

function! s:RestoreSessionWithConfirm()
  let msg = 'Do you want to restore previous session?'

  if !argc() && filereadable('Session.vim') && confirm(msg, "&Yes\n&No", 1, 'Question') == 1
    execute ':source Session.vim'
  endif
endfunction


" プラグイン "{{{1
if &compatible
  set nocompatible
endif
set runtimepath^=~/.vim/bundle/repos/github.com/Shougo/dein.vim
autocmd vimrc VimEnter * call dein#call_hook('post_source')

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
  execute 'autocmd vimrc User' 'dein#source#'.g:dein#name 'call s:neocomplete_on_source()'

  function! s:my_cr_function()
    " return neocomplete#close_popup() . "\<CR>"
    " For no inserting <CR> key.
    return pumvisible() ? neocomplete#close_popup() : "\<CR>"
  endfunction
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
if dein#tap('neosnippet.vim') "{{{2
  " For snippet_complete marker.
  if has('conceal')
    set conceallevel=2 concealcursor=niv
  endif
endif "}}}
call dein#add('Shougo/neosnippet-snippets', { 'depends': ['neosnippet.vim'] })
call dein#add('tpope/vim-fugitive')
" call dein#add('ctrlpvim/ctrlp.vim')
if dein#tap('ctrlp.vim') "{{{2
  let g:ctrlp_switch_buffer = 'ET'
  let g:ctrlp_path_nolim = 1
  let g:ctrlp_open_new_file = 't'

  function! s:ctrlp_filer_glob_func(path)
    return map([".."] + glob(a:path . "/*", 0, 1) + glob(a:path . "/.??*", 0, 1), 'fnamemodify(v:val, ":t") . (isdirectory(v:val) ? "/" : "")')
  endfunction
  let g:Ctrlp_filer_glob_func = function('s:ctrlp_filer_glob_func')

  if executable('pt')
    let g:ctrlp_use_caching = 0
    let g:ctrlp_user_command = 'pt %s --nocolor --nogroup -g .'
  endif

  let g:ctrlp_funky_syntax_highlight = 1
  let g:ctrlp_funky_nolim = 1
endif "}}}
" call dein#add('tacahiroy/ctrlp-funky')
" call dein#add('yami-beta/ctrlp-filer', { 'rev' : 'personal' })
" call dein#add('mhinz/vim-startify')

" call neobundle#local("~/develop",
"       \   {}, ['ctrlp-filer'])

" 見た目
call dein#add('flazz/vim-colorschemes')
" call dein#add('zsoltf/vim-maui')
" call dein#add('machakann/vim-colorscheme-imas')
" call dein#add('ap/vim-buftabline')
call dein#add('itchyny/lightline.vim')
if dein#tap('lightline.vim') "{{{2
  let g:lightline = {
        \ 'colorscheme': 'pencil_dark',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'modified': 'MyModified',
        \   'readonly': 'MyReadonly',
        \   'fugitive': 'MyFugitive',
        \   'filename': 'MyFilename',
        \   'fileformat': 'MyFileformat',
        \   'filetype': 'MyFiletype',
        \   'fileencoding': 'MyFileencoding',
        \   'mode': 'MyMode',
        \ },
        \ }

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

  function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
  endfunction

  function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
  endfunction

  function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
          \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
          \  &ft == 'unite' ? MyUniteGetStatusString() :
          \  &ft == 'vimshell' ? vimshell#get_status_string() :
          \ '' != expand('%:.') ? expand('%:.') : '[No Name]') .
          \ ('' != MyModified() ? ' ' . MyModified() : '')
  endfunction

  function! MyFugitive()
    try
      if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
        return fugitive#head()
      endif
    catch
    endtry
    return ''
  endfunction

  function! MyFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
  endfunction

  function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
  endfunction

  function! MyFileencoding()
    return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
  endfunction

  function! MyMode()
    return  &ft == 'unite' ? 'Unite' :
          \ &ft == 'vimfiler' ? 'VimFiler' :
          \ &ft == 'vimshell' ? 'VimShell' :
          \ winwidth(0) > 60 ? lightline#mode() : ''
  endfunction
endif "}}}
call dein#add('yami-beta/lightline-pencil.vim')

call dein#add('kana/vim-submode')
call dein#add('AndrewRadev/splitjoin.vim')
call dein#add('junegunn/vim-easy-align')
call dein#add('tomtom/tcomment_vim') " コメントON/OFFを手軽に実行
" call dein#add('LeafCage/yankround.vim')

call dein#add('kana/vim-operator-user')
call dein#add('rhysd/vim-operator-surround', {'depends': ['vim-operator-user']})
call dein#add('kana/vim-operator-replace', {'depends': ['vim-operator-user']})
"
call dein#add('kana/vim-textobj-user')
call dein#add('rhysd/vim-textobj-ruby', {'depends': ['vim-textobj-user']})
call dein#add('osyo-manga/vim-textobj-multiblock', {'depends': ['vim-textobj-user']})
call dein#add('kana/vim-textobj-indent', {'depends': ['vim-textobj-user']})

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
call dein#add('elzr/vim-json')
call dein#add('lervag/vimtex')
if dein#tap('vimtex') "{{{2
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  let g:neocomplete#sources#omni#input_patterns.tex = '\v\\\a*(ref|cite)\a*([^]]*\])?\{([^}]*,)*[^}]*'
endif "}}}
" call dein#add('vim-pandoc/vim-pandoc')
call dein#add('vim-pandoc/vim-pandoc-syntax')
if dein#tap('vim-pandoc-syntax') "{{{2
  let g:pandoc#syntax#conceal#use = 0
endif "}}}
call dein#add('vim-pandoc/vim-rmarkdown')

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

call dein#add('cohama/lexima.vim', { 'on_i': 1 })

call dein#add('Shougo/vimproc.vim', {
      \   'build' : {
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'linux' : 'make',
      \     'unix' : 'gmake',
      \   },
      \ })
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
    call unite#custom#default_action('file', 'tabswitch')
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
  execute 'autocmd vimrc User' 'dein#source#'.g:dein#name 'call s:unite_on_source()'

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
call dein#add('Shougo/unite-session')
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
endif "}}}

call dein#add('thinca/vim-quickrun')
if dein#tap('vim-quickrun') "{{{2
  let g:quickrun_config = {
        \ "_": {
        \       "outputter/buffer/split" : ":botright",
        \       "outputter/buffer/close_on_empty" : 1,
        \   "runner": "vimproc",
        \   "runner/vimproc/updatetime": 60,
        \  },
        \  }
endif "}}}

" You can specify revision/branch/tag.
call dein#add('Shougo/vimshell', { 'rev' : '3787e5' })

call dein#end()
filetype plugin indent on


" キーマッピング "{{{1
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
inoremap <expr> <C-a> col('.') == match(getline('.'), '\S') + 1 ?
      \ repeat('<C-G>U<Left>', col('.') - 1) :
      \ (col('.') < match(getline('.'), '\S') ?
      \     repeat('<C-G>U<Right>', match(getline('.'), '\S') + 0) :
      \     repeat('<C-G>U<Left>', col('.') - 1 - match(getline('.'), '\S')))
inoremap <expr> <C-e> repeat('<C-G>U<Right>', col('$') - col('.'))

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

" neocomplate
inoremap <expr><C-g>     neocomplete#undo_completion()
" inoremap <expr><C-l>     neocomplete#complete_common_string()
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
" <C-h>, <BS>: close popup and delete backword char.
" inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplete#close_popup()
" inoremap <expr><C-e> pumvisible() ? neocomplete#cancel_popup() : "\<End>"

xmap <Tab>     <Plug>(neosnippet_expand_target)
imap <expr><TAB> pumvisible() ?
      \ "\<C-n>"
      \ : neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \ : "\<TAB>"
smap <expr><TAB> pumvisible() ?
      \ "\<C-n>"
      \ : neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \ : "\<TAB>"
imap <expr><C-s> !pumvisible() ?
      \ "\<C-s>"
      \ : "\<Plug>(neosnippet_expand_or_jump)"
smap <expr><C-s> !pumvisible() ?
      \ "\<C-s>"
      \ : "\<Plug>(neosnippet_expand_or_jump)"

if dein#tap('lexima.vim')
  function! s:lexima_on_post_source() abort
    call lexima#insmode#map_hook('before', '<CR>', "\<C-r>=neocomplete#close_popup()\<CR>")
    " inoremap <silent><expr> <CR> pumvisible() ? neocomplete#close_popup() : lexima#expand('<LT>CR>', 'i')
    imap <silent><expr> <CR> !pumvisible() ? lexima#expand('<LT>CR>', 'i') :
          \ neosnippet#expandable() ? "\<Plug>(neosnippet_expand)" :
          \ neocomplete#close_popup()
    inoremap <C-j> <Down>
    inoremap <C-k> <Up>
  endfunction
  execute 'autocmd vimrc User' 'dein#post_source#'.g:dein#name 'call s:lexima_on_post_source()'
endif

vmap , <Plug>(EasyAlign)

omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
vmap ab <Plug>(textobj-multiblock-a)
vmap ib <Plug>(textobj-multiblock-i)

nmap <silent> <Leader>r <Plug>(operator-replace)

map <silent>sa <Plug>(operator-surround-append)
map <silent>sd <Plug>(operator-surround-delete)
map <silent>sr <Plug>(operator-surround-replace)

nmap <silent>sdd <Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)
nmap <silent>srr <Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)

" nnoremap <Space>o :<C-u>CtrlPFunky<CR>
" nnoremap <Space>f :<C-u>CtrlPFiler<CR>
" nnoremap <Space>f :<C-u>CtrlPFilerWithBufferDir<CR>

nnoremap <silent> <Space>u :<C-u>UniteWithBufferDir -multi-line file file/new<CR>
nnoremap <silent> <Space><C-u> :<C-u>Unite file file/new<CR>
nnoremap <silent> <Space>i :<C-u>call AutoSelectUniteFileRec()<CR>
" nnoremap <silent> <Space>i :<C-u>Unite file_rec/async<CR>
nnoremap <silent> <Space>b :<C-u>Unite buffer -force-redraw<CR>
nnoremap <silent> <Space>t :<C-u>Unite tab -force-redraw<CR>
nnoremap <silent> <Space>o :<C-u>Unite outline -direction=botright -vertical -winwidth=40<CR>
nnoremap <silent> <Space>s :<C-u>Unite session<CR>
nnoremap <silent> <Space>r :<C-u>Unite file_mru<CR>
nnoremap <silent> <Space>g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent> <Space>gd :<C-u>Unite grep -buffer-name=search-buffer<CR>
nnoremap <silent> <Space>gr :<C-u>UniteResume search-buffer<CR>

autocmd vimrc FileType unite imap <buffer> <C-c> <Plug>(unite_insert_leave)<Plug>(unite_all_exit)
autocmd vimrc FileType unite nmap <buffer> <C-c> <Plug>(unite_all_exit)

nnoremap <silent> <Space>d :<C-u>VimFiler -simple -toggle -winwidth=30 -split -force-quit<CR>

nmap <CR> <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)
vmap <CR> <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)

map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
nmap n <Plug>(incsearch-nohl)<Plug>(anzu-n-with-echo)
nmap N <Plug>(incsearch-nohl)<Plug>(anzu-N-with-echo)
map *  <Plug>(incsearch-nohl0)<Plug>(asterisk-z*)
map g* <Plug>(incsearch-nohl0)<Plug>(asterisk-gz*)
map #  <Plug>(incsearch-nohl0)<Plug>(asterisk-z#)
map g# <Plug>(incsearch-nohl0)<Plug>(asterisk-gz#)

map m/ <Plug>(incsearch-migemo-/)
map m? <Plug>(incsearch-migemo-?)
map mg/ <Plug>(incsearch-migemo-stay)

nnoremap <silent> <Space>m :OverCommandLine %s/\v<CR>
vnoremap <silent> <Space>m :OverCommandLine s/\v<CR>


" インデント "{{{1
setglobal autoindent      " オートインデント
setglobal smartindent     " スマートインデント
setglobal cindent         " C プログラムの自動インデント
setglobal expandtab       " Tab文字を空白に展開
setglobal tabstop=4       " タブ幅
setglobal shiftwidth=4    " インデントの幅
setglobal softtabstop=-1  " Tab キー押下時に挿入される空白の量(マイナスでshiftwidthと同じ)

" ファイル別設定 "{{{1
augroup vimrc_filetype
  autocmd!
  autocmd FileType ruby       setlocal tabstop=2 shiftwidth=2
  autocmd FileType vim        setlocal tabstop=2 shiftwidth=2
  autocmd FileType tex        setlocal tabstop=2 shiftwidth=2
  autocmd FileType html       setlocal tabstop=2 shiftwidth=2
  autocmd FileType css,scss   setlocal tabstop=2 shiftwidth=2
  autocmd FileType javascript setlocal tabstop=2 shiftwidth=2
augroup END


" 表示 "{{{1
set number " 行番号を表示
set cursorline
set list
setglobal listchars=tab:»\ ,space:･
setglobal showmatch " 括弧の対応をハイライト
setglobal showmode "現在のモードを表示
set conceallevel=0
let g:vim_json_syntax_conceal = 0
" texのconcealを無効化
let g:tex_conceal=''
autocmd vimrc FileType markdown setlocal conceallevel=0

" ウィンドウタイトルの保存・復元
let &t_ti .= "\e[22;0t"
let &t_te .= "\e[23;0t"

" カラー設定
syntax on " シンタックスハイライト
setglobal t_Co=256 " 256色ターミナルでVimを使用する
setglobal background=dark
augroup pencil
  autocmd!
  if &background == 'dark'
    " autocmd ColorScheme pencil highlight CursorLine ctermbg=236 guibg=#303030
    autocmd ColorScheme pencil highlight clear CursorLine
    autocmd ColorScheme pencil highlight CursorLineNr ctermbg=NONE guibg=NONE
    autocmd ColorScheme pencil highlight Normal guibg=#262626
    autocmd ColorScheme pencil highlight SpecialKey ctermfg=8 guifg=#424242
    autocmd ColorScheme pencil highlight Comment gui=NONE
  endif
augroup END
colorscheme pencil
let g:pencil_higher_contrast_ui=1 " 0=low (def), 1=high

" vim kaoriyaで、txtファイルが自動改行されてしまうバグ対応
autocmd vimrc FileType text setlocal textwidth=0



" 折り畳み "{{{1
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


" __END__ "{{{1
if filereadable(expand($HOME.'/.vimrc_local'))
  source $HOME/.vimrc_local
endif

" vim: expandtab softtabstop=-1 shiftwidth=2
" vim: foldmethod=marker
" vim: foldlevel=0
