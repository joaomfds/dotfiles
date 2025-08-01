# ==============================
# 1. Shell Interactivity Check
# ==============================
# Exit if the shell is non-interactive
if [[ $- != *i* ]] ; then
    # Shell is non-interactive. Be done now!
    return
fi

# ==============================
# 2. Prompt Customization
# ==============================
# Set fallback PS1 if currently set to upstream bash default
if [ "$PS1" = '\s-\v\$ ' ]; then
    PS1='\h:\w\$ '
fi

# ==============================
# 3. Source System and Global Scripts
# ==============================
# Source all readable scripts in /etc/bash/
for f in /etc/bash/*.sh; do
    [ -r "$f" ] && . "$f"
done
unset f

# Source global definitions if available
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ==============================
# 4. Bash Completion
# ==============================
# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ==============================
# 5. Shell Options
# ==============================
# Check the window size after each command and update LINES and COLUMNS if necessary
shopt -s checkwinsize

# Append to the history file, don't overwrite it
shopt -s histappend

# ==============================
# 6. Command History Configuration
# ==============================
# Immediately append new history lines to the history file
PROMPT_COMMAND='history -a'

# Allow Ctrl-S for history navigation (with Ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Set maximum number of lines in the history file
export HISTFILESIZE=10000

# Set maximum number of commands remembered in the current session
export HISTSIZE=5000

# Control how Bash handles command history:
# - erasedups: Remove older duplicate commands from history
# - ignoredups: Do not store duplicate commands in history
# - ignorespace: Do not store commands that start with a space
export HISTCONTROL=ignorespace

# ==============================
# 7. Readline and Input Behavior
# ==============================
# Configure readline for improved tab completion and navigation
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind 'set show-all-if-unmodified on'
bind 'set show-all-if-ambiguous on'
bind 'set colored-stats on'
bind 'set visible-stats on'
bind 'set mark-symlinked-directories on'
bind 'set colored-completion-prefix on'
bind 'set menu-complete-display-prefix on'
bind 'set bell-style visible'
bind 'set completion-ignore-case on'

# ==============================
# 8. Environment Variables
# ==============================
export EDITOR="nvim"
export VISUAL="nvim"
#export GTK_THEME="Adwaita:dark"
export PAGER="less"
export TERM="xterm-256color"
export PATH="/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$HOME/.local/bin"
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null' --preview-window=right:60%"

# Enable colored output for the `ls` command and related utilities
export CLICOLOR=0

# Uncomment and customize LS_COLORS for colored ls output
# export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:...'

# ==============================
# 9. Aliases
# ==============================
alias ls='eza --icons --color --group-directories-first'
alias la='ls -a'
alias l='ls -l'
alias ll='ls -la'
alias lt='ls -lT'
alias syu='sudo pacman -Syu --needed'
alias updatemirrors='reflector -c AT -p https --sort rate -f 1 --verbose > mirrorlist && sudo mv mirrorlist /etc/pacman.d/mirrorlist'

# Aliases for Neovim as default editor
alias v=nvim
alias vi=nvim
alias vim=nvim

# ==============================
# 10. Shell Integrations
# ==============================
# Starship prompt initialization
eval "$(starship init bash)"

# FZF (fuzzy finder) integration
eval "$(fzf --bash)"

# Zoxide (smarter cd command) integration
eval "$(zoxide init --cmd cd bash)"

# ==============================
# 11. Optional/Commented Out Sections
# ==============================
# Uncomment to run fastfetch at shell startup
# if [ -f /usr/bin/fastfetch ]; then
#     fastfetch
# fi

# Uncomment to start Hyprland on TTY1 if no DISPLAY is set
#if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
#    exec startplasma-wayland
#fi

# ==============================
# 12. Make hardware acceleration work on google-chrome. Also needs the chrome-flags enabled
# ==============================
#export LIBVA_DRIVER_NAME=iHD # for intel-media-driver (Gen8+)                                      
#export LIBVA_DRIVERS_PATH=/usr/lib/dri                                                             
#export LIBVA_DRM_DEVICE=/dev/dri/renderD128                                                        
