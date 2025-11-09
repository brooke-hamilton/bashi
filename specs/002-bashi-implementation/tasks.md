# Tasks: Bashi Test Framework Implementation

**Input**: Design documents from `/specs/002-bashi-implementation/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cli-interface.md

**Tests**: Self-hosting tests using Bashi's YAML interface are included as part of the implementation (self-testing capability is a core requirement).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Single project structure:

- Source: `src/`
- Tests: `tests/`
- Paths shown below follow this structure

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create directory structure: `src/lib/`, `tests/integration/`, `tests/unit/`, `tests/fixtures/`
- [ ] T002 [P] Move `test-suite-schema.json` to project root if not already there
- [ ] T003 [P] Create `.shellcheckrc` configuration file for Bash linting standards
- [ ] T004 [P] Create dependency check helper function in `src/lib/utils.sh` for `yq` and `bats` availability

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core library modules that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 Create `src/lib/validator.sh` with basic structure and error handling functions
- [ ] T006 Implement YAML file existence and readability checks in `src/lib/validator.sh`
- [ ] T007 Implement required field validation (tests array) in `src/lib/validator.sh`
- [ ] T008 Implement field type validation (arrays, objects, strings, integers) in `src/lib/validator.sh`
- [ ] T009 Implement pattern validation for variable names (`^[a-zA-Z_][a-zA-Z0-9_]*$`) in `src/lib/validator.sh`
- [ ] T010 Implement pattern validation for fragment names (`^[a-zA-Z_][a-zA-Z0-9_-]*$`) in `src/lib/validator.sh`
- [ ] T011 Implement exit code range validation (0-255) and timeout value validation (≥1 second) in `src/lib/validator.sh`
- [ ] T012 Create `src/lib/processor.sh` with basic structure for variable and fragment processing
- [ ] T013 Create `src/lib/generator.sh` with basic structure for Bats code generation
- [ ] T014 Create `src/lib/executor.sh` with basic structure for Bats execution
- [ ] T015 Update `src/bashi` main executable to source all lib modules and implement argument parsing

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Execute Basic Tests (Priority: P1) 🎯 MVP

**Goal**: Enable users to write simple YAML test files with basic assertions and run them to verify CLI tool behavior

**Independent Test**: Create a minimal YAML file with one test case, run `bashi test.yaml`, verify test executes and reports pass/fail status

### Implementation for User Story 1

- [ ] T016 [US1] Implement basic Bats test generation for simple test cases in `src/lib/generator.sh`
- [ ] T017 [US1] Generate `@test` blocks with test name from YAML in `src/lib/generator.sh`
- [ ] T018 [US1] Generate `run` command with test command from YAML in `src/lib/generator.sh`
- [ ] T019 [US1] Implement exit code assertion generation (`[ "$status" -eq N ]`) in `src/lib/generator.sh`
- [ ] T020 [US1] Implement `outputContains` assertion generation using `grep` in `src/lib/generator.sh`
- [ ] T021 [US1] Implement `outputEquals` assertion generation in `src/lib/generator.sh`
- [ ] T022 [US1] Implement Bats file execution in `src/lib/executor.sh` using `bats` command
- [ ] T023 [US1] Pass through TAP output from Bats to stdout in `src/lib/executor.sh`
- [ ] T024 [US1] Propagate exit codes correctly (0 for success, 1 for failure) in `src/lib/executor.sh`
- [ ] T025 [US1] Create integration test `tests/integration/basic-test.bats` that runs bashi with simple YAML
- [ ] T026 [US1] Create example `tests/fixtures/basic-test.bashi.yaml` with single test case
- [ ] T027 [US1] Test with failing test case to verify failure reporting works

**Checkpoint**: At this point, User Story 1 should be fully functional - basic tests can be written and executed

---

## Phase 4: User Story 2 - Validate Test Configuration (Priority: P2)

**Goal**: Provide immediate feedback if YAML configuration is invalid before tests run

**Independent Test**: Provide invalid YAML files (missing fields, wrong types) and verify clear error messages

### Implementation for User Story 2

- [ ] T028 [US2] Implement structured error message formatting in `src/lib/validator.sh`
- [ ] T029 [US2] Add specific error messages for missing required fields in `src/lib/validator.sh`
- [ ] T030 [US2] Add specific error messages for invalid field types with expected type info in `src/lib/validator.sh`
- [ ] T031 [US2] Add specific error messages for naming pattern violations in `src/lib/validator.sh`
- [ ] T032 [US2] Implement `--validate-only` flag in `src/bashi` to skip test execution
- [ ] T033 [US2] Create integration test `tests/integration/validation-errors.bats` with various invalid YAML files
- [ ] T034 [US2] Create test fixture `tests/fixtures/invalid-missing-field.bashi.yaml`
- [ ] T035 [US2] Create test fixture `tests/fixtures/invalid-wrong-type.bashi.yaml`
- [ ] T036 [US2] Create test fixture `tests/fixtures/invalid-variable-name.bashi.yaml`
- [ ] T037 [US2] Verify validation completes in under 1 second (performance requirement)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Use Variables and Fragments (Priority: P3)

**Goal**: Enable developers to reduce duplication using reusable variables and test fragments

**Independent Test**: Create YAML with variables and fragments, run tests, verify substitutions and inheritance work

### Implementation for User Story 3

- [ ] T038 [P] [US3] Implement variable extraction from YAML in `src/lib/processor.sh`
- [ ] T039 [P] [US3] Implement fragment extraction from YAML in `src/lib/processor.sh`
- [ ] T040 [US3] Implement `{{varName}}` substitution throughout YAML in `src/lib/processor.sh`
- [ ] T041 [US3] Validate all referenced variables are defined in `src/lib/processor.sh`
- [ ] T042 [US3] Implement `$ref` fragment reference parsing in `src/lib/processor.sh`
- [ ] T043 [US3] Implement fragment field merging (test fields override fragment) in `src/lib/processor.sh`
- [ ] T044 [US3] Implement circular reference detection in `src/lib/processor.sh`
- [ ] T045 [US3] Add error messages for undefined variable references in `src/lib/processor.sh`
- [ ] T046 [US3] Add error messages for undefined fragment references in `src/lib/processor.sh`
- [ ] T047 [US3] Add error messages for circular fragment references in `src/lib/processor.sh`
- [ ] T048 [US3] Create integration test `tests/integration/variables.bats` with variable substitution tests
- [ ] T049 [US3] Create integration test `tests/integration/fragments.bats` with fragment inheritance tests
- [ ] T050 [US3] Create test fixture `tests/fixtures/variables.bashi.yaml` (may already exist from spec examples)
- [ ] T051 [US3] Create test fixture `tests/fixtures/fragments.bashi.yaml` (may already exist from spec examples)
- [ ] T052 [US3] Test override behavior: local test fields take precedence over fragment fields

**Checkpoint**: All basic features now work - variables and fragments enable maintainable test suites

---

## Phase 6: User Story 4 - Setup and Teardown (Priority: P4)

**Goal**: Enable test environment preparation and cleanup with setup/teardown commands

**Independent Test**: Define setup/teardown that create/remove files, verify execution timing and cleanup on failures

### Implementation for User Story 4

- [ ] T053 [P] [US4] Implement `setup_file()` generation for suite-level setup in `src/lib/generator.sh`
- [ ] T054 [P] [US4] Implement `teardown_file()` generation for suite-level teardown in `src/lib/generator.sh`
- [ ] T055 [P] [US4] Implement `setup()` generation for per-test setup (setupEach) in `src/lib/generator.sh`
- [ ] T056 [P] [US4] Implement `teardown()` generation for per-test teardown (teardownEach) in `src/lib/generator.sh`
- [ ] T057 [US4] Verify Bats executes setup_file before all tests
- [ ] T058 [US4] Verify Bats executes teardown_file after all tests (even on failure)
- [ ] T059 [US4] Create integration test `tests/integration/setup-teardown.bats` verifying execution order
- [ ] T060 [US4] Create test fixture `tests/fixtures/setup-teardown.bashi.yaml` (may already exist from spec examples)
- [ ] T061 [US4] Test that suite-level setup failure aborts all tests (FR-023 requirement)
- [ ] T062 [US4] Test that teardown still runs when setup fails (FR-024 requirement)

**Checkpoint**: Test environment management now works - realistic testing scenarios enabled

---

## Phase 7: User Story 5 - Advanced Output Assertions (Priority: P5)

**Goal**: Support complex output verification using exact matches, contains checks, and regex patterns

**Independent Test**: Create tests with all assertion types, verify each works correctly

### Implementation for User Story 5

- [ ] T063 [P] [US5] Implement `outputMatches` regex assertion generation in `src/lib/generator.sh`
- [ ] T064 [P] [US5] Implement `stderr` capture and assertion generation in `src/lib/generator.sh`
- [ ] T065 [P] [US5] Implement `skip` field handling with `skip "reason"` in `src/lib/generator.sh`
- [ ] T066 [P] [US5] Implement `timeout` field handling with `timeout` command wrapper in `src/lib/generator.sh`
- [ ] T067 [US5] Validate regex patterns are valid POSIX ERE in `src/lib/validator.sh`
- [ ] T068 [US5] Test stderr capture works correctly with Bats
- [ ] T069 [US5] Create integration test `tests/integration/advanced-assertions.bats` for all assertion types
- [ ] T070 [US5] Create test fixture `tests/fixtures/multi-assertion.bashi.yaml` (may already exist from spec examples)
- [ ] T071 [US5] Test timeout behavior: commands exceeding limit are terminated
- [ ] T072 [US5] Test skip behavior: skipped tests appear in TAP output with reason

**Checkpoint**: All assertion types now work - sophisticated testing scenarios enabled

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T073 [P] Add `--verbose` flag implementation with progress messages in `src/bashi`
- [ ] T074 [P] Add `--version` flag showing version string in `src/bashi`
- [ ] T075 [P] Add `--help` flag with full usage information in `src/bashi`
- [ ] T076 [P] Implement temp file cleanup with trap in `src/bashi`
- [ ] T077 [P] Add dependency checks for `yq` with installation instructions in `src/bashi`
- [ ] T078 [P] Add dependency check for `bats` with installation instructions in `src/bashi`
- [ ] T079 [P] Run shellcheck on all Bash scripts and fix violations (document exceptions per constitution Principle V)
- [ ] T080 [P] Verify Bash 3.2 compatibility by testing on macOS or using Docker with bash:3.2 image
- [ ] T081 [P] Create README.md with installation and usage instructions
- [ ] T082 [P] Copy example files from `specs/001-yaml-schema/examples/` to project `examples/` directory
- [ ] T083 Self-hosting test: Use Bashi to test itself with YAML test suite in `tests/self-test.bashi.yaml`
- [ ] T084 Verify all success criteria from spec.md are met
- [ ] T085 [P] Create CONTRIBUTING.md guide
- [ ] T086 Code review: Ensure all variables quoted, strict mode used, error handling complete
- [ ] T087 [P] Validate schema validation completes in under 1 second with 100+ test YAML file in tests/performance/
- [ ] T088 [P] Benchmark test execution overhead is under 10% wall time vs direct Bats execution

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - Can proceed sequentially in priority order (P1 → P2 → P3 → P4 → P5)
  - Some parallelization possible within each story
- **Polish (Phase 8)**: Depends on desired user stories being complete (minimum: US1 for MVP)

### User Story Dependencies

- **User Story 1 (P1)**: Foundation only - No dependencies on other stories ✅ **MVP READY**
- **User Story 2 (P2)**: Foundation only - Independent of US1 (validation is separate concern)
- **User Story 3 (P3)**: Foundation + processor.sh - Independent, but enhances US1
- **User Story 4 (P4)**: Foundation + generator.sh - Independent feature addition
- **User Story 5 (P5)**: Foundation + generator.sh - Independent feature addition

### Within Each User Story

- Foundational modules (validator, processor, generator, executor) before story tasks
- Generator tasks before executor tasks within a story
- Integration tests after implementation
- Test fixtures can be created in parallel with implementation

### Parallel Opportunities

**Phase 1 (Setup)**: T002, T003, T004 can run in parallel

**Phase 2 (Foundational)**: Limited parallelization

- T005-T011 (validator) should be sequential (same file)
- T012, T013, T014 (different lib files) can run in parallel after validator complete

**Phase 3 (US1)**: Limited parallelization

- T016-T021 (generator assertions) can have some parallelization
- T025, T026 can run in parallel

**Phase 4 (US2)**: Most tasks sequential (same validator file)

- T034-T036 (test fixtures) can run in parallel

**Phase 5 (US3)**: T038-T039 can run in parallel

- T048-T051 (integration tests and fixtures) can run in parallel

**Phase 6 (US4)**: T053-T056 can run in parallel (different functions)

- T059-T060 can run in parallel

**Phase 7 (US5)**: T063-T066 can run in parallel (different assertion types)

**Phase 8 (Polish)**: Most tasks marked [P] can run in parallel

---

## Parallel Example: User Story 5

```bash
# Launch all assertion generation tasks together:
Task: "Implement outputMatches regex assertion in src/lib/generator.sh"
Task: "Implement stderr capture and assertion in src/lib/generator.sh"
Task: "Implement skip field handling in src/lib/generator.sh"
Task: "Implement timeout field handling in src/lib/generator.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (~4 tasks)
2. Complete Phase 2: Foundational (~11 tasks) - CRITICAL
3. Complete Phase 3: User Story 1 (~12 tasks)
4. **STOP and VALIDATE**: Test basic execution end-to-end
5. **Total MVP**: ~27 tasks to working prototype

### Incremental Delivery

1. **MVP (US1)**: Basic test execution - immediately useful
2. **+US2**: Add validation - improves user experience
3. **+US3**: Add variables/fragments - reduces duplication in test suites
4. **+US4**: Add setup/teardown - enables realistic testing scenarios
5. **+US5**: Add advanced assertions - sophisticated testing capabilities
6. **Polish**: Production-ready tool

Each increment adds value without breaking previous functionality.

### Parallel Team Strategy

With multiple developers (after Foundational phase complete):

- **Developer A**: User Story 1 (P1) - Core execution
- **Developer B**: User Story 2 (P2) - Validation
- **Developer C**: User Story 3 (P3) - Variables/fragments

Stories can merge independently as they complete.

---

## Task Summary

- **Total Tasks**: 88
- **Setup**: 4 tasks
- **Foundational**: 11 tasks (BLOCKING)
- **User Story 1 (P1)**: 12 tasks 🎯 MVP
- **User Story 2 (P2)**: 10 tasks
- **User Story 3 (P3)**: 15 tasks
- **User Story 4 (P4)**: 10 tasks
- **User Story 5 (P5)**: 10 tasks
- **Polish**: 16 tasks

**MVP Scope**: Phases 1-3 (27 tasks) deliver basic working test execution

**Full Feature**: All 88 tasks deliver complete Bashi framework

---

## Validation Checklist

Format validation confirms:

- ✅ All tasks follow `- [ ] [TID] [P?] [Story?] Description` format
- ✅ Task IDs sequential (T001-T088)
- ✅ [P] markers only on parallelizable tasks
- ✅ [Story] labels present for user story phases (US1-US5)
- ✅ No [Story] labels in Setup, Foundational, or Polish phases
- ✅ File paths included in all implementation task descriptions
- ✅ Each user story has independent test criteria
- ✅ Tasks organized by priority (P1 first for MVP)

---

## Notes

- Self-hosting is built into the implementation (Bashi tests itself)
- Example YAML files already exist in `specs/001-yaml-schema/examples/`
- Bash 3.2 compatibility must be verified (no associative arrays, no mapfile)
- All scripts must pass shellcheck
- Constitution principles guide all implementation decisions
- Stop after any user story to validate and potentially ship increment
