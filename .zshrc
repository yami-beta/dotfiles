# Check if zplug is installed
[[ -d ~/.zplug ]] || {
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
}

# Essential
source ~/.zplug/init.zsh

# Make sure to use double quotes to prevent shell expansion
zplug "zplug/zplug"
zplug "zsh-users/zsh-syntax-highlighting"
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
disable r
setopt nonomatch
autoload -Uz colors && colors
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export CLICOLOR=true
unsetopt promptcr

# prmptcmd() { eval "$PROMPT_COMMAND" }
# precmd_functions=(prmptcmd)
# PROMPT_COMMAND='/c/Program\ Files/ConEmu/ConEmu/ConEmuC -StoreCWD'

# プロンプト
autoload -Uz vcs_info
# PROMPT変数内で変数参照する
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd() { vcs_info }
PROMPT="%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[cyan]%}%~%{$reset_color%}
%(!.#.$) "
RPROMPT='${vcs_info_msg_0_}'

# 補完
autoload -Uz compinit && compinit
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# ssh設定
zstyle ':completion:*' users off # ユーザの補完をオフ
[ -r ~/.ssh/config ] && _ssh_config=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p')) || _ssh_config=()
[ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
  "$_ssh_config[@]"
  localhost
)
zstyle ':completion:*:hosts' hosts $hosts # ホスト名の補完

# history search
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

alias ls='ls --color'
alias ll='ls -lha'
alias la='ls -a'
alias rm='rm -i'
alias sshlocal='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias tsukuba='tsukuba.sh'

export PATH=~/bin:$PATH
if type brew >/dev/null 2>&1; then
  export PATH="$(brew --prefix)/bin:$PATH"
fi

#MacVim-KaoriYa
export PATH="/Applications/MacVim.app/Contents/MacOS:$PATH"
#alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='Vim'
alias gvim='mvim'

# Visual Studio Code
code () {
  if [[ $# = 0 ]]
  then
    open -a "Visual Studio Code"
  else
    [[ $1 = /* ]] && F="$1" || F="$PWD/${1#./}"
    open -a "Visual Studio Code" "$F"
  fi
}

# peco
function _peco_tmux_session() {
  local session="$( tmux ls | peco | awk -F':' '{print $1}')"
  echo $session
  if [ -n "$session" ]; then
    tmux attach -t $session;
  fi
}

# tmux
alias ts='tmux new -s $(basename `pwd`)'
alias ta='_peco_tmux_session'

export EDITOR="vim"
export PATH="/usr/local/sbin:$PATH"


# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if type rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi
alias be="bundle exec"

# nodebrew
export PATH="$HOME/.nodebrew/current/bin:$PATH"

# docker
# alias dmstart='docker-machine start default && eval "$(docker-machine env default)"'
# alias dmstop='docker-machine stop default'
alias docker='docker $(docker-machine config docker-host)'