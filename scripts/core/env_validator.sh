#!/bin/bash

# Environment variable validator and processor
# Validates and sets default values for environment variables

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# Default values
readonly DEFAULT_PROTO_FILE_PATH="."
readonly DEFAULT_PROTO_FILE_NAME="*.proto"
readonly DEFAULT_PROTO_OUT_PATH="."
readonly DEFAULT_PROTOC_VERSION="latest"
readonly DEFAULT_PROTOC_GEN_GO_VERSION="latest"
readonly DEFAULT_PROTOC_GEN_GO_GRPC_VERSION="latest"

# Validate and set environment variables
validate_and_set_env() {
    log_step "Validating environment variables"
    
    # Set defaults if not provided
    export PROTO_FILE_PATH="${PROTO_FILE_PATH:-$DEFAULT_PROTO_FILE_PATH}"
    export PROTO_FILE_NAME="${PROTO_FILE_NAME:-$DEFAULT_PROTO_FILE_NAME}"
    export PROTO_OUT_PATH="${PROTO_OUT_PATH:-$DEFAULT_PROTO_OUT_PATH}"
    export PROTOC_VERSION="${PROTOC_VERSION:-$DEFAULT_PROTOC_VERSION}"
    export PROTOC_GEN_GO_VERSION="${PROTOC_GEN_GO_VERSION:-$DEFAULT_PROTOC_GEN_GO_VERSION}"
    export PROTOC_GEN_GO_GRPC_VERSION="${PROTOC_GEN_GO_GRPC_VERSION:-$DEFAULT_PROTOC_GEN_GO_GRPC_VERSION}"
    
    # Validate required environment for Go
    if [[ "$LANG" == "go" ]]; then
        if [[ -z "$GO_VERSION" ]]; then
            log_warning "GO_VERSION not specified, will use latest available"
        fi
    fi
    
    log_info "LANG: ${LANG}"
    log_info "PROTO_FILE_PATH: ${PROTO_FILE_PATH}"
    log_info "PROTO_FILE_NAME: ${PROTO_FILE_NAME}"
    log_info "PROTO_OUT_PATH: ${PROTO_OUT_PATH}"
    
    if [[ "$LANG" == "go" ]]; then
        log_info "GO_VERSION: ${GO_VERSION:-latest}"
        log_info "PROTOC_VERSION: ${PROTOC_VERSION}"
        log_info "PROTOC_GEN_GO_VERSION: ${PROTOC_GEN_GO_VERSION}"
        log_info "PROTOC_GEN_GO_GRPC_VERSION: ${PROTOC_GEN_GO_GRPC_VERSION}"
    fi
}

# Check if required paths exist in the source directory
validate_paths() {
    log_step "Validating paths"
    
    cd /home/src || {
        log_error "Failed to change to /home/src directory"
        exit 1
    }
    
    if [[ ! -d "$PROTO_FILE_PATH" ]]; then
        log_error "Proto file path '$PROTO_FILE_PATH' does not exist"
        exit 1
    fi
    
    # Create output directory if it doesn't exist
    if [[ ! -d "$PROTO_OUT_PATH" ]]; then
        log_info "Creating output directory: $PROTO_OUT_PATH"
        mkdir -p "$PROTO_OUT_PATH" || {
            log_error "Failed to create output directory: $PROTO_OUT_PATH"
            exit 1
        }
    fi
    
    # Check if there are any proto files to process
    local proto_files
    proto_files=$(find "$PROTO_FILE_PATH" -name "$PROTO_FILE_NAME" 2>/dev/null)
    if [[ -z "$proto_files" ]]; then
        log_error "No proto files found matching pattern '$PROTO_FILE_NAME' in '$PROTO_FILE_PATH'"
        log_info "Available files in '$PROTO_FILE_PATH':"
        ls -la "$PROTO_FILE_PATH" || log_info "Directory is empty or inaccessible"
        exit 1
    fi
    
    log_success "Path validation completed"
    return 0
}
