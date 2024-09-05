# vim を日本語表示にするため
export LANG=ja_JP.UTF-8

# fzf で border がずれるため
# https://shoalwave.net/develop/2023062245388/
# https://noborus.github.io/blog/runewidth/index.html
export RUNEWIDTH_EASTASIAN=0

bindkey -e
disable r # rコマンド(zsh)を無効化，R言語と重複する
setopt nonomatch # glob展開による警告を無効 (e.g. rake new_post['post title'])
autoload -Uz colors && colors
# export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export CLICOLOR=true
unsetopt promptcr # 改行のない出力も表示


# ----------
# 履歴
# ----------
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
# 重複を記録しない
setopt hist_ignore_dups
# 履歴ファイルにタイムスタンプを記録
setopt EXTENDED_HISTORY


# ----------
# 補完
# ----------
# 大文字小文字を無視して補完
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# sshの補完候補
zstyle ':completion:*' users off # ユーザの補完をオフ
_ssh_config=($(egrep -i '^Host\s+.+' $HOME/.ssh/config $(find $HOME/.ssh/conf.d -type f 2>/dev/null) | awk '{print $2}'))
[ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
  "$_ssh_config[@]"
  localhost
)
zstyle ':completion:*:hosts' hosts $hosts # ホスト名の補完

# cd の履歴
# $ cd -[tab]
# auto_pushd: cd の履歴を保持
# pushdminus: 候補順を時系列降順にする
# pushdignoredups: 重複する履歴を記録しない
DIRSTACKSIZE=5
setopt auto_pushd pushdminus pushdignoredups

# プロンプト
# autoload -Uz vcs_info
# autoload -Uz add-zsh-hook
# # PROMPT変数内で変数参照する
# setopt prompt_subst
# zstyle ':vcs_info:git:*' check-for-changes true
# zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
# zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
# zstyle ':vcs_info:*' formats "%F{cyan}%c%u%b%f"
# zstyle ':vcs_info:*' actionformats '[%b|%a]'
# function _update_vcs_info()
# {
#   vcs_info
# }
# add-zsh-hook precmd _update_vcs_info
# local prompt_username
# # sshログイン時に ユーザ名@ホスト名 を表示
# [[ "$SSH_CONNECTION" != '' ]] && prompt_username="%F{green}%n@%m%f:"
# # root時に ユーザ名@ホスト名 を表示
# [[ $UID -eq 0 ]] && prompt_username="%F{green}%n@%m%f:"
# # prompt_subst は，シングルクォートで囲まれている場合のみ変数展開する
# # %(!.#.$) は，Conditional Substitution
# PROMPT="${prompt_username}%F{blue}%~%f"' ${vcs_info_msg_0_}'"
# %(!.#.$) "


# history search
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

alias ll='ls -lha'
alias la='ls -a'
alias rm='rm -i'

function repo() {
  select_repo=$(ghq list | fzf)
  if [[ $select_repo = "" ]]; then
    return
  fi

  cd $(ghq root)/$select_repo
  if type wezterm >/dev/null 2>&1; then
    wezterm cli rename-workspace $select_repo
  fi
}

function git_branch() {
  local output=$(git branch --all -vv --color=always | grep -v -E "HEAD" |
  fzf --multi --ansi --no-sort --expect=ctrl-y | awk '{gsub(/^\*/, " ", $0); print $1;}')
  local key=$(head -1 <<< "$output")
  local branch=$(echo $output | tail -n +2 | awk '{gsub(/^\*/, " ", $0); print $1;}')
  case "$key" in
    ctrl-y)
      # "remotes/origin/"を消す
      branch=$(awk '{gsub(/^remotes\/origin\//, "", $0); print $0}' <<< "$branch")
      ;;
    *)
      # ローカルの場合: master
      # リモートの場合: origin/master
      branch=$(awk '{gsub(/^remotes\//, "", $0); print $0}' <<< "$branch")
  esac
  if [ -n "$branch" ]; then
    BUFFER="${LBUFFER}$(echo $branch | tr '\n' ' ')${RBUFFER}"
    CURSOR=${#BUFFER}
  fi
  zle redisplay
}
# 関数をウィジェットに登録
zle -N git_branch
bindkey '^y^b' git_branch

function git_add() {
  local files=$(git status --short -u | grep -E "^(\s\w|\?\?|\w\w)" | fzf --multi --ansi --prompt='git add > '\
    --bind "enter:toggle-preview" --bind "ctrl-n:preview-down" --bind "ctrl-p:preview-up" --bind "ctrl-y:accept" \
    --preview-window "down:wrap" \
    --preview " (awk '{print \$2}' | xargs -I % sh -c 'git add -N % && git diff --color=always % | less -R && git reset % > /dev/null 2>&1') <<< {}" | awk '{print $2}')
  if [ -n "$files" ]; then
    BUFFER="${BUFFER}$(echo $files | tr '\n' ' ')"
    CURSOR=${#BUFFER}
  fi
  zle redisplay
}
zle -N git_add
bindkey '^y^f' git_add

function ggraph() {
  git log --graph --color=always --date-order --all -C -M --pretty=format:"%x09%C(auto)[%h] %C(cyan)%ad%Creset %C(blue)%an%Creset %C(auto)%d %s" --date=short |
  fzf --ansi --no-sort --reverse --tiebreak=index --prompt='git log > ' \
    --bind "enter:toggle-preview" --bind "ctrl-n:preview-down" --bind "ctrl-p:preview-up" --bind "ctrl-y:accept" \
    --preview-window=down:hidden:wrap \
    --preview " (grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | less -R') <<< {}"
}
function zle_git_graph() {
  local commit_hash=$(ggraph | grep -o '[a-f0-9]\{7\}')
  if [ -n "$commit_hash" ]; then
    BUFFER="${BUFFER}${commit_hash}"
    CURSOR=${#BUFFER}
  fi
  zle redisplay
}
zle -N zle_git_graph
bindkey '^y^l' zle_git_graph

# tmux
alias tmux='tmux -u'
# -A で session が存在する場合は attach になる
alias tn='tmux new -A -s $(basename $(pwd) | awk "{ gsub(/\./, \"_\", \$0); print \$0 }")'

# history
function fzf_select_history() {
  local tac
  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi
  BUFFER=$(history -n 1 | eval $tac | fzf --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf_select_history
bindkey '^r' fzf_select_history

alias deno-file-server='deno run --allow-net --allow-read https://deno.land/std/http/file_server.ts'

export EDITOR="vim"


# proto
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

export FZF_DEFAULT_COMMAND='rg --files --hidden --no-ignore --iglob "!.git"'

source "$HOME/pnpm-completion.zsh"

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

# zsh-syntax-highlighting が zshrc の最後の辺りに置くことを推奨されている
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# zsh-history-substring-search は zsh-syntax-highlighting の後に置くことを推奨されている
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# https://mise.jdx.dev/getting-started.html#_2a-activate-mise
# `mise activate zsh` はインタラクティブ環境で PATH を操作するための設定なので .zshrc に記載している
if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# .zshrc.local で読み込んでいる google-cloud-sdk/completion.zsh.inc が compinit がまだ呼ばれていないときに呼ぶようになっているため、この位置で読み込み
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

typeset -U path

eval "$(starship init zsh)"
