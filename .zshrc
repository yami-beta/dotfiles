# Check if zplug is installed
[[ -d ~/.zplug ]] || {
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
}

# Essential
source ~/.zplug/init.zsh

# Make sure to use double quotes to prevent shell expansion
zplug "zplug/zplug"
zplug "zsh-users/zsh-syntax-highlighting", nice:10
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
[ -r ~/.ssh/config ] && _ssh_config=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p')) || _ssh_config=()
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
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
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
PROMPT="${prompt_username}%F{cyan}%~%f"' ${vcs_info_msg_0_}'"
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

# fzf
function fzf_tmux_session() {
  local session=$( tmux ls | awk -F':' '{print $1}' | fzf )
  echo $session
  if [ -n "$session" ]; then
    tmux attach -t $session;
  fi
}

# tmux
alias ts='tmux new -s $(basename `pwd`)'
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
