#!/bin/bash

# ==========================================
# GO GENERATOR
# ==========================================

generate_go() {
    # 1. INSTALL GO (using gobrew)
    if [[ -z "$GO_VERSION" ]]; then
        echo "GO_VERSION is not set. Using 'latest'..."
        gobrew use latest
    else
        echo "Using Go version: $GO_VERSION"
        gobrew use "$GO_VERSION"
    fi

    # Set GOPATH to gobrew's environment
    export GOPATH="$HOME/.gobrew/current/go"
    
    # Strictly enforce local toolchain to prevent Go from silently downloading newer versions
    export GOTOOLCHAIN=local

    # 2. INSTALL PROTOC PLUGINS (These will be cached in GOPATH)
    local GEN_GO_VERSION=${PROTOC_GEN_GO_VERSION:-latest}
    local GEN_GO_GRPC_VERSION=${PROTOC_GEN_GO_GRPC_VERSION:-latest}

    echo "Installing protoc-gen-go@$GEN_GO_VERSION and protoc-gen-go-grpc@$GEN_GO_GRPC_VERSION..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@$GEN_GO_VERSION
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$GEN_GO_GRPC_VERSION

    # 3. GENERATE PROTOBUF
    cd /home/src

    local FILE_NAME=${PROTO_FILE_NAME:-*.proto}
    local FILE_PATH=${PROTO_FILE_PATH:-.}
    local OUT_PATH=${PROTO_OUT_PATH:-.}

    echo "Generating protobuf files for Go in $OUT_PATH..."
    find . -name "$FILE_NAME" -exec protoc \
        --proto_path="$FILE_PATH" \
        --go_out="$OUT_PATH" \
        --go_opt=paths=source_relative \
        --go-grpc_out="$OUT_PATH" \
        --go-grpc_opt=paths=source_relative {} \;
}
