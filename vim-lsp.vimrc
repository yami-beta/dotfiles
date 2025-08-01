set nocompatible
" $XDG_CONFIG_HOME/vim/vimrc を使う場合 $HOME/.vim が runtimepath に追加されないため
" 特に vim-plug のインストールが $HOME/.vim/autoload/ になっているので手動で runtimepath に追加しています
" いずれは XDG_DATA_HOME ($HOME/.local/share) に移しても良いかもしれない
" https://vim-jp.org/vimdoc-ja/starting.html#xdg-base-dir
setglobal runtimepath+=$HOME/.vim

call plug#begin('~/.vim/plug')
" Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_fold_enabled=0
let g:lsp_settings = {
\ 'efm-langserver': {
\   'disabled': v:true
\ },
\ }
" let g:lsp_settings_filetype_typescript = ['vscode-eslint-language-server', 'typescript-language-server']
" let g:lsp_settings_filetype_typescriptreact = ['vscode-eslint-language-server', 'typescript-language-server']
" let g:lsp_settings_filetype_javascript = ['vscode-eslint-language-server', 'typescript-language-server']
" let g:lsp_settings_filetype_javascriptreact = ['vscode-eslint-language-server', 'typescript-language-server']
let g:lsp_settings_filetype_typescript = ['vscode-eslint-language-server']
let g:lsp_settings_filetype_typescriptreact = ['vscode-eslint-language-server']
let g:lsp_settings_filetype_javascript = ['vscode-eslint-language-server']
let g:lsp_settings_filetype_javascriptreact = ['vscode-eslint-language-server']

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
endfunction
augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

call plug#end()

" https://github.com/prabirshrestha/vim-lsp/issues/1056
" いつの間にか --server オプションが付いていたらしい
" autocmd BufWritePre *.ts,*.tsx call execute('LspDocumentFormatSync --server=efm-langserver')

" autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
" imap <c-space> <Plug>(asyncomplete_force_refresh)
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
" autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
" call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
"  \ 'name': 'omni',
"  \ 'whitelist': ['*'],
"  \ 'completor': function('asyncomplete#sources#omni#completor')
"  \  }))
" call asyncomplete#register_source(
"    \ asyncomplete#sources#buffer#get_source_options({
"    \   'name': 'buffer',
"    \   'whitelist': ['*'],
"    \   'completor': function('asyncomplete#sources#buffer#completor'),
"    \ }))
