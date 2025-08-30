#!/bin/bash

# System utilities for package installation and system setup
# Provides reusable functions for system operations

# Prevent double sourcing
if [[ -n "${SYSTEM_UTILS_LOADED:-}" ]]; then
    return 0
fi
export SYSTEM_UTILS_LOADED=1

source "$(dirname "${BASH_SOURCE[0]}")/../core/logger.sh"

PACKAGE_CACHE_FILE="/home/.installed_packages"

# Check if packages are already installed
are_packages_installed() {
    local packages=("$@")
    
    if [[ ! -f "$PACKAGE_CACHE_FILE" ]]; then
        return 1
    fi
    
    local installed_packages
    installed_packages=$(cat "$PACKAGE_CACHE_FILE")
    
    for package in "${packages[@]}"; do
        if ! echo "$installed_packages" | grep -q "$package"; then
            return 1
        fi
    done
    
    return 0
}

# Install system packages
install_system_packages() {
    local packages=("$@")
    
    if are_packages_installed "${packages[@]}"; then
        log_info "Required packages already installed: ${packages[*]}"
        return 0
    fi
    
    log_step "Installing system packages: ${packages[*]}"
    
    # Update package list
    log_debug "Updating package list"
    apt-get update -y >/dev/null 2>&1 || {
        log_error "Failed to update package list"
        exit 1
    }
    
    # Install packages
    log_debug "Installing packages"
    apt-get install -y "${packages[@]}" >/dev/null 2>&1 || {
        log_error "Failed to install packages: ${packages[*]}"
        exit 1
    }
    
    # Save installed packages to cache
    printf '%s\n' "${packages[@]}" >> "$PACKAGE_CACHE_FILE"
    
    log_success "System packages installed successfully"
}

# Ensure required system packages are available
ensure_system_packages() {
    local required_packages=("curl" "unzip" "git")
    install_system_packages "${required_packages[@]}"
}

# Clean up temporary files
cleanup_temp_files() {
    log_debug "Cleaning up temporary files"
    rm -f /tmp/*.tar.gz /tmp/*.zip /tmp/protoc-* 2>/dev/null || true
}
