# Check if zplug is installed
[[ -d ~/.zplug ]] || {
  git clone https://github.com/b4b4r07/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
}

# Essential
source ~/.zplug/init.zsh

# Make sure to use double quotes to prevent shell expansion
zplug "zplug/zplug"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"

# Add a bunch more of your favorite packages!

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

autoload -Uz compinit
compinit
# End of lines added by compinstall
unsetopt promptcr

autoload -Uz colors && colors
PROMPT="%{${fg[green]}%}%n@%m%{${reset_color}%}: %{${fg[cyan]}%}%~%{${reset_color}%}
%(!.#.$) "

# Git
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'

# prmptcmd() { eval "$PROMPT_COMMAND" }
# precmd_functions=(prmptcmd)
# PROMPT_COMMAND='/c/Program\ Files/ConEmu/ConEmu/ConEmuC -StoreCWD'

alias ls='ls --color'
alias ll='ls -la'
