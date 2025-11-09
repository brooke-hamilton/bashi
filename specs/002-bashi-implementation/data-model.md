# Data Model: Bashi Test Framework

**Feature**: 002-bashi-implementation  
**Date**: 2025-11-08  
**Purpose**: Define the internal data structures and entity relationships for the Bashi test framework

## Overview

The Bashi test framework processes YAML test definitions through several transformation stages. This document defines the data model at each stage and the relationships between entities.

## Entities

### 1. Test Suite (YAML Input)

The top-level container for test definitions, parsed from user-provided YAML files.

**Fields**:

- `name` (string, optional): Human-readable identifier for the test suite
- `description` (string, optional): Explanation of what this test suite validates
- `variables` (object, optional): Key-value pairs for variable substitution
- `fragments` (object, optional): Named reusable test fragments
- `setup` (string, optional): Suite-level setup commands
- `teardown` (string, optional): Suite-level teardown commands
- `setupEach` (string, optional): Per-test setup commands
- `teardownEach` (string, optional): Per-test teardown commands
- `tests` (array, required): Array of test definitions (minimum 1 item)

**Validation Rules**:

- `tests` array must have at least one element
- `variables` keys must match pattern `^[a-zA-Z_][a-zA-Z0-9_]*$`
- `fragments` keys must match pattern `^[a-zA-Z_][a-zA-Z0-9_-]*$`

**Relationships**:

- Contains 0..* Variables
- Contains 0..* Fragments
- Contains 1..* Test Definitions

### 2. Variable

A named string value used for substitution in test definitions.

**Fields**:

- `name` (string, key): Variable identifier (matches naming pattern)
- `value` (string): The string value to substitute

**Validation Rules**:

- Name must match `^[a-zA-Z_][a-zA-Z0-9_]*$`
- Value is always treated as string (no type coercion)

**Usage**:

- Referenced in tests via `{{variableName}}` syntax
- Substituted during processing stage before fragment resolution

### 3. Fragment

A reusable partial test definition that can be inherited by multiple tests.

**Fields**:

- `name` (string, key): Fragment identifier (matches naming pattern)
- `command` (string, optional): Shell command template
- `exitCode` (integer, optional): Expected exit status (0-255)
- `outputContains` (array of strings, optional): Strings that must appear in stdout
- `outputEquals` (string, optional): Exact expected stdout
- `outputMatches` (string, optional): POSIX ERE regex pattern for stdout
- `stderr` (string, optional): Expected stderr output
- `skip` (boolean or string, optional): Skip test with optional reason
- `timeout` (integer, optional): Maximum execution time in seconds

**Validation Rules**:

- Name must match `^[a-zA-Z_][a-zA-Z0-9_-]*$`
- exitCode must be 0-255 if specified
- timeout must be >= 1 if specified
- Cannot contain `$ref` (no nested fragment references)

**Relationships**:

- Referenced by 0..* Test Definitions

### 4. Test Definition (YAML)

A single test case with command and assertions, before processing.

**Fields**:

- `name` (string, required): Descriptive test name (becomes Bats @test name)
- `command` (string, required): Shell command to execute
- `exitCode` (integer, optional, default: 0): Expected exit status
- `outputContains` (array of strings, optional): Required stdout strings (AND logic)
- `outputEquals` (string, optional): Exact stdout match
- `outputMatches` (string, optional): POSIX ERE regex for stdout
- `stderr` (string, optional): Expected stderr output
- `skip` (boolean or string, optional): Skip test with optional reason
- `timeout` (integer, optional): Execution time limit in seconds
- `$ref` (string, optional): Fragment reference (format: `#/fragments/{name}`)

**Validation Rules**:

- `name` must be 1-256 characters
- `command` must be non-empty
- `exitCode` must be 0-255 if specified
- `timeout` must be >= 1 if specified
- `$ref` format must be `#/fragments/[valid-fragment-name]`
- Cannot specify both `outputEquals` and `outputMatches` (mutually exclusive)

**State Transitions**:

```text
YAML Test Definition (with {{vars}} and $ref)
  ↓ Variable Substitution
Test with Resolved Variables (with $ref)
  ↓ Fragment Resolution
Fully Resolved Test (no $ref)
  ↓ Bats Generation
Generated Bats @test
```

### 5. Resolved Test Definition

A test definition after variable substitution and fragment resolution, ready for Bats generation.

**Fields**: Same as Test Definition (YAML) except:

- No `$ref` field (fragments fully merged)
- All `{{variableName}}` replaced with actual values
- Fragment fields merged (test-local fields override fragment fields)

**Merge Rules (Fragment Resolution)**:

1. Start with fragment fields (if `$ref` present)
2. Overlay test-local fields
3. Test-local fields always win conflicts
4. Result has no `$ref` field

**Example Merge**:

```yaml
# Fragment
fragments:
  common:
    exitCode: 0
    timeout: 30

# Test (before resolution)
tests:
  - name: "My test"
    command: "echo hi"
    $ref: "#/fragments/common"
    timeout: 60  # Local override

# Resolved test
tests:
  - name: "My test"
    command: "echo hi"
    exitCode: 0      # From fragment
    timeout: 60      # Local override wins
```

### 6. Generated Bats Test

The final Bats-core compatible test code generated from resolved test definitions.

**Structure**:

```bash
#!/usr/bin/env bats

# Setup functions (if defined)
setup_file() {
  # Suite-level setup commands
}

teardown_file() {
  # Suite-level teardown commands
}

setup() {
  # Per-test setup commands (setupEach)
}

teardown() {
  # Per-test teardown commands (teardownEach)
}

# Generated test
@test "Test name from YAML" {
  # Skip if specified
  [[ skip_condition ]] && skip "reason"
  
  # Execute command with timeout wrapper if needed
  run timeout 60 command args
  
  # Assertions based on test fields
  [ "$status" -eq 0 ]
  [[ "$output" =~ pattern ]]
  # etc.
}
```

**Assertion Mapping**:

- `exitCode: N` → `[ "$status" -eq N ]`
- `outputEquals: "text"` → `[ "$output" = "text" ]`
- `outputContains: ["A", "B"]` → `grep -q "A" <<< "$output" && grep -q "B" <<< "$output"`
- `outputMatches: "pattern"` → `[[ "$output" =~ pattern ]]`
- `stderr: "text"` → Custom stderr capture and assertion
- `skip: "reason"` → `skip "reason"` at test start
- `timeout: 60` → `run timeout 60 command`

### 7. Test Result

The outcome of executing a Bats test, extracted from TAP output.

**Fields** (from Bats TAP output):

- `test_number` (integer): Sequential test number
- `status` (string): "ok" or "not ok"
- `test_name` (string): Name from @test
- `skip_reason` (string, optional): Reason if skipped
- `failure_output` (string, optional): Error details if failed

**TAP Format Example**:

```text
1..3
ok 1 Test name
not ok 2 Another test # FAILED
ok 3 Third test # SKIP reason here
```

## Data Flow

```text
┌─────────────────────┐
│   YAML Test File    │ ← User creates
└──────────┬──────────┘
           │
           │ Parse & Validate
           ↓
┌─────────────────────┐
│ Test Suite Object   │ ← Raw YAML parsed
│ + Tests with {{vars}}│
│ + Tests with $ref   │
└──────────┬──────────┘
           │
           │ Variable Substitution
           ↓
┌─────────────────────┐
│ Tests with Values   │ ← Variables resolved
│ (still has $ref)    │
└──────────┬──────────┘
           │
           │ Fragment Resolution
           ↓
┌─────────────────────┐
│ Fully Resolved Tests│ ← Fragments merged
│ (no $ref, no {{}} ) │
└──────────┬──────────┘
           │
           │ Bats Code Generation
           ↓
┌─────────────────────┐
│ Generated .bats File│ ← Executable Bats tests
└──────────┬──────────┘
           │
           │ Execute with Bats
           ↓
┌─────────────────────┐
│   Test Results      │ ← TAP output
│   (pass/fail/skip)  │
└─────────────────────┘
```

## Validation Points

1. **Schema Validation** (on YAML input):
   - Required fields present
   - Field types correct
   - Naming patterns match
   - Value ranges valid

2. **Reference Validation** (before processing):
   - All `{{variables}}` defined in `variables` section
   - All `$ref` fragments exist in `fragments` section
   - No circular fragment references

3. **Semantic Validation** (during processing):
   - Mutual exclusions (e.g., outputEquals vs outputMatches)
   - Timeout values reasonable
   - Commands non-empty after substitution

## Error States

| Error Type | Detection Point | Example |
|------------|----------------|---------|
| Missing Required Field | Schema Validation | `tests` array not present |
| Invalid Field Type | Schema Validation | `exitCode` is string not integer |
| Undefined Variable | Reference Validation | `{{foo}}` but no `foo` in variables |
| Undefined Fragment | Reference Validation | `$ref: "#/fragments/missing"` |
| Circular Reference | Fragment Resolution | Fragment A refs B, B refs A |
| Invalid Pattern | Schema Validation | Variable name `123invalid` |
| Value Out of Range | Schema Validation | `exitCode: 999` (> 255) |

## Storage Considerations

**Temporary Files**:

- Processed YAML (after variable substitution): `$TEMP_DIR/processed.yaml`
- Generated Bats file: `$TEMP_DIR/tests.bats`
- Cleanup on exit via trap

**No Persistent State**:

- Bashi is stateless
- Each invocation processes from scratch
- No caching or state files

## Concurrency

**Not Applicable**: Bashi processes one test suite per invocation sequentially. Bats-core handles parallel test execution internally if configured.

## Summary

The Bashi data model flows from user-provided YAML through validation, variable substitution, fragment resolution, and finally Bats code generation. Each stage has specific validation rules and error handling. The model is intentionally simple to keep the adapter layer thin and maintainable.
