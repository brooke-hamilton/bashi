# Research: Bashi Test Framework Implementation

**Feature**: 002-bashi-implementation  
**Date**: 2025-11-08  
**Purpose**: Research technical decisions and best practices for implementing the Bashi YAML-to-Bats test framework

## Research Areas

### 1. YAML Validation with yq

**Decision**: Use `yq` v4+ with external JSON schema validator

**Rationale**:

- `yq` is the standard YAML processor for Bash environments
- Widely available via package managers (Homebrew, apt, yum)
- Supports JSON output for easier processing in Bash
- Does not natively support JSON schema validation
- Must combine with external validator or implement custom validation

**Validation Approach**:

- Convert YAML to JSON using `yq eval -o=json`
- Validate JSON against schema using one of:
  - Option A: Python `jsonschema` (requires Python dependency)
  - Option B: Node.js `ajv-cli` (requires Node.js dependency)
  - Option C: Custom Bash validation logic using `yq` queries
- **Selected**: Option C (custom Bash validation) to minimize external dependencies beyond `yq`

**Alternatives Considered**:

- `jq` with YAML libraries: Less mature YAML support
- Python/Ruby scripts: Adds language dependency beyond Bash
- Pure Bash YAML parsing: Too complex, error-prone

**Implementation Notes**:

- Check for `yq` availability at startup
- Provide clear installation instructions if missing
- Use `yq --version` to verify v4+ (newer syntax)
- Validate against schema by querying required fields with `yq`

### 2. JSON Schema Validation in Bash

**Decision**: Implement targeted validation using `yq` queries for critical fields

**Rationale**:

- Full JSON schema validation requires external tools (Python jsonschema, Node.js ajv)
- Adding Python/Node dependency conflicts with "Bash-only" philosophy
- Most schema violations are simple (missing fields, wrong types)
- Can validate 90% of cases with targeted `yq` queries

**Validation Strategy**:

1. Required field checks: `yq '.tests' file.yaml` (must exist, must be array)
2. Type validation: Check array vs object vs string with `yq` type operators
3. Pattern validation: Use Bash regex for variable/fragment names
4. Range validation: Check exit codes 0-255 with Bash arithmetic
5. Reference validation: Verify fragments exist before resolving

**Alternatives Considered**:

- Full schema validator with Python: Adds dependency
- Full schema validator with Node.js: Adds dependency
- No validation: Too risky, poor user experience

**Implementation Notes**:

- Create `validate_yaml()` function in `lib/validator.sh`
- Check required fields first (fast failure)
- Provide specific error messages with field paths
- Exit code 1 for validation errors

### 3. Variable Substitution Strategy

**Decision**: Use Bash string replacement with regex validation

**Rationale**:

- Simple `{{varName}}` syntax easy to find and replace
- Bash native string operations sufficient
- No template engine needed
- Validate variable names before substitution

**Implementation Approach**:

```bash
# Extract variables section as JSON
variables=$(yq '.variables' file.yaml -o=json)

# Find all {{varName}} patterns in YAML
# Replace with actual values from variables object
# Use sed or Bash string replacement
```

**Alternatives Considered**:

- `envsubst`: Requires $ syntax, conflicts with shell variables
- Template engine (mustache, jinja): Overkill, adds dependency
- Recursive expansion: Complex, risk of infinite loops

**Implementation Notes**:

- Validate variable names match `^[a-zA-Z_][a-zA-Z0-9_]*$`
- Detect undefined variables and error clearly
- Perform substitution after validation, before fragment resolution
- Handle escaping if needed (e.g., `\{{` for literal)

### 4. Fragment Resolution ($ref)

**Decision**: Custom resolution using `yq` to extract and merge fragments

**Rationale**:

- JSON Reference ($ref) is a standard pattern
- Simple to implement with `yq`: extract fragment, merge fields
- Test-local fields override fragment fields (explicit wins)

**Resolution Algorithm**:

1. Extract fragments section: `yq '.fragments' file.yaml`
2. For each test with `$ref`:
   - Parse reference (e.g., `#/fragments/common`)
   - Extract fragment by name
   - Merge fragment fields into test (test fields override)
3. Detect circular references (track resolution stack)

**Alternatives Considered**:

- JSON Reference library: No mature Bash library
- Inline expansion: Harder to maintain
- No fragment support: Reduces user convenience

**Implementation Notes**:

- Resolve fragments after variable substitution
- Maintain stack to detect cycles: `fragment_stack=()`
- Use `yq` merge operator or manual field copying
- Clear error for undefined fragment references

### 5. Bats Code Generation

**Decision**: Generate Bats test file from processed YAML using heredoc templates

**Rationale**:

- Bats syntax is simple: `@test "name" { commands; assertions }`
- Can generate programmatically from YAML
- Use Bash heredoc for clean template generation

**Generation Approach**:

```bash
# For each test in YAML:
cat >> output.bats <<EOF
@test "${test_name}" {
  run ${test_command}
  [ "\$status" -eq ${expected_exit_code} ]
  # Additional assertions based on outputContains, etc.
}
EOF
```

**Assertion Mapping**:

- `exitCode` → `[ "$status" -eq N ]`
- `outputEquals` → `[ "$output" = "expected" ]`
- `outputContains` → `[[ "$output" =~ pattern ]]` or `grep -q`
- `outputMatches` → `[[ "$output" =~ regex ]]`
- `stderr` → Capture stderr separately, assert on `$stderr`
- `skip` → `skip "reason"` at test start

**Alternatives Considered**:

- Bats helper library: Keep it simple first
- Custom test format: Breaks Bats-core dependency principle

**Implementation Notes**:

- Escape special characters in test names and strings
- Generate setup/teardown functions if defined
- Use `run` command for test execution
- Quote all variables in generated code

### 6. Setup/Teardown Implementation

**Decision**: Generate Bats `setup()`, `teardown()`, `setup_file()`, `teardown_file()` functions

**Rationale**:

- Bats natively supports these hooks
- Direct mapping from YAML to Bats functions
- Bats handles execution order automatically

**Mapping**:

- `setup` (suite-level) → `setup_file()` function
- `teardown` (suite-level) → `teardown_file()` function
- `setupEach` (per-test) → `setup()` function
- `teardownEach` (per-test) → `teardown()` function

**Error Handling**:

- Bats aborts tests if `setup_file()` fails (matches spec requirement)
- Bats runs `teardown_file()` even on failure (matches spec requirement)
- Bats aborts individual test if `setup()` fails (matches spec requirement)

**Implementation Notes**:

- Generate functions only if commands defined in YAML
- Place at top of generated Bats file
- No additional error handling needed (Bats handles it)

### 7. Test Execution & Reporting

**Decision**: Execute Bats directly, pass through TAP output with optional formatting

**Rationale**:

- Bats produces TAP (Test Anything Protocol) output
- TAP is standard, parseable, CI-friendly
- Can enhance formatting in future without changing core

**Execution Approach**:

```bash
bats generated_tests.bats
exit_code=$?
exit $exit_code
```

**Output Options**:

- Default: Pass through Bats TAP output directly
- Future: Add `--format` flag for alternative formatters
- Preserve exit codes: 0 = all pass, non-zero = failures

**Alternatives Considered**:

- Custom test runner: Violates dependency-first architecture
- Parse and reformat TAP: Unnecessary complexity initially

**Implementation Notes**:

- Check for `bats` availability at startup
- Provide installation instructions if missing
- Capture exit code for proper error propagation
- Consider `bats --tap` flag for pure TAP output

### 8. Error Message Best Practices

**Decision**: Structured error messages with context and actionable guidance

**Format Template**:

```text
Error: [CATEGORY] [Specific problem]

Location: [file:line or field path]
Found: [what was actually present]
Expected: [what should be present]

Fix: [specific action to resolve]
```

**Examples**:

```text
Error: YAML Validation - Missing required field

Location: test-file.yaml
Field: tests[2].command
Expected: Non-empty string

Fix: Add a 'command' field to test at index 2
```

```text
Error: Variable Reference - Undefined variable

Location: tests[0].command
Found: {{undefined_var}}
Expected: Variable defined in 'variables' section

Fix: Add 'undefined_var: "value"' to the variables section
```

**Rationale**:

- Clear categorization helps users identify error type
- Location info enables quick fixes
- Expected vs Found shows the gap
- Actionable fix reduces support burden

**Implementation Notes**:

- Create `error()` helper function in each lib module
- Log errors to stderr
- Exit with appropriate codes (1 = validation, 2 = processing, etc.)
- Validate early to fail fast

### 9. Timeout Handling

**Decision**: Use Bats' built-in timeout support or `timeout` command wrapper

**Rationale**:

- Bats supports timeout with `BATS_TEST_TIMEOUT` environment variable (Bats v1.5+)
- Fallback: wrap command with GNU `timeout` utility
- Prevents hung tests

**Implementation Approach**:

- If test has `timeout` field, generate wrapped command:

  ```bash
  @test "name" {
    run timeout ${timeout_seconds} ${command}
    # assertions
  }
  ```

**Alternatives Considered**:

- Custom timeout implementation: Complex, error-prone
- No timeout support: Tests could hang forever

**Implementation Notes**:

- Check if `timeout` command available (`command -v timeout`)
- Timeout exit code is 124 (handle specially)
- Provide clear error when test times out

### 10. Bash 3.2 Compatibility

**Decision**: Test on macOS (Bash 3.2) and Linux (Bash 4+) regularly

**Critical Compatibility Constraints**:

- **No**: Associative arrays (Bash 4+)
- **No**: `mapfile`/`readarray` (Bash 4+)
- **No**: `&>>` redirect shorthand
- **Yes**: Indexed arrays (Bash 3.0+)
- **Yes**: `[[ ]]` conditionals (Bash 2.05+)
- **Yes**: `$(...)` command substitution

**Workarounds for Missing Features**:

- Instead of associative arrays: Use parallel indexed arrays or `grep` lookups
- Instead of `mapfile`: Use `while read` loops
- Instead of `&>>`: Use `>> file 2>&1`

**Testing Strategy**:

- Primary development can be on Bash 4+
- Must test on macOS before each release
- CI/CD should include macOS runner
- Document Bash 3.2 requirement in README

**Implementation Notes**:

- Run `shellcheck` with `--shell=bash` flag
- Add `# shellcheck shell=bash` directive to scripts
- Manually verify no Bash 4+ features used
- Keep compatibility notes in code comments

## Summary of Decisions

| Area | Decision | Key Tool/Approach |
|------|----------|-------------------|
| YAML Processing | Use `yq` v4+ | Required dependency |
| Schema Validation | Custom validation with `yq` queries | Avoid external validators |
| Variable Substitution | Bash string replacement | Native Bash operations |
| Fragment Resolution | Custom $ref resolver with `yq` | Merge algorithm |
| Bats Generation | Heredoc templates | Programmatic generation |
| Setup/Teardown | Native Bats functions | Direct mapping |
| Test Execution | Execute Bats directly | Pass-through TAP output |
| Error Messages | Structured format | Context + actionable fix |
| Timeouts | `timeout` command wrapper | GNU timeout utility |
| Bash Compatibility | Test on Bash 3.2 | Avoid Bash 4+ features |

## Dependencies Summary

**Required**:

- Bash 3.2+ (assumed present on target systems)
- `yq` v4+ (user must install)
- Bats-core latest stable (user must install)
- `timeout` command (GNU coreutils, usually pre-installed)

**Optional**:

- `shellcheck` (development only, for code quality)

**Installation Documentation Needed**:

- macOS: `brew install yq bats-core`
- Ubuntu/Debian: `sudo apt install yq bats`
- RHEL/CentOS: `sudo yum install yq bats`
- Manual: Link to release pages

## Next Steps

With research complete, proceed to:

1. **Phase 1**: Create data-model.md (entities and their relationships)
2. **Phase 1**: Define contracts (CLI interface, expected inputs/outputs)
3. **Phase 1**: Write quickstart.md (getting started guide)
4. **Phase 1**: Update agent context with technology decisions
