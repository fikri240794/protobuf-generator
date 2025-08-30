#!/bin/bash

# Protocol Buffer Compiler (protoc) installer and manager
# Handles installation and version management of protoc

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

readonly PROTOC_INSTALL_DIR="/usr/local/protoc"
readonly PROTOC_VERSION_FILE="/home/.protoc_version"

# Check if protoc is already installed with the required version
is_protoc_installed() {
    local required_version="$1"
    
    if [[ -f "$PROTOC_VERSION_FILE" ]] && command -v protoc >/dev/null 2>&1; then
        local installed_version
        installed_version=$(cat "$PROTOC_VERSION_FILE" 2>/dev/null)
        
        if [[ "$installed_version" == "$required_version" ]]; then
            log_info "protoc version $required_version is already installed"
            return 0
        else
            log_info "protoc version mismatch. Installed: $installed_version, Required: $required_version"
        fi
    fi
    
    return 1
}

# Get latest protoc version from GitHub API
get_latest_protoc_version() {
    log_debug "Fetching latest protoc version from GitHub API" >&2
    local version
    version=$(curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | grep -i "tag_name" | awk -F '"' '{print $4}' | sed 's/v//')
    
    if [[ -z "$version" ]]; then
        log_error "Failed to fetch latest protoc version" >&2
        exit 1
    fi
    
    echo "$version"
}

# Install protoc
install_protoc() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        log_info "No protoc version specified, fetching latest"
        version=$(get_latest_protoc_version)
        log_debug "Fetched latest version: $version"
    fi
    
    log_step "Installing protoc version: $version"
    
    # Remove existing installation
    if [[ -d "$PROTOC_INSTALL_DIR" ]]; then
        log_debug "Removing existing protoc installation"
        rm -rf "$PROTOC_INSTALL_DIR"
    fi
    
    local protoc_url="https://github.com/protocolbuffers/protobuf/releases/download/v$version/protoc-$version-linux-x86_64.zip"
    local protoc_zip="/tmp/protoc.zip"
    
    log_debug "Downloading protoc from: $protoc_url"
    curl -o "$protoc_zip" -LO "$protoc_url" || {
        log_error "Failed to download protoc"
        exit 1
    }
    
    log_debug "Extracting protoc to: $PROTOC_INSTALL_DIR"
    mkdir -p "$PROTOC_INSTALL_DIR"
    unzip -q "$protoc_zip" -d "$PROTOC_INSTALL_DIR" || {
        log_error "Failed to extract protoc"
        exit 1
    }
    
    rm "$protoc_zip"
    
    # Save installed version
    echo "$version" > "$PROTOC_VERSION_FILE"
    
    log_success "protoc $version installed successfully"
}

# Setup protoc environment
setup_protoc_env() {
    if [[ -d "$PROTOC_INSTALL_DIR/bin" ]]; then
        export PATH="$PATH:$PROTOC_INSTALL_DIR/bin"
        log_debug "Added protoc to PATH: $PROTOC_INSTALL_DIR/bin"
    else
        log_error "protoc binary directory not found: $PROTOC_INSTALL_DIR/bin"
        exit 1
    fi
}

# Main function to ensure protoc is ready
ensure_protoc() {
    local required_version="${1:-}"
    
    # Skip version check if no version is specified (Docker image has protoc pre-installed)
    if [[ -n "$required_version" ]]; then
        if ! is_protoc_installed "$required_version"; then
            install_protoc "$required_version"
        fi
    fi
    
    setup_protoc_env
    
    # Verify installation
    if ! command -v protoc >/dev/null 2>&1; then
        log_error "protoc command not found after installation"
        exit 1
    fi
    
    local actual_version
    actual_version=$(protoc --version | awk '{print $2}')
    log_success "protoc is ready (version: $actual_version)"
}
