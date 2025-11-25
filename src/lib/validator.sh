#!/usr/bin/env bash
# validator.sh - YAML validation against schema

set -euo pipefail

# Assumes utils.sh and PROJECT_ROOT have already been set

# validate_yaml_syntax: Check if file is valid YAML
# Args: $1 = YAML file path
# Returns: 0 if valid, 1 if invalid
validate_yaml_syntax() {
    local yaml_file="$1"
    
    log_verbose "Validating YAML syntax: ${yaml_file}"
    
    if ! yq eval '.' "${yaml_file}" >/dev/null 2>&1; then
        log_error "Invalid YAML syntax in ${yaml_file}"
        return 1
    fi
    
    return 0
}

# validate_schema: Validate YAML against bashi-schema.json
# Args: $1 = YAML file path
# Returns: 0 if valid, 1 if invalid
validate_schema() {
    local yaml_file="$1"
    local schema_file="${PROJECT_ROOT}/src/bashi-schema.json"
    
    check_file_exists "${yaml_file}" || return 1
    check_file_exists "${schema_file}" || return 1
    
    log_verbose "Validating against schema: ${schema_file}"
    
    # First check YAML syntax
    validate_yaml_syntax "${yaml_file}" || return 1
    
    # Validate required top-level fields
    local name
    name=$(yq eval '.name' "${yaml_file}")
    if [ "${name}" = "null" ] || [ -z "${name}" ]; then
        log_error "Missing required field: name"
        return 1
    fi
    
    local tests
    tests=$(yq eval '.tests' "${yaml_file}")
    if [ "${tests}" = "null" ]; then
        log_error "Missing required field: tests"
        return 1
    fi
    
    # Validate tests is an array
    if ! yq eval '.tests | type' "${yaml_file}" | grep -q '!!seq'; then
        log_error "Field 'tests' must be an array"
        return 1
    fi
    
    # Validate each test has required fields
    local test_count
    test_count=$(yq eval '.tests | length' "${yaml_file}")
    
    if [ "${test_count}" -eq 0 ]; then
        log_error "At least one test is required"
        return 1
    fi
    
    local i
    for ((i=0; i<test_count; i++)); do
        # Check name field
        local test_name
        test_name=$(yq eval ".tests[${i}].name" "${yaml_file}")
        if [ "${test_name}" = "null" ] || [ -z "${test_name}" ]; then
            log_error "Test ${i}: Missing required field 'name'"
            return 1
        fi
        
        # Check command field
        local test_command
        test_command=$(yq eval ".tests[${i}].command" "${yaml_file}")
        if [ "${test_command}" = "null" ] || [ -z "${test_command}" ]; then
            log_error "Test '${test_name}': Missing required field 'command'"
            return 1
        fi
    done
    
    log_verbose "Schema validation passed"
    return 0
}
