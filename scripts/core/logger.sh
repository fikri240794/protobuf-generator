#!/bin/bash

# Logger utility for consistent logging across the application
# Provides different log levels with colors and timestamps

# Prevent double sourcing
if [[ -n "${LOGGER_LOADED:-}" ]]; then
    return 0
fi
export LOGGER_LOADED=1

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Log info message
log_info() {
    local message="$1"
    echo -e "${CYAN}[$(get_timestamp)] [INFO]${NC} $message"
}

# Log success message
log_success() {
    local message="$1"
    echo -e "${GREEN}[$(get_timestamp)] [SUCCESS]${NC} $message"
}

# Log warning message
log_warning() {
    local message="$1"
    echo -e "${YELLOW}[$(get_timestamp)] [WARNING]${NC} $message"
}

# Log error message
log_error() {
    local message="$1"
    echo -e "${RED}[$(get_timestamp)] [ERROR]${NC} $message" >&2
}

# Log debug message (only if DEBUG=1)
log_debug() {
    local message="$1"
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${PURPLE}[$(get_timestamp)] [DEBUG]${NC} $message"
    fi
}

# Log step message (for major steps)
log_step() {
    local message="$1"
    echo -e "${BLUE}[$(get_timestamp)] [STEP]${NC} $message"
}
