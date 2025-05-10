#!/bin/bash

# Constants and configuration
BACKUP_DIR="${BACKUP_DIR:-/tmp}"
LOG_FILE="/tmp/installation.log"

# Logging function
log() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Progress indication
show_progress() {
    echo -n "$1..."
}

finish_progress() {
    local status=$?
    if [ $status -eq 0 ]; then
        echo " Done"
    else
        echo " Failed"
    fi
    return $status
}

# Cleanup function
cleanup() {
    log "INFO" "Cleaning up temporary files..."
    [ -f temp ] && rm -f temp
    [ -f /tmp/*.deb ] && rm -f /tmp/*.deb
    [ -f /tmp/miniconda.sh ] && rm -f /tmp/miniconda.sh
}

# Error handling
handle_error() {
    local line_no=$1
    local error_code=$2
    log "ERROR" "Error on line $line_no. Exit code: $error_code"
    cleanup
    exit $error_code
}


# Function to run commands based on root/non-root mode
run_command() {
    if [ "$ROOT_MODE" = true ]; then
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
    local file="$1"
    local backup_path="$BACKUP_DIR/$(basename "$file")"
    
    # check if the file exists and is a regular file
    if [ ! -e "$file" ]; then
        log "INFO" "$file does not exist"
        return 0
    fi

    if [ ! -f "$file" ]; then
        log "INFO" "$file is a symbolic link. Deleting."
        rm "$file"
        return 0
    fi

    # copy the file to backup directory with the same name
    if ! cp -L "$file" "$backup_path"; then
        log "ERROR" "Failed to copy $file to $backup_path"
        return 3
    fi
    log "INFO" "Backed up $file to $backup_path"

    # delete the original file
    if ! rm "$file"; then
        log "ERROR" "Failed to delete $file"
        return 4
    fi
    log "INFO" "Deleted $file"
}

# Improved dotfile installation
install_dotfile() {
    local src="$1"
    local dest="$2"
    
    show_progress "Installing $(basename "$src")"
    if [ ! -f "$src" ]; then
        log "ERROR" "Source file $src does not exist"
        finish_progress
        return 1
    fi
    
    backup_and_delete "$dest"
    cp "$src" "$dest"
    finish_progress
}

# WSL detection
is_wsl() {
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ] || \
       grep -qi microsoft /proc/version; then
        return 0
    fi
    return 1
}

# Configuration backup
backup_configs() {
    local backup_dir="$BACKUP_DIR/config_backup_$(date +%Y%m%d_%H%M%S)"
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

# Validate email format
validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log "ERROR" "Invalid email format"
        return 1
    fi
    return 0
}
