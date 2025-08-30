#!/bin/bash

# Go language generator for protobuf files
# Uses gobrew for Go version management and generates Go protobuf code

source "$(dirname "${BASH_SOURCE[0]}")/../core/logger.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/system_utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/version_compatibility.sh"

readonly GO_WORKSPACE="/home/go"
readonly GOBREW_VERSION_FILE="/home/.gobrew_version"

# Check if gobrew is installed
is_gobrew_installed() {
    [[ -f "$HOME/.gobrew/bin/gobrew" ]] && [[ -f "$GOBREW_VERSION_FILE" ]]
}

# Install gobrew
install_gobrew() {
    log_step "Installing gobrew for Go version management"
    
    if is_gobrew_installed; then
        log_info "gobrew is already installed"
        return 0
    fi
    
    local gobrew_install_script="/tmp/gobrew_install.sh"
    
    log_debug "Downloading gobrew installation script"
    curl -s -L https://raw.githubusercontent.com/kevincobain2000/gobrew/master/git.io.sh -o "$gobrew_install_script" || {
        log_error "Failed to download gobrew installation script"
        exit 1
    }
    
    log_debug "Running gobrew installation"
    # The install script installs to $HOME/.gobrew by default
    bash "$gobrew_install_script" || {
        log_error "Failed to install gobrew"
        exit 1
    }
    
    rm -f "$gobrew_install_script"
    
    # Verify installation
    if [[ ! -f "$HOME/.gobrew/bin/gobrew" ]]; then
        log_error "gobrew binary not found after installation at $HOME/.gobrew/bin/gobrew"
        exit 1
    fi
    
    # Mark as installed
    echo "installed" > "$GOBREW_VERSION_FILE"
    
    log_success "gobrew installed successfully"
}

# Setup gobrew environment
setup_gobrew_env() {
    # Set PATH as per gobrew official documentation
    export PATH="$HOME/.gobrew/current/bin:$HOME/.gobrew/bin:$PATH"
    export GOPATH="$GO_WORKSPACE"
    # Let Go determine GOROOT automatically
    unset GOROOT
    
    # Ensure go workspace directory  
    mkdir -p "$GO_WORKSPACE"
    
    # Add GOPATH/bin to PATH for protoc plugins
    export PATH="$GO_WORKSPACE/bin:$PATH"
    
    log_debug "gobrew environment configured"
    log_debug "PATH: $PATH"
    log_debug "GOPATH: $GOPATH" 
    log_debug "GOROOT: $(go env GOROOT 2>/dev/null || echo 'not set')"
}

# Check if Go version is already installed via gobrew
is_go_version_installed() {
    local version="$1"
    
    if [[ ! -f "$HOME/.gobrew/bin/gobrew" ]]; then
        return 1
    fi
    
    # If version is "latest", get the actual latest version and check if it's installed
    if [[ "$version" == "latest" ]]; then
        local latest_version
        latest_version=$("$HOME/.gobrew/bin/gobrew" ls-remote | grep -E "^go[0-9]+\.[0-9]+(\.[0-9]+)?$" | sort -V | tail -1 | sed 's/^go//')
        if [[ -n "$latest_version" ]]; then
            "$HOME/.gobrew/bin/gobrew" ls 2>/dev/null | grep -q "go${latest_version}"
            return $?
        fi
    else
        # Remove 'go' prefix if present for comparison
        version=${version#go}
        "$HOME/.gobrew/bin/gobrew" ls 2>/dev/null | grep -q "go${version}"
        return $?
    fi
    
    return 1
}

# Get latest Go version
get_latest_go_version() {
    log_debug "Fetching latest Go version"
    local version
    version=$(curl -s -L https://golang.org/VERSION?m=text | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 | sed 's/go//')
    
    if [[ -z "$version" ]]; then
        log_error "Failed to fetch latest Go version"
        exit 1
    fi
    
    echo "$version"
}

# Install Go version using gobrew  
install_go_version() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        log_info "No Go version specified, using latest"
        version="latest"
    else
        # Remove 'go' prefix if present
        version=${version#go}
    fi
    
    # Check if this specific version is already installed
    if is_go_version_installed "$version"; then
        log_info "Go version $version is already installed, switching to it"
        "$HOME/.gobrew/bin/gobrew" use "$version" || {
            log_error "Failed to switch to Go version $version"
            exit 1
        }
        log_success "Switched to existing Go $version installation"
    else
        log_step "Installing and setting Go version: $version"
        
        # Use 'gobrew use' which will install and set the version
        "$HOME/.gobrew/bin/gobrew" use "$version" || {
            log_error "Failed to install and set Go version $version"
            log_debug "Trying to debug gobrew installation..."
            log_debug "Gobrew directory: $HOME/.gobrew"
            log_debug "Gobrew binary exists: $(test -f "$HOME/.gobrew/bin/gobrew" && echo "yes" || echo "no")"
            if [[ -f "$HOME/.gobrew/bin/gobrew" ]]; then
                log_debug "Gobrew version: $("$HOME/.gobrew/bin/gobrew" version)"
            fi
            exit 1
        }
        
        log_success "Go $version installed and set successfully"
    fi
    
    # Re-source environment to ensure PATH is updated
    setup_gobrew_env
}

# Get installed protoc-gen-go version
get_installed_protoc_gen_go_version() {
    if command -v protoc-gen-go >/dev/null 2>&1; then
        # Try to get version from the binary
        protoc-gen-go --version 2>/dev/null | grep -o 'protoc-gen-go v[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/protoc-gen-go //' || echo ""
    else
        echo ""
    fi
}

# Get installed protoc-gen-go-grpc version  
get_installed_protoc_gen_go_grpc_version() {
    if command -v protoc-gen-go-grpc >/dev/null 2>&1; then
        # Try to get version from the binary
        protoc-gen-go-grpc --version 2>/dev/null | grep -o 'protoc-gen-go-grpc [0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/protoc-gen-go-grpc /v/' || echo ""
    else
        echo ""
    fi
}

# Check if specific version of protoc-gen-go is installed
is_protoc_gen_go_version_installed() {
    local required_version="$1"
    local installed_version
    
    installed_version=$(get_installed_protoc_gen_go_version)
    
    if [[ -n "$installed_version" ]] && [[ "$installed_version" == "$required_version" ]]; then
        return 0
    else
        return 1
    fi
}

# Check if specific version of protoc-gen-go-grpc is installed
is_protoc_gen_go_grpc_version_installed() {
    local required_version="$1"
    local installed_version
    
    installed_version=$(get_installed_protoc_gen_go_grpc_version)
    
    if [[ -n "$installed_version" ]] && [[ "$installed_version" == "$required_version" ]]; then
        return 0
    else
        return 1
    fi
}

# Install Go protobuf plugins
install_go_protobuf_plugins() {
    log_step "Installing Go protobuf plugins"
    
    # Verify Go is available
    if ! command -v go >/dev/null 2>&1; then
        log_error "Go command not found"
        log_debug "Current PATH: $PATH"
        log_debug "Gobrew current dir: $(ls -la $HOME/.gobrew/current/ 2>/dev/null || echo 'Not found')"
        exit 1
    fi
    
    # Set Go proxy to avoid potential connectivity issues
    export GOPROXY="https://proxy.golang.org,direct"
    export GOSUMDB="sum.golang.org"
    
    local protoc_gen_go_version="$PROTOC_GEN_GO_VERSION"
    local protoc_gen_go_grpc_version="$PROTOC_GEN_GO_GRPC_VERSION"
    local go_version="$GO_VERSION"
    
    # Resolve compatible versions based on Go version
    if [[ "$protoc_gen_go_version" == "latest" ]]; then
        protoc_gen_go_version=$(get_compatible_protoc_gen_go_version "$go_version")
        log_info "Auto-resolved protoc-gen-go version for Go $go_version: $protoc_gen_go_version"
    fi
    
    if [[ "$protoc_gen_go_grpc_version" == "latest" ]]; then
        protoc_gen_go_grpc_version=$(get_compatible_protoc_gen_go_grpc_version "$go_version")
        log_info "Auto-resolved protoc-gen-go-grpc version for Go $go_version: $protoc_gen_go_grpc_version"
    fi
    
    # Validate compatibility if user specified versions
    if [[ "$PROTOC_GEN_GO_VERSION" != "latest" ]] || [[ "$PROTOC_GEN_GO_GRPC_VERSION" != "latest" ]]; then
        local warnings
        warnings=$(validate_compatibility "$go_version" "$protoc_gen_go_version" "$protoc_gen_go_grpc_version")
        if [[ $warnings -gt 0 ]]; then
            log_info "Consider using compatible versions for better stability"
        fi
    fi
    
    # Check if plugins are already installed with correct versions (smart caching)
    local need_install=false
    local installed_protoc_gen_go_version
    local installed_protoc_gen_go_grpc_version
    
    installed_protoc_gen_go_version=$(get_installed_protoc_gen_go_version)
    installed_protoc_gen_go_grpc_version=$(get_installed_protoc_gen_go_grpc_version)
    
    if ! is_protoc_gen_go_version_installed "$protoc_gen_go_version"; then
        need_install=true
        if [[ -n "$installed_protoc_gen_go_version" ]]; then
            log_info "protoc-gen-go version mismatch: installed=$installed_protoc_gen_go_version, required=$protoc_gen_go_version"
        else
            log_info "protoc-gen-go not found, will install"
        fi
    else
        log_info "protoc-gen-go $protoc_gen_go_version already available, skipping installation"
    fi
    
    if ! is_protoc_gen_go_grpc_version_installed "$protoc_gen_go_grpc_version"; then
        need_install=true
        if [[ -n "$installed_protoc_gen_go_grpc_version" ]]; then
            log_info "protoc-gen-go-grpc version mismatch: installed=$installed_protoc_gen_go_grpc_version, required=$protoc_gen_go_grpc_version"
        else
            log_info "protoc-gen-go-grpc not found, will install"
        fi
    else
        log_info "protoc-gen-go-grpc $protoc_gen_go_grpc_version already available, skipping installation"
    fi
    
    if [[ "$need_install" == "true" ]]; then
        log_info "Installing missing or incompatible protobuf plugins..."
        
        if ! is_protoc_gen_go_version_installed "$protoc_gen_go_version"; then
            log_info "Installing protoc-gen-go@$protoc_gen_go_version"
            go install "google.golang.org/protobuf/cmd/protoc-gen-go@$protoc_gen_go_version" || {
                log_error "Failed to install protoc-gen-go"
                exit 1
            }
        fi
        
        if ! is_protoc_gen_go_grpc_version_installed "$protoc_gen_go_grpc_version"; then
            log_info "Installing protoc-gen-go-grpc@$protoc_gen_go_grpc_version"
            go install "google.golang.org/grpc/cmd/protoc-gen-go-grpc@$protoc_gen_go_grpc_version" || {
                log_error "Failed to install protoc-gen-go-grpc"
                exit 1
            }
        fi
    else
        log_info "All protobuf plugins already installed, skipping installation"
    fi
    
    # Update PATH to include GOPATH/bin for protoc plugins
    setup_gobrew_env
    
    # Verify plugins are installed and accessible
    log_debug "Verifying protoc plugins installation:"
    if command -v protoc-gen-go >/dev/null 2>&1; then
        log_debug "protoc-gen-go found at: $(which protoc-gen-go)"
    else
        log_error "protoc-gen-go not found in PATH"
    fi
    
    if command -v protoc-gen-go-grpc >/dev/null 2>&1; then
        log_debug "protoc-gen-go-grpc found at: $(which protoc-gen-go-grpc)"
    else
        log_error "protoc-gen-go-grpc not found in PATH"
    fi
    
    log_success "Go protobuf plugins installed successfully"
}

# Generate Go protobuf files
generate_protobuf_files() {
    log_step "Generating Go protobuf files"
    
    cd /home/src || {
        log_error "Failed to change to /home/src directory"
        exit 1
    }
    
    local proto_files
    log_debug "Looking for files with pattern '$PROTO_FILE_NAME' in directory '$PROTO_FILE_PATH'"
    proto_files=$(find "$PROTO_FILE_PATH" -name "$PROTO_FILE_NAME" 2>/dev/null)
    
    log_debug "Found proto files: $proto_files"
    
    if [[ -z "$proto_files" ]]; then
        log_warning "No proto files found matching pattern '$PROTO_FILE_NAME' in '$PROTO_FILE_PATH'"
        return 0
    fi
    
    local file_count=0
    while IFS= read -r proto_file; do
        log_info "Processing: $proto_file"
        
        local protoc_cmd="protoc --proto_path=\"$PROTO_FILE_PATH\" --go_out=\"$PROTO_OUT_PATH\" --go_opt=paths=source_relative --go-grpc_out=\"$PROTO_OUT_PATH\" --go-grpc_opt=paths=source_relative \"$proto_file\""
        log_debug "Running protoc command: $protoc_cmd"
        
        # Debug: check current directory and files
        log_debug "Current directory: $(pwd)"
        log_debug "Proto file exists: $(test -f "$proto_file" && echo "yes" || echo "no")"
        log_debug "Output directory exists: $(test -d "$PROTO_OUT_PATH" && echo "yes" || echo "no")"
        
        # Capture both stdout and stderr
        local protoc_output
        protoc_output=$(protoc \
            --proto_path="$PROTO_FILE_PATH" \
            --go_out="$PROTO_OUT_PATH" \
            --go_opt=paths=source_relative \
            --go-grpc_out="$PROTO_OUT_PATH" \
            --go-grpc_opt=paths=source_relative \
            "$proto_file" 2>&1)
        
        local exit_code=$?
        
        log_debug "protoc exit code: $exit_code"
        if [[ -n "$protoc_output" ]]; then
            log_debug "protoc output: $protoc_output"
        fi
        
        if [[ $exit_code -ne 0 ]]; then
            log_error "Failed to generate protobuf for: $proto_file (exit code: $exit_code)"
            if [[ -n "$protoc_output" ]]; then
                log_error "protoc error: $protoc_output"
            fi
            exit 1
        fi
        
        log_debug "Successfully processed: $proto_file"
        file_count=$((file_count + 1))
    done <<< "$proto_files"
    
    log_success "Generated protobuf files for $file_count proto file(s)"
    log_debug "generate_protobuf_files completed successfully"
}

# Main function for Go protobuf generation
generate_go_protobuf() {
    log_step "Starting Go protobuf generation"
    
    # Ensure system packages
    ensure_system_packages
    
    # Install and setup gobrew
    install_gobrew
    setup_gobrew_env
    
    # Install Go version
    install_go_version "$GO_VERSION"
    
    # Install Go protobuf plugins
    install_go_protobuf_plugins
    
    # Generate protobuf files
    generate_protobuf_files
    
    log_success "Go protobuf generation completed successfully"
}
