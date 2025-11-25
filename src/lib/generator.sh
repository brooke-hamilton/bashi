#!/usr/bin/env bash
# generator.sh - Bats test code generation
# Implements FR-003: Generate Bats test files from processed YAML

set -euo pipefail

# Assumes utils.sh has already been sourced

# generate_bats_header: Create Bats file header
# Args: $1 = suite name
generate_bats_header() {
    local suite_name="$1"
    
    cat <<EOF
#!/usr/bin/env bats
# Auto-generated from Bashi test suite: ${suite_name}
# Generated at: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

setup() {
    # Test-specific setup will be added here
    export TEST_TEMP_DIR="\${BATS_TEST_TMPDIR}/bashi-\${BATS_TEST_NUMBER}"
    mkdir -p "\$TEST_TEMP_DIR"
}

teardown() {
    # Test-specific teardown will be added here
    if [ -d "\${TEST_TEMP_DIR}" ]; then
        rm -rf "\${TEST_TEMP_DIR}"
    fi
}

EOF
}

# generate_bats_test: Generate a single Bats test
# Reads test properties from associative array-like parameters
generate_bats_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit="${3:-0}"
    local trace_mode="${4:-false}"
    local skip_test="${5:-false}"
    shift 5
    
    # Start test
    cat <<EOF
@test "${test_name}" {
EOF

    # Add skip if enabled
    if [ "${skip_test}" = "true" ]; then
        echo "    skip"
        echo "}"
        echo ""
        return
    fi

    # Add trace output if enabled
    if [ "${trace_mode}" = true ]; then
        cat <<'EOF'
    # Trace output
    echo "" >&3
    echo "# Running test: $BATS_TEST_DESCRIPTION" >&3
EOF
        # For trace, show command with actual newlines for readability
        local display_command="${test_command}"
        # shellcheck disable=SC2001
        display_command=$(echo "${display_command}" | sed 's/\\n/\n/g')
        echo "    echo '# Command: ${display_command}' >&3"
    fi
    
    # Escape the command properly for bash -c with double quotes
    # Need to escape backslashes, double quotes, dollar signs, and backticks
    local escaped_command="${test_command}"
    escaped_command="${escaped_command//\\/\\\\}"  # Escape backslashes first
    escaped_command="${escaped_command//\"/\\\"}"  # Escape double quotes
    escaped_command="${escaped_command//\$/\\\$}"  # Escape dollar signs
    escaped_command="${escaped_command//\`/\\\`}"  # Escape backticks
    # Now decode the \n to actual newlines using printf
    # shellcheck disable=SC2001
    escaped_command=$(printf '%b' "${escaped_command}")
    
    cat <<EOF
    # Execute command and capture output
    run bash -c "${escaped_command}"
    
EOF

    # Add trace output for results if enabled
    if [ "${trace_mode}" = true ]; then
        cat <<'EOF'
    # Trace results
    echo "# Exit code: $status" >&3
    if [ -n "$output" ]; then
        echo "# Output:" >&3
        echo "$output" | sed 's/^/# /' >&3
    fi
    echo "" >&3
    
EOF
    fi
    
    # Exit code assertion (always check)
    echo "    # Verify exit code"
    echo "    if [ \$status -ne ${expected_exit} ]; then"
    echo "        echo \"exit code: expected: ${expected_exit}, actual: \$status\" >&2"
    echo "        return 1"
    echo "    fi"
    echo ""
    
    # Generate additional assertions from remaining args
    while [ $# -gt 0 ]; do
        echo "    $1"
        shift
    done
    
    echo "}"
    echo ""
}

# generate_bats_file: Generate complete Bats file from processed test data
# Args: $1 = suite name, $2 = output file path, $3 = trace mode (optional, default false), stdin = processed test data
generate_bats_file() {
    local suite_name="$1"
    local output_file="$2"
    local trace_mode="${3:-false}"
    
    log_verbose "Generating Bats file: ${output_file}"
    
    # Read all processed test data and organize by test
    local current_test_name=""
    local current_test_command=""
    local current_exit_code="0"
    local current_skip="false"
    local current_assertions=()
    
    {
        generate_bats_header "${suite_name}"
        
        while IFS= read -r line; do
            if [[ "${line}" =~ ^TEST:([0-9]+):name=(.+)$ ]]; then
                # New test starting - output previous test if exists
                if [ -n "${current_test_name}" ]; then
                    generate_bats_test "${current_test_name}" "${current_test_command}" "${current_exit_code}" "${trace_mode}" "${current_skip}" "${current_assertions[@]}"
                fi
                
                # Reset for new test
                current_test_name="${BASH_REMATCH[2]}"
                current_test_command=""
                current_exit_code="0"
                current_skip="false"
                current_assertions=()
                
            elif [[ "${line}" =~ ^TEST:[0-9]+:command=(.+)$ ]]; then
                current_test_command="${BASH_REMATCH[1]}"
                # Decode literal \n back to actual newlines
                # shellcheck disable=SC2001
                current_test_command=$(echo "${current_test_command}" | sed 's/\\n/\n/g')
                
            elif [[ "${line}" =~ ^TEST:[0-9]+:exitCode=(.+)$ ]]; then
                current_exit_code="${BASH_REMATCH[1]}"
                
            elif [[ "${line}" =~ ^TEST:[0-9]+:outputContains=(.+)$ ]]; then
                local contains="${BASH_REMATCH[1]}"
                current_assertions+=("# Verify stdout contains expected text")
                current_assertions+=("[[ \"\$output\" == *\"${contains}\"* ]]")
                current_assertions+=("")
                
            elif [[ "${line}" =~ ^TEST:[0-9]+:outputEquals=(.+)$ ]]; then
                local equals="${BASH_REMATCH[1]}"
                current_assertions+=("# Verify stdout equals expected value")
                current_assertions+=("[ \"\$output\" = \"${equals}\" ]")
                current_assertions+=("")
                
            elif [[ "${line}" =~ ^TEST:[0-9]+:outputMatches=(.+)$ ]]; then
                local matches="${BASH_REMATCH[1]}"
                # Strip surrounding quotes if present
                matches="${matches#\"}"
                matches="${matches%\"}"
                current_assertions+=("# Verify stdout matches regex")
                current_assertions+=("local regex='${matches}'")
                current_assertions+=("[[ \"\$output\" =~ \$regex ]]")
                current_assertions+=("")
                
            elif [[ "${line}" =~ ^TEST:[0-9]+:stderr=(.+)$ ]]; then
                local stderr_val="${BASH_REMATCH[1]}"
                current_assertions+=("# Verify stderr output")
                current_assertions+=("[ \"\${lines[0]}\" = \"${stderr_val}\" ] || [[ \"\$output\" == *\"${stderr_val}\"* ]]")
                current_assertions+=("")
                
            elif [[ "${line}" =~ ^TEST:[0-9]+:skip=(.+)$ ]]; then
                current_skip="${BASH_REMATCH[1]}"
            fi
        done
        
        # Output final test
        if [ -n "${current_test_name}" ]; then
            generate_bats_test "${current_test_name}" "${current_test_command}" "${current_exit_code}" "${trace_mode}" "${current_skip}" "${current_assertions[@]}"
        fi
    } > "${output_file}"
    
    # Make executable
    chmod +x "${output_file}"
    
    log_verbose "Generated Bats file: ${output_file}"
}
