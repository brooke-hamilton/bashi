# Data Model: YAML Test Definition Schema

**Feature**: 001-yaml-schema  
**Date**: November 6, 2025  
**Purpose**: Define entities, structures, and relationships in YAML test files

## Core Entities

### TestSuite

The root YAML document representing a collection of related tests.

**Fields**:

- `name` (string, optional): Human-readable identifier for the test suite
- `description` (string, optional): Explanation of what the suite tests
- `variables` (object, optional): Key-value pairs for variable substitution
- `fragments` (object, optional): Named reusable test fragments
- `setup` (string, optional): Commands to run once before all tests
- `teardown` (string, optional): Commands to run once after all tests
- `setupEach` (string, optional): Commands to run before each individual test
- `teardownEach` (string, optional): Commands to run after each individual test
- `tests` (array, required): List of test definitions

**Validation Rules**:

- At least one test required in `tests` array
- Variable names must be valid identifiers (alphanumeric + underscore, no spaces)
- Fragment IDs must be unique within suite
- `setup`/`teardown` commands must be valid shell commands

**Example**:

```yaml
name: "CLI Tool Test Suite"
description: "Tests for myapp command-line interface"
variables:
  TEMP_DIR: "/tmp/myapp-test"
  APP_BIN: "./bin/myapp"
tests:
  - name: "First test"
    command: "{{APP_BIN}} --version"
    exitCode: 0
```

---

### TestDefinition

An individual test case specifying a command to execute and expected outcomes.

**Fields**:

- `name` (string, required): Descriptive name for the test (becomes Bats `@test` name)
- `command` (string, required): Shell command to execute under test
- `exitCode` (integer, optional, default: 0): Expected exit status code
- `outputContains` (array of strings, optional): Strings that must appear in stdout
- `outputEquals` (string, optional): Exact expected stdout (character-for-character)
- `outputMatches` (string, optional): POSIX ERE regex pattern for stdout
- `stderr` (string, optional): Expected stderr output validation
- `skip` (boolean or string, optional): Skip test execution (with optional reason)
- `timeout` (integer, optional): Maximum execution time in seconds
- `$ref` (string, optional): Reference to a fragment ID for field inheritance

**Validation Rules**:

- `name` and `command` are mandatory
- `exitCode` must be integer 0-255
- Cannot specify both `outputEquals` and `outputMatches` (ambiguous intent)
- `outputContains` array elements must be non-empty strings
- Multiple assertion types (`outputContains`, `outputEquals`, `outputMatches`) use AND logic
- `timeout` must be positive integer if specified
- `skip` as boolean (true) or string (reason message)
- `$ref` must reference an existing fragment ID

**Example**:

```yaml
- name: "Check version output format"
  command: "myapp --version"
  exitCode: 0
  outputMatches: "^myapp version [0-9]+\\.[0-9]+\\.[0-9]+$"
  
- name: "Test invalid argument"
  command: "myapp --invalid-flag"
  exitCode: 1
  stderr: "Error: Unknown flag --invalid-flag"
  
- name: "Skip slow test"
  command: "myapp --benchmark"
  skip: "Benchmarking disabled in CI"
```

---

### Variable

A named value defined at suite level, substituted into test commands and assertions.

**Structure**:

```yaml
variables:
  VAR_NAME: "value"
  ANOTHER_VAR: "another value"
```

**Resolution Rules**:

- User-defined variables: `{{VAR_NAME}}` replaced with value from `variables:` section
- Environment variables: `{{env.PATH}}` replaced with value from shell environment
- Undefined variable reference: Validation error with line number
- Variable values can contain other variables (resolved recursively with cycle detection)
- Variables resolved before fragment expansion

**Example**:

```yaml
variables:
  BASE_URL: "https://api.example.com"
  API_KEY: "{{env.TEST_API_KEY}}"
  
tests:
  - name: "Call API endpoint"
    command: "curl -H 'Authorization: {{API_KEY}}' {{BASE_URL}}/users"
    exitCode: 0
```

---

### Fragment

A reusable partial test definition that can be referenced by multiple tests.

**Structure**:

```yaml
fragments:
  common-output-checks:
    outputContains:
      - "Success"
      - "Duration:"
    exitCode: 0
    
tests:
  - name: "Test feature A"
    command: "myapp feature-a"
    $ref: "#/fragments/common-output-checks"
    
  - name: "Test feature B"
    command: "myapp feature-b"
    $ref: "#/fragments/common-output-checks"
    outputContains:  # Adds to fragment's checks (merges arrays)
      - "Feature B specific output"
```

**Merge Rules**:

1. Fragment fields are inherited by referencing test
2. Test-level fields override fragment fields (except arrays)
3. Arrays are merged: test's array + fragment's array (all must match)
4. Nested object fields merge recursively
5. `$ref` can reference fragments in same file: `#/fragments/id`
6. Circular references detected and reported as error

**Example**:

```yaml
fragments:
  base-http-test:
    timeout: 30
    outputContains:
      - "HTTP/1.1"
      
tests:
  - name: "GET request"
    command: "curl https://example.com"
    $ref: "#/fragments/base-http-test"
    exitCode: 0  # Overrides any exitCode from fragment
    outputContains:  # Merged with fragment's outputContains
      - "200 OK"
```

---

### LifecycleHook

Setup or teardown commands that run at specific points in test execution.

**Types**:

1. **Suite-level setup** (`setup:`): Runs once before first test
2. **Suite-level teardown** (`teardown:`): Runs once after last test, even if tests fail
3. **Per-test setup** (`setupEach:`): Runs before each test
4. **Per-test teardown** (`teardownEach:`): Runs after each test, even if test fails

**Failure Behavior**:

- `setup` failure: Skip all tests, mark as skipped, run `teardown` anyway
- `setupEach` failure: Skip specific test, continue with next test
- `teardown` failure: Report error but doesn't affect test results
- `teardownEach` failure: Report error but doesn't affect test result

**Example**:

```yaml
setup: |
  export TEST_TMPDIR=$(mktemp -d)
  echo "Setup complete: $TEST_TMPDIR"

setupEach: |
  cd "$TEST_TMPDIR"
  touch test-file.txt

teardownEach: |
  rm -f test-file.txt

teardown: |
  rm -rf "$TEST_TMPDIR"
  echo "Cleanup complete"

tests:
  - name: "Test with temp file"
    command: "ls test-file.txt"
    exitCode: 0
```

---

## Relationships

```text
TestSuite (1)
  ├── contains → Tests (1..n)
  ├── defines → Variables (0..n)
  ├── defines → Fragments (0..n)
  └── defines → LifecycleHooks (0..4)

TestDefinition (1)
  ├── references → Variable (0..n) via {{var}} syntax
  ├── references → Fragment (0..1) via $ref
  └── validates → OutputAssertions (0..n) with AND logic

Fragment (1)
  └── provides → TestFields (partial) merged into referencing tests

Variable (1)
  ├── references → Variable (0..1) for nested substitution
  └── references → EnvironmentVariable (0..1) via {{env.VAR}}

LifecycleHook (1)
  └── executes_at → ExecutionPhase (enum: before_suite, after_suite, before_test, after_test)
```

---

## State Transitions

### Test Execution States

```text
PENDING (initial state)
  ↓
VALIDATING (schema validation)
  ↓ [validation passes]
RESOLVING_VARIABLES (substitute {{var}})
  ↓ [no undefined variables]
EXPANDING_FRAGMENTS (merge $ref)
  ↓ [no circular refs]
GENERATING_BATS (create @test blocks)
  ↓ [generation succeeds]
READY_TO_EXECUTE
  ↓
EXECUTING (Bats-core runs tests)
  ↓
COMPLETED (with results: pass/fail/skip)
```

**Error States**:

- VALIDATION_FAILED: YAML syntax error or missing required fields
- VARIABLE_UNDEFINED: Referenced variable not found
- CIRCULAR_REFERENCE: Variable or fragment cycle detected
- GENERATION_FAILED: Cannot create valid Bats code
- EXECUTION_ERROR: Bats-core invocation failed

---

## Field Type Specifications

### Primitive Types

| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| name | string | non-empty, <256 chars | "Check version output" |
| command | string | non-empty, valid shell command | "echo 'test'" |
| exitCode | integer | 0-255 | 0 |
| timeout | integer | > 0 | 30 |
| skip | boolean \| string | - | true or "Not implemented yet" |

### Structured Types

| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| outputContains | array[string] | non-empty strings | ["Success", "Done"] |
| variables | object | keys: identifiers, values: strings | {VAR: "value"} |
| fragments | object | keys: identifiers, values: objects | {frag1: {...}} |
| tests | array[object] | ≥1 test definition | [{name: "...", ...}] |

### Special Syntax

| Syntax | Purpose | Example |
|--------|---------|---------|
| `{{varName}}` | Variable substitution | `{{BASE_URL}}/api` |
| `{{env.VAR}}` | Environment variable | `{{env.PATH}}` |
| `$ref` | Fragment reference | `#/fragments/common` |
| `\|` (YAML literal) | Multi-line string | `command: \| <newline> line1 <newline> line2` |
| `>` (YAML folded) | Folded string | `description: > <newline> Long text...` |

---

## Validation Matrix

| Validation | Timing | Error if Invalid |
|------------|--------|------------------|
| YAML syntax | Parse time | "Parse error at line X: unexpected token" |
| Required fields | Parse time | "Missing required field 'command' in test at line X" |
| Field types | Parse time | "Field 'exitCode' must be integer, got: 'abc'" |
| Variable refs | Pre-execution | "Undefined variable '{{FOO}}' referenced at line X" |
| Fragment refs | Pre-execution | "Undefined fragment '#/fragments/missing' at line X" |
| Circular deps | Pre-execution | "Circular reference detected: {{A}} → {{B}} → {{A}}" |
| Regex patterns | Pre-execution | "Invalid POSIX ERE pattern: '[unmatched'" |
| Assertion logic | Pre-execution | "Cannot specify both outputEquals and outputMatches" |

---

## Entity Lifecycle Example

Full lifecycle of a test suite with variables and fragments:

```yaml
# 1. PARSING: YAML → internal representation
name: "Example Suite"
variables:
  APP: "myapp"
fragments:
  base:
    exitCode: 0
tests:
  - name: "Version check"
    command: "{{APP}} --version"
    $ref: "#/fragments/base"
    outputMatches: "^version [0-9]+"
```

**Processing Steps**:

1. **Parse**: YAML → TestSuite object
2. **Validate**: Check required fields (tests[0].name ✓, tests[0].command ✓)
3. **Resolve Variables**: `{{APP}}` → `"myapp"`, command becomes `"myapp --version"`
4. **Expand Fragments**: Merge `base` fragment (exitCode: 0) into test
5. **Generate Bats**:

   ```bash
   @test "Version check" {
       run myapp --version
       [ "$status" -eq 0 ]
       [[ "$output" =~ ^version [0-9]+ ]]
   }
   ```

6. **Execute**: Bats-core runs generated `.bats` file
7. **Report**: TAP output from Bats-core (pass/fail/skip)

---

## Phase 1 Data Model Complete

All entities, relationships, and validation rules defined. Proceed to contracts and quickstart documentation.
