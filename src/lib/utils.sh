#!/usr/bin/env bash
# utils.sh - Utility functions for Bashi
# Includes dependency checking and common helpers

set -euo pipefail

# check_dependencies: Verify required external tools are available
# Exits with code 2 if any dependency is missing
check_dependencies() {
    local missing=()
    
    # Required: yq for YAML parsing
    if ! command -v yq >/dev/null 2>&1; then
        missing+=("yq")
    fi
    
    # Required: bats for test execution
    if ! command -v bats >/dev/null 2>&1; then
        missing+=("bats")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing required dependencies: ${missing[*]}" >&2
        echo "Please install:" >&2
        for dep in "${missing[@]}"; do
            case "${dep}" in
                yq)
                    echo "  yq: https://github.com/mikefarah/yq" >&2
                    ;;
                bats)
                    echo "  bats: https://github.com/bats-core/bats-core" >&2
                    ;;
            esac
        done
        return 2
    fi
    
    return 0
}

# check_file_exists: Verify file exists and is readable
# Args: $1 = file path
# Returns: 0 if exists, 1 if not
check_file_exists() {
    local file="$1"
    
    if [ ! -f "${file}" ]; then
        echo "Error: File not found: ${file}" >&2
        return 1
    fi
    
    if [ ! -r "${file}" ]; then
        echo "Error: File not readable: ${file}" >&2
        return 1
    fi
    
    return 0
}

# log_verbose: Print message if verbose mode enabled
# Args: $1 = message
log_verbose() {
    if [ "${BASHI_VERBOSE:-false}" = "true" ]; then
        echo "$1" >&2
    fi
}

# log_error: Print error message to stderr
# Args: $1 = message
log_error() {
    echo "Error: $1" >&2
}
