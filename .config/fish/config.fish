# Source original CachyOS Fish helpers
source /usr/share/cachyos-fish-config/cachyos-config.fish

# Pyenv root
set -gx PYENV_ROOT $HOME/.pyenv

# Disable virtualenv prompt changes
set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1

# Add pyenv to PATH if not already present
if not contains $PYENV_ROOT/bin $PATH
    set -gx PATH $PYENV_ROOT/bin $PATH
end

# Initialize pyenv for Fish
if type -q pyenv
    pyenv init - | source
end

# To learn about prompt customization visit: https://starship.rs/config/
starship init fish | source 

# Turn on Fuzzy search shortcuts
fzf --fish | source