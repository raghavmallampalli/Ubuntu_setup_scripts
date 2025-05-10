#!/bin/sh

# Constants and configuration
BACKUP_DIR="${BACKUP_DIR:-/tmp}"
LOG_FILE="/tmp/installation.log"

# Logging function
log() {
    level="$1"
    shift
    echo ""
    if [ "$level" = "WARN" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [\033[33m$level\033[0m] $*" | tee -a "$LOG_FILE"
    elif [ "$level" = "ERROR" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [\033[31m$level\033[0m] $*" | tee -a "$LOG_FILE"
    else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
    fi
}

# Progress indication
show_progress() {
    echo -n "$1..."
}

finish_progress() {
    status=$?
    if [ $status -eq 0 ]; then
        echo " Done"
    else
        echo " Failed"
    fi
    return $status
}

# Cleanup function
cleanup() {
    exit_code=$?
    line_no=$1
    error_code=$2

    # Always do cleanup
    log "INFO" "Cleaning up temporary files..."
    [ -f temp ] && rm -f temp
    [ -f /tmp/*.deb ] && rm -f /tmp/*.deb
    [ -f /tmp/miniconda.sh ] && rm -f /tmp/miniconda.sh
    log "INFO" "Done."

    # Only log error if there was one
    if [ $exit_code -ne 0 ]; then
        log "ERROR" "Error on line $line_no. Exit code: $error_code"
    fi

    exit $exit_code
}

# Function to run commands based on root/non-root mode
run_command() {
    if [ "$ROOT_MODE" = "true" ]; then
        execute "$@"
    else
        execute sudo "$@"
    fi
}

# Improved execute function
execute() {
    log "CMD" "$*"
    if ! OUTPUT=$("$@" 2>&1 | tee -a "$LOG_FILE"); then
        log "ERROR" "$OUTPUT"
        log "ERROR" "Failed to Execute $*"
        return 1
    fi
}

# Backup the file to backup directory and delete it
backup_and_delete() {
    file="$1"
    backup_path="$BACKUP_DIR/$(basename "$file")"

    # check if the file exists and is a regular file
    if [ ! -e "$file" ]; then
        log "INFO" "$file does not exist"
        return 0
    fi

    if is_symlink "$file"; then
        log "INFO" "$file is a symbolic link"
        if [ -f "$(readlink "$file")" ]; then
            cp -L "$file" "$backup_path" || {
                log "ERROR" "Failed to backup symlink target $file"
                return 3
            }
        fi
        rm "$file" || {
            log "ERROR" "Failed to remove symlink $file"
            return 4
        }
    else
        cp -L "$file" "$backup_path" || {
            log "ERROR" "Failed to backup $file"
            return 3
        }
        rm "$file" || {
            log "ERROR" "Failed to delete $file"
            return 4
        }
    fi
    log "INFO" "Backed up and removed $file"
}

# Improved dotfile installation
install_dotfile() {
    src="$1"
    dest="$2"
    soft_link="${3:-false}"
    if [ "$soft_link" = "true" ]; then
        soft_link=true
    else
        soft_link=false
    fi

    show_progress "Installing $(basename "$src")"
    if [ ! -f "$src" ]; then
        log "ERROR" "Source file $src does not exist"
        finish_progress
        return 1
    fi

    backup_and_delete "$dest"

    if [ "$soft_link" = "true" ]; then
        ln -s "$src" "$dest"
    else
        cp "$src" "$dest"
    fi
    finish_progress
}

# WSL detection
is_wsl() {
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ] || \
       grep -qi microsoft /proc/version 2>/dev/null; then
        return 0
    fi
    return 1
}

# Configuration backup
backup_configs() {
    backup_dir="$BACKUP_DIR/config_backup_$(date +%Y%m%d_%H%M%S)"
    show_progress "Backing up configurations"
    mkdir -p "$backup_dir"
    for file in .zshrc .bashrc .vimrc .tmux.conf; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$backup_dir/"
        fi
    done
    log "INFO" "Configurations backed up to $backup_dir"
    finish_progress
}

is_symlink() {
    file="$1"
    if [ -L "$file" ]; then
        return 0
    fi
    return 1
}
