#!/usr/bin/env bash
# executor.sh - Bats test execution and result reporting
# Implements FR-004: Execute generated Bats tests and report results

set -euo pipefail

# Assumes utils.sh has already been sourced

# execute_bats_tests: Run Bats test file
# Args: $1 = bats file path, $2 = timeout (optional, default 300), $3 = tap output (optional, default false),
#       $4 = timing (optional, default false), $5 = trace (optional, default false), $6 = parallel jobs (optional, default 1)
# Returns: Bats exit code
execute_bats_tests() {
    local bats_file="$1"
    local timeout="${2:-300}"
    local tap_output="${3:-false}"
    local timing="${4:-false}"
    # trace is accepted for API compatibility but handled in test generation, not execution
    # shellcheck disable=SC2034
    local trace="${5:-false}"
    local parallel_jobs="${6:-1}"
    
    check_file_exists "${bats_file}" || return 1
    
    log_verbose "Executing Bats tests: ${bats_file} (timeout: ${timeout}s, parallel: ${parallel_jobs})"
    
    # Build bats command with optional flags
    # Note: trace is handled in test generation, not passed to bats
    local bats_cmd=("bats")
    if [ "${tap_output}" = true ]; then
        bats_cmd+=("--tap")
    fi
    if [ "${timing}" = true ]; then
        bats_cmd+=("--timing")
    fi
    if [ "${parallel_jobs}" -gt 1 ]; then
        # Check for parallel binary (required by Bats for --jobs)
        if ! command -v parallel >/dev/null 2>&1 && ! command -v rush >/dev/null 2>&1; then
            log_error "Parallel execution requires GNU parallel or shenwei356/rush to be installed"
            log_error "Install with: apt-get install parallel (Debian/Ubuntu) or brew install parallel (macOS)"
            return 2
        fi
        bats_cmd+=("--jobs" "${parallel_jobs}")
    fi
    
    # Check if timeout command is available
    if command -v timeout >/dev/null 2>&1; then
        # GNU timeout
        timeout "${timeout}s" "${bats_cmd[@]}" "${bats_file}"
    elif command -v gtimeout >/dev/null 2>&1; then
        # GNU timeout on macOS (installed via coreutils)
        gtimeout "${timeout}s" "${bats_cmd[@]}" "${bats_file}"
    else
        # No timeout available - run without timeout
        log_verbose "Warning: timeout command not available, running without timeout"
        "${bats_cmd[@]}" "${bats_file}"
    fi
    
    return $?
}

# parse_tap_output: Parse TAP output for summary statistics
# Args: stdin = TAP output
# Outputs: Summary statistics
parse_tap_output() {
    local total=0
    local passed=0
    local failed=0
    local skipped=0
    
    while IFS= read -r line; do
        if [[ "${line}" =~ ^1\.\.\.([0-9]+)$ ]]; then
            total="${BASH_REMATCH[1]}"
        elif [[ "${line}" =~ ^ok ]]; then
            if [[ "${line}" =~ \#\ skip ]]; then
                ((skipped++)) || true
            else
                ((passed++)) || true
            fi
        elif [[ "${line}" =~ ^not\ ok ]]; then
            ((failed++)) || true
        fi
    done
    
    echo "Total: ${total}"
    echo "Passed: ${passed}"
    echo "Failed: ${failed}"
    echo "Skipped: ${skipped}"
}

# report_results: Generate human-readable test results
# Args: $1 = exit code, $2 = TAP output file (optional)
report_results() {
    local exit_code="$1"
    local tap_file="${2:-}"
    
    if [ "${exit_code}" -eq 0 ]; then
        echo "✓ All tests passed"
    else
        echo "✗ Some tests failed (exit code: ${exit_code})"
    fi
    
    if [ -n "${tap_file}" ] && [ -f "${tap_file}" ]; then
        echo ""
        echo "Test Summary:"
        parse_tap_output < "${tap_file}"
        echo "Outputting tap file:"
        cat "${tap_file}"
    fi
}
