# Research: YAML Test Definition Schema

**Feature**: 001-yaml-schema  
**Date**: November 6, 2025  
**Purpose**: Resolve technical unknowns and establish best practices for YAML schema implementation

## Research Areas

### 1. YAML Parsing Strategy for Bash 3.2+

**Decision**: Hybrid approach - pure Bash parser for simple cases, optional yq/jq for complex features

**Rationale**:
- Bash 3.2+ lacks native YAML parsing, but simple key-value extraction is feasible with `sed`/`awk`
- Pure Bash parsing ensures zero dependencies for basic test suites (P1 user story)
- Optional yq (YAML processor) or jq (after `yq eval -o=json`) for advanced features (variables, fragments)
- Graceful degradation: warn users if advanced features require yq but it's not installed

**Alternatives Considered**:
1. **Pure Bash only**: Rejected - too complex for nested structures and edge cases (YAML anchors, multi-line strings)
2. **Mandatory yq dependency**: Rejected - violates "accessibility" goal (users shouldn't need to install tools for basic tests)
3. **Python/Ruby YAML libs**: Rejected - introduces language dependency outside constitution's Bash 3.2+ requirement

**Implementation Guidance**:
- Detect yq/jq availability at runtime: `command -v yq >/dev/null 2>&1`
- Basic parsing (P1): Pure Bash regex extraction for `name:`, `command:`, `exitCode:`, `outputContains:`
- Advanced features (P3-P4): Require yq and provide clear error if missing: "Variable substitution requires yq. Install: brew install yq"
- Document yq as optional dependency in README with installation instructions

### 2. POSIX ERE Regex Validation in Bash 3.2+

**Decision**: Use Bash's `[[ string =~ pattern ]]` built-in for ERE regex validation

**Rationale**:
- Bash 3.2+ supports ERE regex natively via `=~` operator in `[[ ]]` conditionals
- No external dependencies (grep -E would work but `=~` is cleaner for validation)
- Validates regex patterns before embedding in generated Bats tests
- Captures match results in `BASH_REMATCH` array for complex assertions

**Alternatives Considered**:
1. **grep -E for validation**: Rejected - requires spawning subprocess, slower, less idiomatic
2. **PCRE via external tools**: Rejected - not POSIX, introduces dependency
3. **BRE (Basic Regex)**: Rejected - too limited (no `+`, `?`, `|` alternation)

**Implementation Guidance**:
```bash
# Validate ERE pattern
validate_ere_pattern() {
    local pattern="$1"
    if [[ "test" =~ $pattern ]] 2>/dev/null; then
        return 0  # Valid ERE
    else
        echo "ERROR: Invalid POSIX ERE pattern: $pattern" >&2
        return 1
    fi
}
```

**Known Limitations**:
- Bash 3.2 ERE doesn't support `\d`, `\w`, `\s` (use `[0-9]`, `[a-zA-Z0-9_]`, `[[:space:]]`)
- Document these POSIX ERE restrictions in schema reference

### 3. Temporary Bats File Management

**Decision**: Generate Bats files in `/tmp/bashi-{pid}/` with automatic cleanup via trap

**Rationale**:
- Bats-core requires `.bats` files as input - cannot accept tests via stdin
- Temporary directory per process ID prevents collision in parallel executions
- `trap` ensures cleanup even if Bashi exits unexpectedly (Ctrl-C, error)
- `/tmp/` is cross-platform (macOS, Linux) and automatically cleaned on reboot

**Alternatives Considered**:
1. **Persistent `.bats` files in project**: Rejected - clutters user's workspace, requires .gitignore management
2. **Named pipes**: Rejected - Bats-core doesn't support reading from FIFOs
3. **In-memory file descriptors**: Rejected - not portable to Bash 3.2, Bats expects real files

**Implementation Guidance**:
```bash
#!/usr/bin/env bash
set -euo pipefail

BASHI_TMPDIR="/tmp/bashi-$$"
trap 'rm -rf "$BASHI_TMPDIR"' EXIT INT TERM

mkdir -p "$BASHI_TMPDIR"
generated_test="$BASHI_TMPDIR/test.bats"

# ... generate Bats code into $generated_test ...

bats "$generated_test"  # Execute via Bats-core
# Cleanup handled by trap automatically
```

### 4. Variable Substitution Algorithm

**Decision**: Two-pass preprocessing (variables first, fragments second) with cycle detection

**Rationale**:
- Variables resolved before fragment expansion allows fragments to contain variable references
- Cycle detection prevents infinite loops from circular variable refs: `{{a}}` → `{{b}}` → `{{a}}`
- Clear error messages guide users to fix circular dependencies
- Separate passes simplify logic and error reporting

**Algorithm**:
```
Pass 1: Variable Resolution
  For each {{varName}} in YAML:
    1. Look up varName in variables: section
    2. If not found, check {{env.VARNAME}} for environment variables
    3. If still not found, ERROR with line number
    4. Track visited variables to detect cycles
    5. Replace {{varName}} with resolved value

Pass 2: Fragment Expansion
  For each $ref: in tests:
    1. Look up referenced fragment by ID
    2. Merge fragment fields with test fields (test overrides fragment)
    3. Track visited fragments to detect cycles
    4. ERROR if circular reference detected
```

**Alternatives Considered**:
1. **Single-pass combined resolution**: Rejected - complex logic, hard to debug, unclear precedence
2. **Fragments before variables**: Rejected - prevents variables in fragments (less flexible)
3. **No cycle detection**: Rejected - infinite loops would hang Bashi silently

**Edge Cases Handled**:
- Variable referencing undefined variable: Report specific missing var name with line number
- Variable referencing itself: Detect immediate cycle, report error
- Empty variable value: Allow (user may want empty string substitution)
- Variable in fragment: Works (fragments expanded after variables)

### 5. Multi-Assertion Validation (AND Logic)

**Decision**: Generate sequential Bats assertions, fail-fast within single @test block

**Rationale**:
- Clarification confirmed: ALL assertions must pass (AND logic)
- Bats-core fails test on first assertion failure within `@test` block
- Generate separate `[[ ... ]]` conditionals or `grep` checks for each assertion
- Clear error messages indicate which specific assertion failed

**Implementation Pattern**:
```bash
@test "example with multiple assertions" {
    run command_under_test
    
    # Exit code check
    [ "$status" -eq 0 ]
    
    # outputEquals check (exact match)
    [ "$output" = "expected exact output" ]
    
    # outputContains checks (all must be present)
    echo "$output" | grep -F "first string"
    echo "$output" | grep -F "second string"
    
    # outputMatches check (ERE regex)
    [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}
```

**Alternatives Considered**:
1. **OR logic for assertions**: Rejected - clarification specified AND logic
2. **Continue on assertion failure**: Rejected - Bats-core design is fail-fast per test
3. **Custom assertion aggregator**: Rejected - reimplements Bats-core logic (violates constitution)

### 6. Setup/Teardown Failure Handling

**Decision**: Map to Bats-core `setup()`/`teardown()` functions with explicit failure reporting

**Rationale**:
- Clarification specified: setup failure skips tests, teardown always runs
- Bats-core native behavior: `setup()` failure skips test, `teardown()` always executes
- Direct mapping honors dependency-first architecture (no reimplementation)
- Bats-core reports setup/teardown failures distinctly in TAP output

**Mapping**:
```
YAML Field          → Bats Function
─────────────────────────────────────
setup:              → setup() { ... }
teardown:           → teardown() { ... }
setupEach:          → setup() { ... }  (same function, runs before each test)
teardownEach:       → teardown() { ... }  (same function, runs after each test)
```

**Note**: Bats-core doesn't distinguish suite-level vs per-test setup/teardown in function names. The distinction is semantic (how Bashi generates the Bats file structure). If both `setup` and `setupEach` are specified, this requires clarification in future refinement.

**Alternatives Considered**:
1. **Custom hook execution**: Rejected - reimplements Bats-core (violates constitution)
2. **Ignore teardown on failure**: Rejected - clarification mandates teardown always runs (matches Bats)
3. **Try-catch for setup**: Rejected - Bash 3.2 lacks try-catch, Bats handles this natively

### 7. Schema Validation Performance

**Decision**: Single-pass validation with collected errors, avoid redundant parsing

**Rationale**:
- Success criteria: <100ms for 100-test suites
- Single YAML parse pass (via yq or pure Bash), collect all errors before reporting
- Fail-fast on parse errors (malformed YAML), continue on semantic errors (missing fields)
- Batch error reporting improves UX (user fixes multiple issues at once)

**Performance Optimizations**:
- Validate required fields during initial parse pass (don't re-parse)
- Cache variable definitions in associative array... wait, Bash 3.2 lacks associative arrays!
- Alternative: Use `grep` to extract variable names, store in indexed array with name-value pairs
- Skip fragment expansion during validation-only mode (add `--validate-only` flag)

**Implementation Note**:
```bash
# Bash 3.2 compatible "map" using indexed arrays
declare -a var_names=(key1 key2)
declare -a var_values=(val1 val2)

lookup_var() {
    local key="$1"
    for i in "${!var_names[@]}"; do
        if [[ "${var_names[$i]}" == "$key" ]]; then
            echo "${var_values[$i]}"
            return 0
        fi
    done
    return 1
}
```

**Alternatives Considered**:
1. **Parse each field separately**: Rejected - too slow, would miss 100ms target
2. **Incremental validation**: Rejected - early exit on first error frustrates users
3. **External validator (JSON Schema)**: Rejected - adds dependency, doesn't validate Bash-specific rules

## Best Practices

### YAML Schema Design

1. **Explicit over implicit**: Require explicit `name:` and `command:` fields (no positional arguments)
2. **Fail-safe defaults**: Default `exitCode: 0` (most commands succeed), no default for command (must be explicit)
3. **Consistent naming**: Use camelCase for multi-word fields (`exitCode`, not `exit_code`) per YAML conventions
4. **Array for multiple values**: `outputContains: [...]` not `outputContains1:`, `outputContains2:`
5. **Reserved prefix**: Use `bashi_` prefix for internal metadata fields to avoid user conflicts

### Error Message Quality

1. **Always include location**: `"Error in test.bashi.yml:42: Missing required field 'command'"`
2. **Actionable guidance**: Not "Invalid field" but "Field 'timeout' must be a positive integer, got: 'abc'"`
3. **Batch related errors**: Group errors by test definition (don't interleave errors from different tests)
4. **Examples in errors**: "Did you mean 'outputContains: [\"text\"]' instead of 'outputContains: text'?"

### Generated Bats Code

1. **Readable output**: Generated Bats code should be human-readable for debugging
2. **Comment source**: Add `# Generated from test.bashi.yml:42` comments for traceability
3. **Preserve test names**: Use YAML `name:` field verbatim in Bats `@test "..."` (sanitize special chars)
4. **Shellcheck clean**: Generated code should pass shellcheck (quoted variables, proper conditionals)

## Dependencies

### Required
- Bash 3.2+ (system requirement, always present)
- Bats-core (external dependency, must be installed by user)

### Optional
- yq or jq (for advanced features: variables, fragments, complex YAML)
- shellcheck (for development, validation of generated code)

### Not Required
- Python/Ruby/Node.js (stay pure Bash)
- YAML parsing libraries (use yq or pure Bash)
- JSON schema validators (custom Bash validation)

## Open Questions for Future Refinement

1. **Suite-level vs per-test hooks**: If user specifies both `setup` and `setupEach`, what is the behavior? (Bats only has one `setup()` function)
   - Potential solution: Error on conflict, or concatenate commands, or document `setup` = suite, `setupEach` = per-test (requires different file structure)

2. **YAML anchors and aliases**: Should Bashi support native YAML anchors (`&anchor`, `*alias`)? yq handles them automatically.
   - Decision: Support them (yq handles parsing), document as alternative to `$ref` fragments

3. **Timeout implementation**: How to enforce `timeout: 30` in Bash 3.2? `timeout` command not POSIX.
   - Research needed: Bash background jobs with `wait`, `kill` after sleep, or require GNU `timeout`

4. **Parallel test execution**: Should YAML schema support `parallel: true`? Or delegate to Bats-core `--jobs` flag?
   - Decision (per constitution): Delegate to Bats-core, don't reimplement (add note to documentation)

## Phase 0 Complete

All critical technical unknowns resolved. Proceed to Phase 1: Design & Contracts.

