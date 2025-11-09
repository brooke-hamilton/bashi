# Feature Specification: Bashi Test Framework Implementation

**Feature Branch**: `002-bashi-implementation`  
**Created**: November 8, 2025  
**Status**: Draft  
**Input**: User description: "read and validate the test cases according to the schema, generate the bats test code, execute the tests, report the results"

## Clarifications

### Session 2025-11-08

- Q: Which YAML processing tool should bashi require or prefer? → A: Require `yq` (YAML processor) - user must install it
- Q: When setup commands fail, what should happen to test execution? → A: Abort all tests immediately with error
- Q: What should happen when command output exceeds reasonable limits? → A: No limit, capture all output

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Execute Basic Tests (Priority: P1)

A developer writes a simple YAML test suite with basic assertions and runs it to verify their CLI tool behaves correctly.

**Why this priority**: This is the core value proposition - the ability to define and run tests. Without this, the tool has no purpose.

**Independent Test**: Can be fully tested by creating a minimal YAML file with one test case, running the bashi command, and verifying the test executes and reports pass/fail status.

**Acceptance Scenarios**:

1. **Given** a YAML file with a single test case, **When** the user runs the bashi command with the file path, **Then** the test executes and displays a clear pass/fail result
2. **Given** a test case with an expected exit code, **When** the command runs and returns that exit code, **Then** the test passes
3. **Given** a test case with output assertions, **When** the command produces matching output, **Then** the test passes
4. **Given** a test case that fails its assertions, **When** the test runs, **Then** the failure is clearly reported with details about what went wrong

---

### User Story 2 - Validate Test Configuration (Priority: P2)

A developer creates a YAML test suite and wants immediate feedback if their configuration is invalid before tests run.

**Why this priority**: Schema validation prevents wasted time debugging malformed test files and provides helpful error messages.

**Independent Test**: Can be tested by providing invalid YAML files (missing required fields, wrong types, invalid patterns) and verifying clear, actionable error messages are displayed.

**Acceptance Scenarios**:

1. **Given** a YAML file missing required fields, **When** the user runs bashi, **Then** a validation error clearly identifies the missing field
2. **Given** a YAML file with invalid field types, **When** validation runs, **Then** the error message explains what type is expected
3. **Given** a YAML file with invalid variable names, **When** validation runs, **Then** the error identifies the naming constraint violation
4. **Given** a valid YAML file, **When** validation runs, **Then** no errors are reported and tests proceed

---

### User Story 3 - Use Variables and Fragments (Priority: P3)

A developer wants to reduce duplication in test files by defining reusable variables and test fragments.

**Why this priority**: Improves maintainability and reduces errors in large test suites, but basic testing works without it.

**Independent Test**: Can be tested by creating a YAML file with variables and fragments, running tests that reference them, and verifying the substitutions and inheritance work correctly.

**Acceptance Scenarios**:

1. **Given** a test suite with variables defined, **When** tests use {{varName}} syntax, **Then** the variable values are correctly substituted
2. **Given** a fragment with common test fields, **When** a test references it via $ref, **Then** the fragment's fields are inherited
3. **Given** a test that overrides fragment fields, **When** the test runs, **Then** the local values take precedence over inherited ones

---

### User Story 4 - Setup and Teardown (Priority: P4)

A developer needs to prepare the test environment before tests run and clean up afterward.

**Why this priority**: Essential for realistic testing scenarios but not needed for basic CLI validation.

**Independent Test**: Can be tested by defining setup/teardown commands that create/remove files, then verifying these commands run at the appropriate times and cleanup happens even on test failures.

**Acceptance Scenarios**:

1. **Given** suite-level setup commands, **When** tests begin, **Then** setup runs once before all tests
2. **Given** suite-level teardown commands, **When** tests complete, **Then** teardown runs once after all tests, even if some failed
3. **Given** per-test setup commands, **When** each test runs, **Then** setupEach runs before that individual test
4. **Given** per-test teardown commands, **When** each test completes, **Then** teardownEach runs after that individual test

---

### User Story 5 - Advanced Output Assertions (Priority: P5)

A developer needs to verify complex output patterns using exact matches, contains checks, or regex patterns.

**Why this priority**: Enables sophisticated testing but basic exit code checks handle many scenarios.

**Independent Test**: Can be tested by creating tests with outputEquals, outputContains, outputMatches, and stderr assertions, verifying each assertion type works correctly.

**Acceptance Scenarios**:

1. **Given** a test with outputEquals, **When** the command output matches exactly, **Then** the test passes
2. **Given** a test with outputContains, **When** all specified strings appear in output, **Then** the test passes
3. **Given** a test with outputMatches regex, **When** output matches the pattern, **Then** the test passes
4. **Given** a test with stderr assertion, **When** error output matches, **Then** the test passes

---

### Edge Cases

- What happens when a YAML file references a non-existent fragment?
- How does the system handle circular $ref dependencies?
- What happens when a variable is used but not defined?
- How does the system handle tests that timeout?
- When suite-level setup commands fail, all tests are aborted immediately and teardown still runs
- When per-test setup (setupEach) fails, that specific test is aborted and marked as failed
- How are special characters in output handled for exact matching?
- What happens when the YAML file itself is malformed (invalid YAML syntax)?
- System captures all command output without size limits for assertion validation

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST parse YAML test suite files according to the defined JSON schema
- **FR-002**: System MUST validate YAML files against the schema before executing tests
- **FR-003**: System MUST report schema validation errors with clear, actionable messages including field names and constraint violations
- **FR-004**: System MUST generate Bats test code from valid YAML test definitions
- **FR-005**: System MUST execute generated Bats tests and capture results
- **FR-006**: System MUST report test results showing pass/fail status for each test
- **FR-007**: System MUST substitute variables using {{varName}} syntax throughout test definitions
- **FR-008**: System MUST resolve fragment references using $ref syntax and merge fragment fields into test definitions
- **FR-009**: System MUST support all assertion types: exitCode, outputContains, outputEquals, outputMatches, stderr
- **FR-010**: System MUST execute suite-level setup once before all tests
- **FR-011**: System MUST execute suite-level teardown once after all tests, even if tests fail
- **FR-012**: System MUST execute per-test setup (setupEach) before each individual test
- **FR-013**: System MUST execute per-test teardown (teardownEach) after each individual test
- **FR-014**: System MUST handle test timeouts according to timeout field specifications
- **FR-015**: System MUST respect skip field to skip tests with optional reason messages
- **FR-016**: System MUST fail gracefully with helpful error messages when encountering undefined variables or fragments
- **FR-017**: System MUST detect and report circular fragment references
- **FR-018**: System MUST validate variable names match pattern `^[a-zA-Z_][a-zA-Z0-9_]*$`
- **FR-019**: System MUST validate fragment names match pattern `^[a-zA-Z_][a-zA-Z0-9_-]*$`
- **FR-020**: System MUST enforce exit code range 0-255
- **FR-021**: System MUST require `yq` YAML processor as a dependency and check for its availability before processing test files
- **FR-022**: System MUST display clear error message with installation instructions when `yq` is not found
- **FR-023**: System MUST abort all tests immediately when suite-level setup commands fail with non-zero exit code
- **FR-024**: System MUST still execute teardown commands even when setup fails
- **FR-025**: System MUST abort and fail individual tests when per-test setup (setupEach) commands fail
- **FR-026**: System MUST capture complete stdout and stderr from test commands without size limits for assertion validation

### Key Entities

- **Test Suite**: A collection of related tests with optional variables, fragments, and setup/teardown commands. Contains metadata like name and description.
- **Test Definition**: A single test case with a command to execute and assertions about the expected behavior. May reference fragments for field inheritance.
- **Variable**: A named string value that can be substituted into test definitions using template syntax.
- **Fragment**: A reusable partial test definition that can be referenced by multiple tests to reduce duplication.
- **Assertion**: A condition that must be met for a test to pass (exit code, output patterns, error output).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can define and execute a simple test in under 2 minutes from creating the YAML file to seeing results
- **SC-002**: Schema validation errors are reported within 1 second maximum of running bashi
- **SC-003**: Test execution wall time adds no more than 10% overhead compared to running commands directly via Bats
- **SC-004**: Error messages for common mistakes (missing fields, invalid syntax, undefined references) are clear enough that 90% of users can fix the issue without consulting documentation
- **SC-005**: All six assertion types (exitCode, outputContains, outputEquals, outputMatches, stderr, and skip) work correctly in basic test scenarios
- **SC-006**: Variable substitution and fragment inheritance reduce test file size by at least 30% in typical multi-test suites
