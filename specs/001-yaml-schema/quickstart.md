# Quickstart: Writing Bashi YAML Tests

**Feature**: 001-yaml-schema  
**Purpose**: Get started writing CLI tests in YAML without Bash knowledge

## Prerequisites

- Bats-core installed:
  - macOS/Linux with Homebrew: `brew install bats-core`
  - Via npm (installs Bash tool, no Node.js runtime needed): `npm install -g bats`
  - From source: See [https://bats-core.readthedocs.io](https://bats-core.readthedocs.io)
- Optional: yq for advanced features (`brew install yq`)

## Basic Test (5 minutes)

### Step 1: Create your first test file

Create `hello-test.bashi.yml`:

```yaml
tests:
  - name: "Echo prints message"
    command: "echo 'Hello, Bashi!'"
    exitCode: 0
    outputContains:
      - "Hello"
      - "Bashi"
```

### Step 2: Run the test

```bash
# (In future: bashi hello-test.bashi.yml)
# For now, manually generate Bats code (implementation pending)
```

**Expected Output**:

```text
✓ Echo prints message

1 test, 0 failures
```

---

## Multiple Assertions (10 minutes)

Test that **all** assertions must pass (AND logic):

```yaml
tests:
  - name: "Version command format"
    command: "myapp --version"
    exitCode: 0
    outputMatches: "^myapp version [0-9]+\\.[0-9]+\\.[0-9]+$"
    outputContains:
      - "version"
```

This test passes only if:

1. Exit code is 0 AND
2. Output matches semver regex AND
3. Output contains "version"

---

## Using Variables (15 minutes)

Avoid duplication with variable substitution:

```yaml
variables:
  APP_BIN: "./bin/myapp"
  TEST_FILE: "/tmp/test-data.txt"

tests:
  - name: "Process file"
    command: "{{APP_BIN}} process {{TEST_FILE}}"
    exitCode: 0
    outputContains:
      - "Processing complete"
```

**Environment Variables**:

```yaml
variables:
  API_KEY: "{{env.TEST_API_KEY}}"

tests:
  - name: "Call API"
    command: "curl -H 'Authorization: {{API_KEY}}' https://api.example.com"
    exitCode: 0
```

---

## Setup and Teardown (20 minutes)

Prepare test environment and clean up:

```yaml
setup: |
  export TMPDIR=$(mktemp -d)
  echo "Test environment: $TMPDIR"

teardown: |
  rm -rf "$TMPDIR"
  echo "Cleanup complete"

setupEach: |
  cd "$TMPDIR"
  touch test-file.txt

teardownEach: |
  rm -f test-file.txt

tests:
  - name: "File exists in temp dir"
    command: "ls test-file.txt"
    exitCode: 0
    
  - name: "Can write to temp file"
    command: "echo 'data' > test-file.txt && cat test-file.txt"
    exitCode: 0
    outputEquals: "data"
```

**Lifecycle Order**:

1. `setup` runs once
2. For each test:
   - `setupEach` runs
   - Test executes
   - `teardownEach` runs (even if test fails)
3. `teardown` runs once (even if tests fail)

---

## Reusable Fragments (25 minutes)

Define common test patterns once:

```yaml
fragments:
  http-success:
    exitCode: 0
    timeout: 30
    outputContains:
      - "HTTP/1.1"
      - "200 OK"

tests:
  - name: "GET homepage"
    command: "curl https://example.com"
    $ref: "#/fragments/http-success"
    
  - name: "GET API endpoint"
    command: "curl https://api.example.com/health"
    $ref: "#/fragments/http-success"
    outputContains:  # Adds to fragment's checks
      - '"status":"healthy"'
```

**Merge Behavior**:

- Test inherits fragment fields
- Test-specific fields override fragment (except arrays)
- Arrays merge: all items from both fragment and test must match

---

## Complete Example (30 minutes)

Real-world test suite for a CLI tool:

```yaml
name: "MyApp CLI Test Suite"
description: "Integration tests for myapp command-line interface"

variables:
  APP: "./bin/myapp"
  VERSION_PATTERN: "[0-9]+\\.[0-9]+\\.[0-9]+"

fragments:
  successful-command:
    exitCode: 0
    timeout: 10

setup: |
  export TEST_DIR=$(mktemp -d)
  echo "Test directory: $TEST_DIR"

teardown: |
  rm -rf "$TEST_DIR"

tests:
  # Basic functionality
  - name: "Show help message"
    command: "{{APP}} --help"
    $ref: "#/fragments/successful-command"
    outputContains:
      - "Usage:"
      - "Options:"
      - "--help"
  
  - name: "Show version in correct format"
    command: "{{APP}} --version"
    exitCode: 0
    outputMatches: "^myapp version {{VERSION_PATTERN}}$"
  
  # Error handling
  - name: "Reject invalid flag"
    command: "{{APP}} --invalid-flag"
    exitCode: 1
    stderr: "Error: Unknown flag --invalid-flag"
  
  - name: "Require argument for --file flag"
    command: "{{APP}} --file"
    exitCode: 1
    outputContains:
      - "Error"
      - "--file requires an argument"
  
  # File operations
  - name: "Process input file"
    command: |
      echo "test data" > "$TEST_DIR/input.txt"
      {{APP}} process "$TEST_DIR/input.txt"
    $ref: "#/fragments/successful-command"
    outputContains:
      - "Processing complete"
      - "1 file processed"
  
  # Skipped tests
  - name: "Benchmark performance"
    command: "{{APP}} --benchmark"
    skip: "Benchmarking disabled in CI pipeline"
```

---

## Field Reference

| Field | Required | Type | Description | Example |
|-------|----------|------|-------------|---------|
| `name` | Yes | string | Test description | "Check version format" |
| `command` | Yes | string | Shell command | "echo 'test'" |
| `exitCode` | No (default: 0) | integer | Expected exit code | 0, 1, 127 |
| `outputContains` | No | array | Strings in stdout (AND) | ["Success", "Done"] |
| `outputEquals` | No | string | Exact stdout match | "Expected output" |
| `outputMatches` | No | string | POSIX ERE regex | "^Error: .*$" |
| `stderr` | No | string | Expected stderr | "Warning message" |
| `skip` | No | bool/string | Skip test | true or "Not ready" |
| `timeout` | No | integer | Max seconds | 30 |
| `$ref` | No | string | Fragment reference | "#/fragments/base" |

---

## Assertion Logic

When multiple output assertions are specified:

```yaml
tests:
  - name: "All assertions must pass (AND logic)"
    command: "myapp status"
    exitCode: 0                    # Must be 0 AND
    outputEquals: "Status: OK"     # Exact match AND
    outputMatches: "^Status:.*$"   # Regex match AND
    outputContains:                # All strings present
      - "Status"
      - "OK"
```

All assertions are evaluated. Test fails if **any** assertion fails.

---

## Special Syntax

### Variable Substitution

- User variable: `{{VAR_NAME}}`
- Environment variable: `{{env.PATH}}`
- Undefined variable: Validation error

### Multi-line Commands

```yaml
command: |
  cd /tmp
  touch file.txt
  ls file.txt
```

### Multi-line Strings

```yaml
outputEquals: >
  This is a long
  expected output
  that spans multiple lines
```

### POSIX ERE Regex (outputMatches)

- Character classes: `[0-9]`, `[a-z]`, `[[:alpha:]]`
- Quantifiers: `*`, `+`, `?`, `{n,m}`
- Anchors: `^` (start), `$` (end)
- Grouping: `(pattern)`
- Alternation: `pattern1|pattern2`

**Not Supported** (use POSIX equivalent):

- `\d` → use `[0-9]`
- `\w` → use `[a-zA-Z0-9_]`
- `\s` → use `[[:space:]]`

---

## Troubleshooting

### "Undefined variable '{{FOO}}'"

Define the variable in the `variables:` section:

```yaml
variables:
  FOO: "value"
```

Or use an environment variable:

```yaml
command: "echo {{env.FOO}}"
```

### "Circular reference detected"

Variables or fragments reference each other in a loop:

```yaml
# DON'T DO THIS
variables:
  A: "{{B}}"
  B: "{{A}}"  # Circular!
```

Fix: Break the cycle or use literal values.

### "Invalid POSIX ERE pattern"

Ensure regex uses POSIX ERE syntax, not PCRE:

```yaml
# Wrong: \d is PCRE
outputMatches: "\\d{4}"

# Correct: [0-9] is POSIX ERE
outputMatches: "[0-9]{4}"
```

### "All assertions must pass"

Remember: Multiple assertions use AND logic. If any assertion fails, the test fails.

Check each assertion independently:

1. Is exit code correct?
2. Does output match exactly (outputEquals)?
3. Does output contain all strings (outputContains)?
4. Does output match regex (outputMatches)?

---

## Next Steps

1. **Learn More**: Read `data-model.md` for complete field specifications
2. **API Contract**: See `contracts/test-suite-schema.json` for JSON Schema
3. **Examples**: Browse `schema/examples/` for more patterns
4. **CLI Usage**: (Future feature) Run `bashi --help` for command-line options

---

## Quick Tips

✅ **DO**:

- Use descriptive test names: "Check version output format" not "Test 1"
- Group related tests in one suite
- Use variables for repeated values
- Use fragments for common assertion patterns
- Test both success and failure cases

❌ **DON'T**:

- Don't use Bash 4+ features in commands (stick to POSIX)
- Don't specify both `outputEquals` and `outputMatches` (pick one)
- Don't create circular variable references
- Don't assume test order (Bats may parallelize)
- Don't forget to clean up in `teardown`

---

## Phase 1 Quickstart Complete

Ready to write YAML tests! Proceed to Phase 2 task breakdown.

