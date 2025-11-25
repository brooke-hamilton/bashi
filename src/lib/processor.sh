#!/usr/bin/env bash
# processor.sh - YAML processing and variable substitution

set -euo pipefail

# Assumes utils.sh has already been sourced

# declare associative arrays for variable storage (Bash 4+)
# For Bash 3.2 compatibility, we'll use a different approach with indexed arrays

# extract_variables: Extract variables from YAML file
# Args: $1 = YAML file path
# Outputs: Variable definitions (name=value pairs)
extract_variables() {
    local yaml_file="$1"
    
    log_verbose "Extracting variables from ${yaml_file}"
    
    # Check if variables section exists
    local has_vars
    has_vars=$(yq eval '.variables' "${yaml_file}")
    
    if [ "${has_vars}" = "null" ]; then
        return 0
    fi
    
    # Output each variable as name=value
    yq eval '.variables | to_entries | .[] | .key + "=" + .value' "${yaml_file}"
}

# substitute_variables: Replace {{var}} placeholders with values
# Args: $1 = input string, $2+ = variable definitions (name=value)
# Outputs: String with substitutions applied
substitute_variables() {
    local input="$1"
    shift
    
    local result="${input}"
    
    # Process each variable definition
    while [ $# -gt 0 ]; do
        local var_def="$1"
        shift
        
        # Split on first = to get name and value
        local var_name="${var_def%%=*}"
        local var_value="${var_def#*=}"
        
        # Replace all occurrences of {{var_name}} with value
        # Using sed for Bash 3.2 compatibility (${var//pattern/replace} has issues with special chars)
        # shellcheck disable=SC2001
        result=$(echo "${result}" | sed "s|{{${var_name}}}|${var_value}|g")
    done
    
    echo "${result}"
}

# process_test_suite: Process YAML file and resolve all variables
# Args: $1 = YAML file path
# Outputs: Resolved test definitions (simple format)
process_test_suite() {
    local yaml_file="$1"
    
    log_verbose "Processing test suite: ${yaml_file}"
    
    # Extract variables into an array
    local vars_array=()
    while IFS= read -r line; do
        [ -n "${line}" ] && vars_array+=("${line}")
    done < <(extract_variables "${yaml_file}")
    
    # Get test count
    local test_count
    test_count=$(yq eval '.tests | length' "${yaml_file}")
    
    # Process each test
    for ((i=0; i<test_count; i++)); do
        local test_name
        test_name=$(yq eval ".tests[${i}].name" "${yaml_file}")
        
        local test_command
        test_command=$(yq eval ".tests[${i}].command" "${yaml_file}")
        
        # Apply variable substitution to command
        test_command=$(substitute_variables "${test_command}" "${vars_array[@]}")
        
        # Output processed test info
        echo "TEST:${i}:name=${test_name}"
        echo "TEST:${i}:command=${test_command}"
        
        # Process optional fields
        local exit_code
        exit_code=$(yq eval ".tests[${i}].exitCode" "${yaml_file}")
        if [ "${exit_code}" != "null" ]; then
            echo "TEST:${i}:exitCode=${exit_code}"
        fi
        
        local output_contains
        output_contains=$(yq eval ".tests[${i}].outputContains[]" "${yaml_file}" 2>/dev/null || true)
        if [ -n "${output_contains}" ]; then
            while IFS= read -r line; do
                [ -n "${line}" ] && echo "TEST:${i}:outputContains=$(substitute_variables "${line}" "${vars_array[@]}")"
            done <<< "${output_contains}"
        fi
        
        local output_equals
        output_equals=$(yq eval ".tests[${i}].outputEquals" "${yaml_file}")
        if [ "${output_equals}" != "null" ]; then
            output_equals=$(substitute_variables "${output_equals}" "${vars_array[@]}")
            echo "TEST:${i}:outputEquals=${output_equals}"
        fi
        
        local output_matches
        output_matches=$(yq eval ".tests[${i}].outputMatches" "${yaml_file}")
        if [ "${output_matches}" != "null" ]; then
            output_matches=$(substitute_variables "${output_matches}" "${vars_array[@]}")
            echo "TEST:${i}:outputMatches=${output_matches}"
        fi
        
        local stderr_val
        stderr_val=$(yq eval ".tests[${i}].stderr" "${yaml_file}")
        if [ "${stderr_val}" != "null" ]; then
            stderr_val=$(substitute_variables "${stderr_val}" "${vars_array[@]}")
            echo "TEST:${i}:stderr=${stderr_val}"
        fi
        
        local skip_val
        skip_val=$(yq eval ".tests[${i}].skip" "${yaml_file}")
        if [ "${skip_val}" != "null" ]; then
            echo "TEST:${i}:skip=${skip_val}"
        fi
        
        local timeout_val
        timeout_val=$(yq eval ".tests[${i}].timeout" "${yaml_file}")
        if [ "${timeout_val}" != "null" ]; then
            echo "TEST:${i}:timeout=${timeout_val}"
        fi
    done
}
