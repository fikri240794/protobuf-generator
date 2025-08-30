#!/bin/bash

# Main entry point for protobuf generation
# Orchestrates the entire protobuf generation process using clean architecture

set -euo pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core modules
source "${SCRIPT_DIR}/core/logger.sh"
source "${SCRIPT_DIR}/core/env_validator.sh"
source "${SCRIPT_DIR}/core/protoc_manager.sh"
source "${SCRIPT_DIR}/core/version_compatibility.sh"
source "${SCRIPT_DIR}/core/generator_registry.sh"
source "${SCRIPT_DIR}/utils/system_utils.sh"

# Cleanup function for graceful shutdown
cleanup() {
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Protobuf generation completed successfully"
    else
        log_error "Protobuf generation failed with exit code: $exit_code"
    fi
    
    cleanup_temp_files
    exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT

# Main function
main() {
    log_step "Starting protobuf generator"
    log_info "Protobuf Generator v2.0 - Clean Architecture Edition"
    
    # Validate and set environment variables
    validate_and_set_env
    
    # Validate paths
    if ! validate_paths; then
        log_error "Path validation failed"
        exit 1
    fi
    
    # Ensure system packages are installed
    ensure_system_packages
    
    # Determine protoc version to use
    local protoc_version_to_use="$PROTOC_VERSION"
    if [[ "$PROTOC_VERSION" == "latest" ]] && [[ "$LANG" == "go" ]]; then
        # Use smart compatibility resolution for Go
        protoc_version_to_use=$(get_compatible_protoc_version "$GO_VERSION")
        log_info "Auto-resolved protoc version $protoc_version_to_use for Go $GO_VERSION"
    fi
    
    # Ensure protoc is installed and ready
    ensure_protoc "$protoc_version_to_use"
    
    # Execute the appropriate language generator
    execute_generator "$LANG"
    
    log_success "All operations completed successfully"
}

# Execute main function
main "$@"
