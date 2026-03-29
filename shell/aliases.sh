# Use colors in coreutils utilities output
alias ls='ls --color=auto'
alias grep='grep --color'

# ls aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls'

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# git related aliases
alias gag='git exec ag'

# Update dotfiles
dfu() {
    (
        cd ~/.dotfiles && git pull --ff-only && ./install
    )
}

# Use pip without requiring virtualenv
syspip() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

syspip2() {
    PIP_REQUIRE_VIRTUALENV="" pip2 "$@"
}

syspip3() {
    PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}

# cd to git root directory
alias cdgr='cd "$(git root)"'

# Create a directory and cd into it
mcd() {
    mkdir "${1}" && cd "${1}"
}

# Jump to directory containing file
jump() {
    cd "$(dirname ${1})"
}

# cd replacement for screen to track cwd (like tmux)
scr_cd()
{
    builtin cd $1
    screen -X chdir "$PWD"
}

if [[ -n $STY ]]; then
    alias cd=scr_cd
fi

# Go up [n] directories
up()
{
    local cdir="$(pwd)"
    if [[ "${1}" == "" ]]; then
        cdir="$(dirname "${cdir}")"
    elif ! [[ "${1}" =~ ^[0-9]+$ ]]; then
        echo "Error: argument must be a number"
    elif ! [[ "${1}" -gt "0" ]]; then
        echo "Error: argument must be positive"
    else
        for ((i=0; i<${1}; i++)); do
            local ncdir="$(dirname "${cdir}")"
            if [[ "${cdir}" == "${ncdir}" ]]; then
                break
            else
                cdir="${ncdir}"
            fi
        done
    fi
    cd "${cdir}"
}

# Execute a command in a specific directory
xin() {
    (
        cd "${1}" && shift && "${@}"
    )
}

# Check if a file contains non-ascii characters
nonascii() {
    LC_ALL=C grep -n '[^[:print:][:space:]]' "${@}"
}

# Fetch pull request

fpr() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "error: fpr must be executed from within a git repository"
        return 1
    fi
    (
        cdgr
        if [ "$#" -eq 1 ]; then
            local repo="${PWD##*/}"
            local user="${1%%:*}"
            local branch="${1#*:}"
        elif [ "$#" -eq 2 ]; then
            local repo="${PWD##*/}"
            local user="${1}"
            local branch="${2}"
        elif [ "$#" -eq 3 ]; then
            local repo="${1}"
            local user="${2}"
            local branch="${3}"
        else
            echo "Usage: fpr [repo] username branch"
            return 1
        fi

        git fetch "git@github.com:${user}/${repo}" "${branch}:${user}/${branch}"
    )
}

# Serve current directory

serve() {
    ruby -run -e httpd . -p "${1:-8080}"
}

# Mirror a website
alias mirrorsite='wget -m -k -K -E -e robots=off'

# Mirror stdout to stderr, useful for seeing data going through a pipe
alias peek='tee >(cat 1>&2)'

# Zellij session manager
# zj          - picker: select/create/switch session
# zj foo      - attach or create session "foo"
# zj -d foo   - delete session "foo"
# zj -l       - list all sessions
zj() {
    case "${1}" in
        -d) zellij delete-session "${2}" --force 2>/dev/null && echo "Deleted: ${2}" || echo "Not found: ${2}"; return ;;
        -l) zellij list-sessions; return ;;
    esac

    if [ -n "${1}" ]; then
        if [ -n "$ZELLIJ" ]; then
            zellij pipe --name switch-session -- "${1}"
        else
            zellij attach --create "${1}"
        fi
        return
    fi

    local sessions
    sessions=$(zellij list-sessions -s 2>/dev/null)
    if [ -z "$sessions" ]; then
        printf "Session name (default: main): "
        read -r name
        zellij --session "${name:-main}"
    else
        local choice
        choice=$(printf "%s\n[new session]" "$sessions" | fzf \
            --height=40% --reverse \
            --prompt="Zellij > " \
            --header=$'↑↓ select  |  Enter attach  |  Esc cancel  |  Type to filter/create' \
            --print-query | tail -1)
        if [ -z "$choice" ]; then
            [ -n "$ZELLIJ" ] && return || zsh
        elif [ "$choice" = "[new session]" ]; then
            printf "Session name (default: main): "
            read -r name
            if [ -n "$ZELLIJ" ]; then
                zellij pipe --name switch-session -- "${name:-main}"
            else
                zellij --session "${name:-main}"
            fi
        else
            if [ -n "$ZELLIJ" ]; then
                zellij pipe --name switch-session -- "$choice"
            else
                zellij attach "$choice"
            fi
        fi
    fi
}

# Randomly switch Ghostty theme among Catppuccin flavors
ghostty-random() {
    local config="$HOME/code/dotfiles/ghostty/config"
    local themes=("Catppuccin Mocha" "Catppuccin Macchiato" "Catppuccin Frappe" "Catppuccin Latte")
    local pick=${themes[$((RANDOM % 4 + 1))]}
    local tmpfile="${config}.tmp"
    awk -v t="$pick" '{if(/^theme = /) print "theme = " t; else print}' "$config" > "$tmpfile" && mv "$tmpfile" "$config"
    echo "Ghostty theme -> ${pick}"
}
