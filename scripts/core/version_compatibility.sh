#!/bin/bash

# Go Version Compatibility Matrix
# This file defines compatible versions of protobuf tools for different Go versions

# Get compatible protoc-gen-go version for a Go version
get_compatible_protoc_gen_go_version() {
    local go_version="$1"
    local go_major_minor
    
    # If version is "latest", resolve to actual installed version first
    if [[ "$go_version" == "latest" ]]; then
        if command -v go >/dev/null 2>&1; then
            go_version=$(go version 2>/dev/null | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/go//' | head -1)
            if [[ -z "$go_version" ]]; then
                go_version="1.25.0"  # fallback to latest stable
            fi
        else
            go_version="1.25.0"  # fallback to latest stable
        fi
    fi
    
    # Extract major.minor version (e.g., "1.21" from "1.21.0")
    go_major_minor=$(echo "$go_version" | sed 's/\([0-9]*\.[0-9]*\).*/\1/')
    
    case "$go_major_minor" in
        "1.25")
            # Latest versions for Go 1.25
            echo "v1.35.2"
            ;;
        "1.24"|"1.23")
            # Latest versions work with Go 1.23+
            echo "v1.34.2"
            ;;
        "1.22"|"1.21")
            # Compatible versions for Go 1.21-1.22
            echo "v1.31.0"
            ;;
        "1.20"|"1.19")
            # Compatible versions for Go 1.19-1.20
            echo "v1.28.1"
            ;;
        "1.18"|"1.17")
            # Compatible versions for Go 1.17-1.18
            echo "v1.27.1"
            ;;
        "1.16"|"1.15")
            # Compatible versions for Go 1.15-1.16
            echo "v1.25.0"
            ;;
        "1.14"|"1.13")
            # Compatible versions for Go 1.13-1.14
            echo "v1.23.0"
            ;;
        *)
            # Default to a stable version for unknown/very old versions
            echo "v1.27.1"
            ;;
    esac
}

# Get compatible protoc-gen-go-grpc version for a Go version
get_compatible_protoc_gen_go_grpc_version() {
    local go_version="$1"
    local go_major_minor
    
    # If version is "latest", resolve to actual installed version first
    if [[ "$go_version" == "latest" ]]; then
        if command -v go >/dev/null 2>&1; then
            go_version=$(go version 2>/dev/null | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/go//' | head -1)
            if [[ -z "$go_version" ]]; then
                go_version="1.25.0"  # fallback to latest stable
            fi
        else
            go_version="1.25.0"  # fallback to latest stable
        fi
    fi
    
    # Extract major.minor version (e.g., "1.21" from "1.21.0")
    go_major_minor=$(echo "$go_version" | sed 's/\([0-9]*\.[0-9]*\).*/\1/')
    
    case "$go_major_minor" in
        "1.25")
            # Latest versions for Go 1.25
            echo "v1.5.1"
            ;;
        "1.24"|"1.23")
            # Latest versions work with Go 1.23+
            echo "v1.5.1"
            ;;
        "1.22"|"1.21")
            # Compatible versions for Go 1.21-1.22
            echo "v1.3.0"
            ;;
        "1.20"|"1.19")
            # Compatible versions for Go 1.19-1.20
            echo "v1.2.0"
            ;;
        "1.18"|"1.17")
            # Compatible versions for Go 1.17-1.18
            echo "v1.1.0"
            ;;
        "1.16"|"1.15")
            # Compatible versions for Go 1.15-1.16
            echo "v1.0.1"
            ;;
        "1.14"|"1.13")
            # Compatible versions for Go 1.13-1.14
            echo "v1.0.0"
            ;;
        *)
            # Default to a stable version for unknown/very old versions
            echo "v1.1.0"
            ;;
    esac
}

# Get compatible protoc version for a Go version
get_compatible_protoc_version() {
    local go_version="$1"
    local go_major_minor
    
    # If version is "latest", resolve to actual installed version first
    if [[ "$go_version" == "latest" ]]; then
        if command -v go >/dev/null 2>&1; then
            go_version=$(go version 2>/dev/null | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/go//' | head -1)
            if [[ -z "$go_version" ]]; then
                go_version="1.25.0"  # fallback to latest stable
            fi
        else
            go_version="1.25.0"  # fallback to latest stable
        fi
    fi
    
    # Extract major.minor version (e.g., "1.21" from "1.21.0")
    go_major_minor=$(echo "$go_version" | sed 's/\([0-9]*\.[0-9]*\).*/\1/')
    
    case "$go_major_minor" in
        "1.25")
            # Latest protoc works with Go 1.25
            echo "28.3"
            ;;
        "1.24"|"1.23")
            # Latest protoc works with Go 1.23+
            echo "25.1"
            ;;
        "1.22"|"1.21")
            # Compatible protoc for Go 1.21-1.22
            echo "24.4"
            ;;
        "1.20"|"1.19")
            # Compatible protoc for Go 1.19-1.20
            echo "23.4"
            ;;
        "1.18"|"1.17")
            # Compatible protoc for Go 1.17-1.18
            echo "21.12"
            ;;
        "1.16"|"1.15")
            # Compatible protoc for Go 1.15-1.16
            echo "21.7"
            ;;
        "1.14"|"1.13")
            # Compatible protoc for Go 1.13-1.14
            echo "21.1"
            ;;
        *)
            # Default to a stable version for unknown/very old versions
            echo "21.12"
            ;;
    esac
}

# Display compatibility information
show_compatibility_info() {
    local go_version="$1"
    
    echo "Go Version: $go_version"
    echo "Compatible versions:"
    echo "  - protoc: $(get_compatible_protoc_version "$go_version")"
    echo "  - protoc-gen-go: $(get_compatible_protoc_gen_go_version "$go_version")"
    echo "  - protoc-gen-go-grpc: $(get_compatible_protoc_gen_go_grpc_version "$go_version")"
}

# Check if the provided versions are compatible with Go version
validate_compatibility() {
    local go_version="$1"
    local protoc_gen_go_version="$2"
    local protoc_gen_go_grpc_version="$3"
    
    local recommended_protoc_gen_go
    local recommended_protoc_gen_go_grpc
    
    recommended_protoc_gen_go=$(get_compatible_protoc_gen_go_version "$go_version")
    recommended_protoc_gen_go_grpc=$(get_compatible_protoc_gen_go_grpc_version "$go_version")
    
    local warnings=0
    
    if [[ "$protoc_gen_go_version" == "latest" ]]; then
        echo "WARNING: Using 'latest' protoc-gen-go with Go $go_version may cause compatibility issues."
        echo "Recommended version: $recommended_protoc_gen_go"
        warnings=$((warnings + 1))
    fi
    
    if [[ "$protoc_gen_go_grpc_version" == "latest" ]]; then
        echo "WARNING: Using 'latest' protoc-gen-go-grpc with Go $go_version may cause compatibility issues."
        echo "Recommended version: $recommended_protoc_gen_go_grpc"
        warnings=$((warnings + 1))
    fi
    
    return $warnings
}

# Auto-resolve compatible versions based on Go version
resolve_compatible_versions() {
    local go_version="$1"
    
    export AUTO_PROTOC_VERSION
    export AUTO_PROTOC_GEN_GO_VERSION
    export AUTO_PROTOC_GEN_GO_GRPC_VERSION
    
    AUTO_PROTOC_VERSION=$(get_compatible_protoc_version "$go_version")
    AUTO_PROTOC_GEN_GO_VERSION=$(get_compatible_protoc_gen_go_version "$go_version")
    AUTO_PROTOC_GEN_GO_GRPC_VERSION=$(get_compatible_protoc_gen_go_grpc_version "$go_version")
    
    echo "Auto-resolved compatible versions for Go $go_version:"
    echo "  - protoc: $AUTO_PROTOC_VERSION"
    echo "  - protoc-gen-go: $AUTO_PROTOC_GEN_GO_VERSION"
    echo "  - protoc-gen-go-grpc: $AUTO_PROTOC_GEN_GO_GRPC_VERSION"
}
