#!/bin/bash

set -e # Exit on error

echo "=========================================="
echo "      Universal Protobuf Generator        "
echo "=========================================="

# 1. Check if TARGET_LANG is set
if [[ -z "$TARGET_LANG" ]]; then
    echo "Error: TARGET_LANG environment variable is not set."
    echo "Please specify the target language (e.g., -e TARGET_LANG=go)."
    exit 1
fi

TARGET_LANG=$(echo "$TARGET_LANG" | tr '[:upper:]' '[:lower:]')
GENERATOR_SCRIPT="/opt/pb-gen/generators/${TARGET_LANG}.sh"

# 2. Check if generator for the target language exists
if [ ! -f "$GENERATOR_SCRIPT" ]; then
    echo "Error: Generator for language '$TARGET_LANG' is not supported yet."
    echo "Please contribute by adding $GENERATOR_SCRIPT to the repository!"
    exit 1
fi

# 3. Load utilities
source /opt/pb-gen/utils.sh

# 4. Install/Ensure protoc is ready
install_protoc

# 5. Route to the specific language generator
echo "Starting generation for language: $TARGET_LANG"
source "$GENERATOR_SCRIPT"
generate_${TARGET_LANG}

# 6. Fix ownership of generated files
fix_ownership

echo "=========================================="
echo "          Generation Completed!           "
echo "=========================================="
