set number             "行番号を表示
set autoindent         "改行時に自動でインデントする
set tabstop=4          "タブを何文字の空白に変換するか
set shiftwidth=4       "自動インデント時に入力する空白の数
set expandtab          "タブ入力を空白に変換
set splitright         "画面を縦分割する際に右に開く
set clipboard=unnamed  "yank した文字列をクリップボードにコピー
set hls                "検索した文字をハイライトする

set undofile                    " Persist undo tree across launches
set undolevels=1000             " Maximum number of changes that can be undone
set undoreload=10000            " Maximum number lines to save for undo on a buffer reload

if has("autocmd")
  "ファイルタイプの検索を有効にする
  filetype plugin on
  "ファイルタイプに合わせたインデントを利用
  "filetype indent on
  
  "sw=softtabstop, sts=shiftwidth, ts=tabstop, et=expandtabの略
  autocmd FileType yaml        setlocal sw=2 sts=2 ts=2 et

  " 引数無しでvimを起動したときにdefxを起動する
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | Defx | endif
endif


" bufferのキーマップ
nnoremap <silent> bp :bprev<CR>
nnoremap <silent> bn :bnext<CR>

" terminalモード内でのキーマップ
" ESCでコマンド入力モードを解除
tnoremap <silent> <ESC> <C-\><C-n>

" Coc extensions
let g:coc_global_extensions = ['coc-marketplace', 'coc-highlight', 'coc-go', 'coc-python']

" autosave plugin
 let g:auto_save = 1


" ============== dein =================
" Pythonインタプリタへのパスを指定
let g:python3_host_prog = '/usr/local/bin/python3'
let g:python_host_prog = '/usr/bin/python'


" 各種ファイルへのパス
let s:dein_cache_dir = $XDG_CACHE_HOME . '/dein'
let s:dein_config_dir = $XDG_CONFIG_HOME . '/nvim'
let s:dein_repo_dir = s:dein_cache_dir . '/repos/github.com/Shougo/dein.vim'
let s:toml = s:dein_config_dir . '/dein.toml'
let s:toml_lazy = s:dein_config_dir . '/dein_lazy.toml'

"dein Scripts-----------------------------
if &compatible
  set nocompatible
endif

" Required:
let &runtimepath = s:dein_repo_dir .",". &runtimepath

" Required:
if dein#load_state(s:dein_cache_dir)
  call dein#begin(s:dein_cache_dir)

  " Let dein manage dein
  " Required:
  call dein#add(s:dein_repo_dir)
  
  " tomlファイルからプラグインのリストをロードしキャッシュする
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:toml_lazy, {'lazy': 1})
  
  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

" update plugins
let g:dein#install_github_api_token = expand('$GITHUB_TOKEN')
call dein#check_update(v:true)

"End dein Scripts-------------------------

" truecolor¬
set termguicolors

" Color theme
if (has("termguicolors"))
 set termguicolors
endif

syntax enable
set background=dark
colorscheme hybrid

"nvim-treesitter config--------------------
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  indent = {
    enable = true, -- これを設定することでtree-sitterによるインデントを有効にできます
  },
  ensure_installed = 'maintained',
}
EOF
