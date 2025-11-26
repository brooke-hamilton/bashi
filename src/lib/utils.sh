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

# expand_glob_pattern: Expand a single glob pattern to matching .bashi.yaml files
# Supports: **/*.bashi.yaml (recursive), *.bashi.yaml (single level)
# Args: $1 = glob pattern (e.g., "tests/**/*.bashi.yaml" or "tests/*.bashi.yaml")
# Outputs: Matching file paths, one per line (sorted)
# Returns: 0 if files found, 1 if no matches
expand_glob_pattern() {
    local pattern="$1"
    local files=()

    # If pattern is an existing file, return it directly
    if [ -f "${pattern}" ]; then
        echo "${pattern}"
        return 0
    fi

    # Extract directory and file pattern
    local dir
    local file_pattern
    local recursive=false

    if [[ "${pattern}" == *"**"* ]]; then
        # Recursive pattern: extract base dir before **
        dir="${pattern%%\*\**}"
        dir="${dir%/}"  # Remove trailing slash
        [ -z "${dir}" ] && dir="."
        file_pattern="${pattern##*\*\*/}"
        recursive=true
    else
        # Non-recursive: extract directory and filename pattern
        dir=$(dirname "${pattern}")
        file_pattern=$(basename "${pattern}")
    fi

    # Validate directory exists
    if [ ! -d "${dir}" ]; then
        log_error "Directory not found: ${dir}"
        return 1
    fi

    # Convert glob pattern to find -name pattern
    # The file pattern should already be in find-compatible format (e.g., *.bashi.yaml)
    local find_args=()
    if [ "${recursive}" = true ]; then
        find_args=("${dir}" -type f -name "${file_pattern}")
    else
        find_args=("${dir}" -maxdepth 1 -type f -name "${file_pattern}")
    fi

    # Execute find and collect results
    while IFS= read -r file; do
        [ -n "${file}" ] && files+=("${file}")
    done < <(find "${find_args[@]}" 2>/dev/null | sort)

    if [ ${#files[@]} -eq 0 ]; then
        log_error "No files matched pattern: ${pattern}"
        return 1
    fi

    # Output sorted file list
    printf '%s\n' "${files[@]}"
    return 0
}

# expand_glob_patterns: Expand multiple glob patterns or file paths
# Args: $@ = list of patterns/files
# Outputs: Unique matching file paths, one per line (sorted)
# Returns: 0 if at least one file found, 1 if no matches
expand_glob_patterns() {
    local all_files=()
    local pattern

    for pattern in "$@"; do
        local matched_files
        if matched_files=$(expand_glob_pattern "${pattern}"); then
            while IFS= read -r file; do
                [ -n "${file}" ] && all_files+=("${file}")
            done <<< "${matched_files}"
        fi
        # Continue processing remaining patterns even if one fails
    done

    if [ ${#all_files[@]} -eq 0 ]; then
        log_error "No test files found"
        return 1
    fi

    # Remove duplicates and sort
    printf '%s\n' "${all_files[@]}" | sort -u
    return 0
}
