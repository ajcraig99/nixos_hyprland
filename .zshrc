# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- ARCH LINUX PLUGIN SECTION (Added for Migration) ---
# Source the theme engine
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Source Plugins (Installed via Pacman)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Basic Aliases for the tools you installed
alias ls='eza --icons'
alias cat='bat'
# -------------------------------------------------------

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
(( ! ${+functions[p10k]} )) || p10k finalize

export "MICRO_TRUECOLOR=1"

if [[ "$TERM" == "xterm-kitty" ]]; then
    precmd() {
        print -Pn "\e]2;%~\a"
    }
    preexec() {
        print -Pn "\e]2;$1 - %~\a"
    }
fi
