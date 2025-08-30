#!/bin/bash

# Language-specific generator registry
# Manages available language generators and provides a factory pattern

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

readonly GENERATORS_DIR="$(dirname "${BASH_SOURCE[0]}")/../generators"

# Supported languages
readonly SUPPORTED_LANGUAGES=("go")

# Check if a language is supported
is_language_supported() {
    local lang="$1"
    
    for supported_lang in "${SUPPORTED_LANGUAGES[@]}"; do
        if [[ "$supported_lang" == "$lang" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Get the generator script path for a language
get_generator_path() {
    local lang="$1"
    echo "${GENERATORS_DIR}/${lang}_generator.sh"
}

# Validate that generator exists for the language
validate_generator() {
    local lang="$1"
    local generator_path
    
    if ! is_language_supported "$lang"; then
        log_error "Language '$lang' is not supported"
        log_info "Supported languages: ${SUPPORTED_LANGUAGES[*]}"
        exit 1
    fi
    
    generator_path=$(get_generator_path "$lang")
    
    if [[ ! -f "$generator_path" ]]; then
        log_error "Generator script not found: $generator_path"
        exit 1
    fi
    
    if [[ ! -x "$generator_path" ]]; then
        log_error "Generator script is not executable: $generator_path"
        exit 1
    fi
    
    log_debug "Generator validated: $generator_path"
    return 0
}

# Execute the appropriate generator
execute_generator() {
    local lang="$1"
    local generator_path
    
    validate_generator "$lang"
    generator_path=$(get_generator_path "$lang")
    
    log_step "Executing $lang generator"
    
    # Source and execute the generator
    source "$generator_path"
    
    if declare -f "generate_${lang}_protobuf" > /dev/null; then
        "generate_${lang}_protobuf"
    else
        log_error "Generator function 'generate_${lang}_protobuf' not found in $generator_path"
        exit 1
    fi
}

# List all supported languages
list_supported_languages() {
    log_info "Supported languages:"
    for lang in "${SUPPORTED_LANGUAGES[@]}"; do
        echo "  - $lang"
    done
}
