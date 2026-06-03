#!/bin/bash

# ==========================================
# UTILITY FUNCTIONS
# ==========================================

get_protoc_arch() {
    local ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        echo "linux-x86_64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        echo "linux-aarch_64"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
}

install_protoc() {
    # INSTALL PROTOC (with caching)
    if [[ -z "$PROTOC_VERSION" ]]; then
        # Use jq which is installed in the Dockerfile for safer JSON parsing
        export PROTOC_VERSION=$(curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | jq -r .tag_name | sed 's/v//')
    fi

    local PROTOC_ARCH=$(get_protoc_arch)
    local PROTOC_DIR="/root/protoc/$PROTOC_VERSION"
    
    if [ ! -d "$PROTOC_DIR" ]; then
        echo "Installing protoc version $PROTOC_VERSION for $PROTOC_ARCH..."
        mkdir -p "$PROTOC_DIR"
        curl -o /tmp/protoc.zip -LO "https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-$PROTOC_ARCH.zip"
        unzip -q /tmp/protoc.zip -d "$PROTOC_DIR"
        rm /tmp/protoc.zip
    else
        echo "protoc version $PROTOC_VERSION is already cached."
    fi

    # Add the specific version's bin to PATH
    export PATH="$PROTOC_DIR/bin:$PATH"
}

fix_ownership() {
    # FIX FILE OWNERSHIP
    # Since the container runs as root, files generated in the mounted volume will be owned by root.
    # We change ownership back to the host user's UID/GID.
    if [ -d "/home/src" ]; then
        local HOST_UID=$(stat -c "%u" /home/src)
        local HOST_GID=$(stat -c "%g" /home/src)
        if [ "$HOST_UID" != "0" ]; then
            chown -R $HOST_UID:$HOST_GID /home/src
        fi
    fi
}
