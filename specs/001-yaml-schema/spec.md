# Feature Specification: YAML Test Definition Schema

**Feature Branch**: `001-yaml-schema`  
**Created**: November 6, 2025  
**Status**: Draft  
**Input**: User description: "specify the yaml schema for bashi tests"

## Clarifications

### Session 2025-11-06

- Q: When multiple output assertion types are specified (`outputContains`, `outputEquals`, `outputMatches`), how should they be evaluated? → A: Multiple types allowed, all must pass (AND logic)
- Q: How should whitespace be handled when comparing actual output to expected output in assertions? → A: Preserve all whitespace exactly (character-for-character matching)
- Q: When one test in a suite fails, what should happen to the remaining tests? → A: Continue executing remaining tests, report all failures at end
- Q: Which regex syntax should `outputMatches` support for pattern matching? → A: POSIX Extended Regular Expressions (ERE)
- Q: When setup or teardown hooks fail, how should test execution proceed? → A: Setup failure skips remaining tests; teardown always runs regardless

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Basic Test Definition (Priority: P1)

Test authors want to define a single CLI command test with expected exit code and output validation using YAML, without writing any Bash code.

**Why this priority**: This is the core value proposition of Bashi - enabling non-Bash users to write CLI tests declaratively. Without this, the entire framework has no purpose.

**Independent Test**: Can be fully tested by creating a YAML file with a single test that runs `echo "hello"`, expects exit code 0, and validates output contains "hello". This delivers immediate value as a working test.

**Acceptance Scenarios**:

1. **Given** a YAML file with a test definition, **When** the test specifies a command, exit code, and output expectations, **Then** the system validates the YAML structure is correct
2. **Given** a valid basic test YAML file, **When** processed by Bashi, **Then** the system generates equivalent Bats-core test code
3. **Given** a test with missing required fields, **When** validated, **Then** the system reports which fields are missing with file location

---

### User Story 2 - Multiple Tests in Suite (Priority: P2)

Test authors want to organize multiple related CLI tests in a single YAML file to test different aspects of the same command or related commands.

**Why this priority**: Real-world testing requires multiple test cases. This enables practical test suites while maintaining the declarative simplicity.

**Independent Test**: Can be tested by creating a YAML file with 3 tests for the same command with different arguments, each independently verifiable. Delivers value as a reusable test suite.

**Acceptance Scenarios**:

1. **Given** a YAML file with multiple test definitions, **When** each test has a unique identifier, **Then** all tests are processed independently
2. **Given** multiple tests in one file, **When** one test definition is invalid, **Then** the system reports the specific invalid test without blocking validation of other tests
3. **Given** a test suite YAML, **When** processed, **Then** tests execute in the order defined in the file

---

### User Story 3 - Setup and Teardown Hooks (Priority: P3)

Test authors want to define setup operations that run before tests (e.g., creating temporary files) and teardown operations that run after tests (e.g., cleanup), without repeating code.

**Why this priority**: Essential for tests that need environmental preparation, but not required for basic command testing. Enables more complex test scenarios.

**Independent Test**: Can be tested by creating a YAML suite that defines setup creating a temp file, a test that reads it, and teardown that removes it. Verifies lifecycle management works.

**Acceptance Scenarios**:

1. **Given** a test suite with setup defined, **When** tests execute, **Then** setup runs once before the first test
2. **Given** a test suite with teardown defined, **When** all tests complete, **Then** teardown runs once after the last test
3. **Given** a test suite with per-test setup, **When** each test executes, **Then** setup runs before each individual test

---

### User Story 4 - Variable Substitution (Priority: P3)

Test authors want to define reusable values (like file paths, URLs, or common strings) once and reference them throughout the test suite to avoid duplication and enable easy updates.

**Why this priority**: Improves maintainability for complex test suites but not essential for basic testing. Reduces duplication significantly.

**Independent Test**: Can be tested by defining a variable for a directory path and using it in multiple test commands. Verifies variable resolution works correctly.

**Acceptance Scenarios**:

1. **Given** variables defined at suite level, **When** tests reference those variables using `{{variableName}}` syntax, **Then** variables are substituted with their values before test execution
2. **Given** undefined variables referenced in tests, **When** validation occurs, **Then** the system reports which variables are undefined
3. **Given** variables with nested references, **When** resolved, **Then** the system reports circular dependency errors

---

### User Story 5 - Test Fragments and Reuse (Priority: P4)

Test authors want to define common test patterns or partial test definitions once and reuse them across multiple tests using references, reducing duplication in large test suites.

**Why this priority**: Optimization for large-scale test suites. Not needed for basic or medium-sized test projects. Enables DRY principle at scale.

**Independent Test**: Can be tested by defining a fragment with common output assertions and referencing it from multiple tests. Verifies fragment expansion works.

**Acceptance Scenarios**:

1. **Given** a fragment defined with `$ref` key, **When** tests reference that fragment, **Then** the fragment content is merged into the test definition
2. **Given** fragments with overlapping field definitions, **When** merged into tests, **Then** test-level values override fragment values
3. **Given** circular fragment references, **When** validated, **Then** the system reports the circular dependency error with involved fragments

---

### Edge Cases

- What happens when YAML file is empty or contains only comments?
- How does system handle YAML files with invalid syntax (malformed YAML)?
- What happens when required fields are present but have empty/null values?
- How does system handle very long command strings or output patterns?
- What happens when test names contain special characters or are duplicated?
- How does system handle YAML anchors and aliases (native YAML features)?
- What happens when file paths in commands contain spaces or special characters?
- How does system handle multi-line strings for commands or output patterns?

## Requirements *(mandatory)*

### Functional Requirements

#### Core Structure

- **FR-001**: System MUST support a root `tests` field containing an array of test definitions
- **FR-002**: System MUST support an optional root `name` field for suite identification
- **FR-003**: System MUST support an optional root `description` field for suite documentation
- **FR-004**: Each test definition MUST have a unique identifier within the suite

#### Test Definition Fields

- **FR-005**: Each test MUST support a `name` field describing what is being tested
- **FR-006**: Each test MUST support a `command` field specifying the CLI command to execute
- **FR-007**: Each test MUST support an optional `exitCode` field with default value of 0
- **FR-008**: Each test MUST support an optional `outputContains` field as an array of expected output strings
- **FR-009**: Each test MUST support an optional `outputEquals` field for exact output matching
- **FR-010**: Each test MUST support an optional `outputMatches` field for regex pattern matching using POSIX Extended Regular Expressions (ERE) syntax
- **FR-010a**: When multiple output assertion types are specified, ALL assertions MUST pass for the test to succeed (AND logic)
- **FR-011**: Each test MUST support an optional `stderr` field for error output validation
- **FR-012**: Each test MUST support an optional `skip` field to disable test execution with reason
- **FR-013**: Each test MUST support an optional `timeout` field to limit execution time in seconds

#### Setup and Teardown

- **FR-014**: System MUST support optional suite-level `setup` field containing commands to run before all tests
- **FR-015**: System MUST support optional suite-level `teardown` field containing commands to run after all tests
- **FR-016**: System MUST support optional suite-level `setupEach` field containing commands to run before each test
- **FR-017**: System MUST support optional suite-level `teardownEach` field containing commands to run after each test
- **FR-018a**: When suite-level `setup` fails, system MUST skip all remaining tests and mark them as skipped
- **FR-018b**: When `setupEach` fails for a test, system MUST skip that specific test and continue with remaining tests
- **FR-018c**: System MUST always execute `teardown` and `teardownEach` hooks regardless of test or setup failures
- **FR-018d**: System MUST report setup and teardown failures distinctly from test failures

#### Variables

- **FR-019**: System MUST support optional root `variables` field as key-value pairs
- **FR-020**: System MUST support variable substitution using `{{variableName}}` syntax in command and output fields
- **FR-021**: System MUST validate all variable references are defined before test execution
- **FR-022**: System MUST support environment variable access using `{{env.VAR_NAME}}` syntax

#### Fragments and Reuse

- **FR-023**: System MUST support defining reusable test fragments using `fragments` root field
- **FR-024**: System MUST support referencing fragments using JSON Reference `$ref` syntax
- **FR-025**: System MUST merge fragment content with test definitions, allowing test values to override fragment values
- **FR-026**: System MUST detect and report circular fragment references

#### Validation

- **FR-027**: System MUST validate YAML syntax and report parsing errors with line numbers
- **FR-028**: System MUST validate required fields are present in each test definition
- **FR-029**: System MUST validate field types match expected schema (strings, numbers, arrays, objects)
- **FR-030**: System MUST report all validation errors together rather than failing on first error
- **FR-031**: System MUST include file path and line number in all validation error messages

#### File Organization

- **FR-032**: System MUST support `.bashi.yml` and `.bashi.yaml` file extensions
- **FR-033**: System MUST support standard `.yml` and `.yaml` extensions when explicitly specified
- **FR-034**: System MUST process files with UTF-8 encoding

#### Test Execution

- **FR-035**: When a test fails, system MUST continue executing remaining tests in the suite
- **FR-036**: System MUST report all test failures together at completion, not stop on first failure

### Key Entities

- **Test Suite**: The root YAML document containing metadata, configuration, and test definitions. Has optional name, description, variables, fragments, and lifecycle hooks. Contains one or more test definitions.

- **Test Definition**: An individual test case specifying a command to execute and validation criteria. Has required name and command fields. Has optional exit code expectation, output validation rules, timeout, and skip flag.

- **Variable**: A named value defined at suite level and referenced in test definitions using substitution syntax. Enables reusability and maintainability. Can reference environment variables.

- **Fragment**: A reusable partial test definition that can be referenced by multiple tests. Supports DRY principle by extracting common patterns. Merged with test definitions at processing time.

- **Lifecycle Hook**: Setup or teardown commands that run at specific points in test execution. Can run once per suite or once per test. Enables environmental preparation and cleanup.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users with no Bash experience can write valid CLI tests using only YAML documentation and examples
- **SC-002**: All YAML syntax errors include file path and line number for quick debugging
- **SC-003**: Schema validation completes in under 100ms for test suites with up to 100 tests
- **SC-004**: Test definitions are readable and understandable by non-technical stakeholders reviewing test coverage
- **SC-005**: 95% of common CLI testing scenarios (command execution, exit codes, output validation) are expressible without custom Bash code
- **SC-006**: Generated Bats-core test code from YAML is functionally identical to hand-written equivalent Bats tests
- **SC-007**: Variable substitution reduces duplication by at least 40% in test suites with repeated values
- **SC-008**: Fragment reuse reduces test definition length by at least 30% in test suites with common patterns

## Assumptions *(mandatory)*

1. **YAML Parser**: System will use standard POSIX-compatible tools or pure Bash parsing. No assumption about specific YAML library.

2. **File Discovery**: Test files will be discovered recursively in the current directory by default, following Bats-core conventions.

3. **Variable Syntax**: Variable substitution uses `{{variableName}}` to avoid conflicts with Bash variable syntax `${var}`.

4. **Fragment Resolution**: Fragments are expanded after variable substitution to allow variables within fragments.

5. **Exit Code Default**: If not specified, tests expect exit code 0 (success), matching standard CLI conventions.

6. **Output Validation**: By default, output assertions are case-sensitive and match against stdout unless stderr is explicitly specified. Whitespace is preserved exactly (character-for-character matching) including leading/trailing spaces, tabs, and newlines. Regex patterns use POSIX Extended Regular Expressions (ERE) syntax for Bash 3.2+ compatibility.

7. **Encoding**: All YAML files are UTF-8 encoded, matching modern file system standards.

8. **Test Ordering**: Tests execute in the order defined in the YAML file, providing predictable behavior.

9. **Timeout Default**: If not specified, tests have no timeout limit and can run indefinitely.

10. **Multi-line Support**: Multi-line strings use YAML's standard literal (`|`) or folded (`>`) block scalar syntax.

## Out of Scope *(mandatory)*

1. **Custom Assertion Functions**: Creating new assertion types beyond basic exit code, output matching, and regex patterns. Users requiring custom assertions should use Bats-core directly.

2. **Conditional Test Execution**: Logic to skip tests based on runtime conditions (OS, installed tools, etc.). This belongs in CI/CD configuration or Bats-core features.

3. **Test Dependencies**: Ordering tests based on dependencies or running specific tests based on previous test results. Bats-core handles test isolation.

4. **Data-Driven Testing**: Parameterized tests that run the same test with multiple input datasets. Can be achieved with variables and multiple test definitions.

5. **Mocking and Stubbing**: Intercepting or replacing commands during tests. This is test implementation logic that belongs in Bats-core.

6. **Schema Versioning**: Multiple schema versions or migration between versions. Initial version establishes foundation; versioning is future consideration.

7. **IDE Integration**: Language server, syntax highlighting, autocomplete for YAML files. These are separate tools, not schema definition concerns.

8. **Performance Benchmarking**: Measuring command execution time or resource usage. Bashi focuses on functional testing, not performance testing.
