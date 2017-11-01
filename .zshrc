# Check if zplug is installed
[[ -d ~/.zplug ]] || {
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
}

# Essential
source ~/.zplug/init.zsh

# Make sure to use double quotes to prevent shell expansion
zplug "zplug/zplug"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"

# Install packages that have not been installed yet
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  else
    echo
  fi
fi

zplug load

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
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
setopt prompt_subst # PROMPT変数内で変数参照する
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{cyan}%c%u%b%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
function _update_vcs_info()
{
  vcs_info
}
add-zsh-hook precmd _update_vcs_info
local prompt_username
# sshログイン時に ユーザ名@ホスト名 を表示
[[ "$SSH_CONNECTION" != '' ]] && prompt_username="%F{green}%n@%m%f:"
# root時に ユーザ名@ホスト名 を表示
[[ $UID -eq 0 ]] && prompt_username="%F{green}%n@%m%f:"
# prompt_subst は，シングルクォートで囲まれている場合のみ変数展開する
# %(!.#.$) は，Conditional Substitution
PROMPT="${prompt_username}%F{blue}%~%f"' ${vcs_info_msg_0_}'"
%(!.#.$) "


# history search
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

alias ll='ls -lha'
alias la='ls -a'
alias rm='rm -i'
alias sshlocal='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias tsukuba='tsukuba.sh'

export PATH=~/bin:$PATH
if type brew >/dev/null 2>&1; then
  export PATH="$(brew --prefix)/bin:$PATH"
fi

function repo() {
  local ghq_list tmux_status tmux_sessions repo_dir key query out filter_owner
  filter_owner=1

  function get_merged_list() {
    filter_owner=$1
    ghq_list=$(ghq list | awk 'BEGIN{OFS="\t"} {print "[ghq]", $0}')
    if [[ $filter_owner -eq 1 ]]; then
      ghq_list=$(grep -E "($FZF_REPO_FILTER)" <<< "$ghq_list")
    fi

    tmux_status=$(tmux ls 2>&1)
    if [[ "$tmux_status" =~ '^(no server running|error)' ]]; then
      # tmuxのsessionが存在しない場合はghq_listの先頭に改行を入れない
      # 改行を入れると空文字の候補になってしまうため
      tmux_sessions=""
    else
      # tmuxのsessionが存在する場合はghq_listの先頭に改行を入れて2つを結合できるようにする
      tmux_sessions=$(echo $tmux_status | awk -F':' 'BEGIN{OFS="\t"} {print "[tmux]", $1}')
      ghq_list="\n${ghq_list}"
    fi

    echo "${tmux_sessions}${ghq_list}"
  }

  while out=$(
    get_merged_list $filter_owner | fzf-tmux --print-query --query="$query" --expect=ctrl-r
    ); do
    query=$(head -1 <<< "$out")
    key=$(head -2 <<< "$out" | tail -1)
    repo_dir=$(head -3 <<< "$out" | tail -1)
    if [[ "$key" = ctrl-r ]]; then
      filter_owner=$((filter_owner ? 0 : 1))
    else
      if [[ -n "$repo_dir" ]]; then
        local select_value=$(echo $repo_dir | awk '{print $2}')
        local select_type=$(echo $repo_dir | awk '{print $1}')
        if [[ "$select_type" = "[tmux]" ]]; then
          tmux attach -t $select_value
        else
          cd ${GOPATH}/src/${select_value}
        fi
      fi
      break
    fi
  done
}

function git_branch() {
  local output=$(git branch --all -vv --color=always | grep -v -E "HEAD" |
  fzf-tmux --multi --ansi --no-sort --expect=ctrl-y | awk '{gsub(/^\*/, " ", $0); print $1;}')
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
bindkey '^g^b' git_branch

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
bindkey '^g^f' git_add

function ggraph() {
  git log --graph --color=always --date-order --all -C -M --pretty=format:"%x09%C(auto)[%h] %C(cyan)%ad%Creset %C(blue)%an%Creset %C(auto)%d %s" --date=short |
  fzf --ansi --no-sort --reverse --tiebreak=index --prompt='git log > ' \
    --bind "enter:toggle-preview" --bind "ctrl-n:preview-down" --bind "ctrl-p:preview-up" --bind "ctrl-y:accept" \
    --preview-window=down:hidden:wrap \
    --preview " (grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | emojify | less -R') <<< {}"
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
bindkey '^g^g' zle_git_graph

function fzf_tmux_session() {
  local session=$( tmux ls | awk -F':' '{print $1}' | fzf )
  echo $session
  if [ -n "$session" ]; then
    tmux attach -t $session;
  fi
}

# tmux
alias tn='tmux new -s $(basename $(pwd) | awk "{ gsub(/\./, \"_\", \$0); print \$0 }")'
alias ta='fzf_tmux_session'

# history
function fzf_select_history() {
  local tac
  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi
  BUFFER=$(history -n 1 | eval $tac | fzf-tmux --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf_select_history
bindkey '^r' fzf_select_history

export EDITOR="vim"
export PATH="/usr/local/sbin:$PATH"


alias be="bundle exec"

# npm completion
eval "$(npm completion 2>/dev/null)"

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

typeset -U path
