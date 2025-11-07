# Implementation Plan: YAML Test Definition Schema

**Branch**: `001-yaml-schema` | **Date**: November 6, 2025 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-yaml-schema/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Define and implement the YAML schema for Bashi test files, enabling non-Bash users to write CLI tests declaratively. The schema supports test definitions, output assertions (with AND logic), setup/teardown hooks, variable substitution, and fragment reuse. Technical approach: Pure Bash 3.2+ YAML parsing or minimal POSIX tool usage, transform to Bats-core test generation, preserve TAP output.

## Technical Context

**Language/Version**: Bash 3.2+ (macOS and Linux compatibility requirement)  
**Primary Dependencies**: Bats-core (external test execution engine), optional: yq or jq for YAML parsing  
**Storage**: Filesystem - YAML test files (`.bashi.yml`, `.bashi.yaml`), generated temporary Bats files  
**Testing**: Bats-core (self-hosting - Bashi tests itself), integration tests for YAML-to-Bats transformation  
**Target Platform**: macOS 10.x+, Linux (any distribution with Bash 3.2+), CI/CD environments  
**Project Type**: Single project (CLI tool with library components)  
**Performance Goals**: <100ms YAML validation for 100-test suites, <5% overhead vs native Bats-core execution  
**Constraints**: Bash 3.2+ only (no associative arrays), POSIX ERE regex only, no Bats-core modifications, TAP output preservation mandatory  
**Scale/Scope**: Single-file test suites up to ~500 tests, support for test fragment reuse across multiple files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Dependency-First Architecture

✅ **PASS** - Schema defines YAML structure only, delegates test execution to Bats-core. No forking or modification of Bats-core planned.

### Principle II: Technology Stack Adherence

✅ **PASS** - Bash 3.2+ for parsing/transformation, YAML for test interface, Bats-core for execution engine. Strict mode (`set -euo pipefail`) for error handling.

### Principle III: YAML Schema Design Philosophy

✅ **PASS** - Declarative test definitions with explicit fields (command, exitCode, outputContains, etc.). Variable substitution `{{var}}` and fragment references `$ref` per constitution. Intuitive hierarchy (suite → tests → assertions).

### Principle IV: Adapter Layer Responsibilities

✅ **PASS** - Schema implementation will parse YAML, generate Bats `@test` blocks, resolve variables/fragments. Will NOT reimplement test execution - delegates to Bats-core. TAP output preserved.

### Principle V: Code Quality Standards

✅ **PASS** - Plan requires shellcheck compliance, quoted variables, `[[ ]]` conditionals, error messages to stderr with line numbers. File organization: `lib/bashi/` for logic, `schema/` for definitions.

### Principle VI: Testing Philosophy

✅ **PASS** - Self-hosting planned: Bashi will test YAML schema validation using its own YAML interface. Integration tests for YAML→Bats transformation.

### Principle VII: Documentation Requirements

✅ **PASS** - Plan includes `quickstart.md` (Phase 1), schema reference documentation needed. Examples for each YAML field type required.

### Principle VIII: Compatibility Commitments

✅ **PASS** - Bash 3.2+ compatibility enforced (no associative arrays). POSIX ERE regex for compatibility. TAP output preservation mandatory. Bats-core features remain accessible.

### Principle IX: Anti-Patterns

✅ **PASS** - No Bats-core forking, no test execution reimplementation, no TAP breaking, no Bash 4+ features, strict error handling required, all variables quoted.

### Principle X: Extension Points

✅ **PASS** - Schema versioning consideration documented in Out of Scope (future). Fragment system provides extensibility pattern for reuse.

**Overall Status**: ✅ ALL GATES PASSED - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── bashi-core/
│   ├── yaml-parser.bash       # YAML parsing functions (pure Bash or wrapper for yq/jq)
│   ├── schema-validator.bash  # Validate YAML against schema rules
│   ├── variable-resolver.bash # Resolve {{var}} and {{env.VAR}} substitutions
│   ├── fragment-expander.bash # Process $ref fragment references
│   └── bats-generator.bash    # Transform YAML to Bats @test blocks

schema/
├── bashi-schema.json          # JSON Schema definition (for documentation/tooling)
└── examples/                  # Example YAML test files
    ├── basic-test.bashi.yml
    ├── multi-assertion.bashi.yml
    ├── setup-teardown.bashi.yml
    ├── variables.bashi.yml
    └── fragments.bashi.yml

bin/
└── bashi                      # Main CLI entry point (will be implemented in later features)

tests/
├── unit/
│   ├── yaml-parser.bats       # Unit tests for YAML parsing
│   ├── schema-validator.bats  # Unit tests for validation
│   ├── variable-resolver.bats # Unit tests for variable substitution
│   ├── fragment-expander.bats # Unit tests for fragment expansion
│   └── bats-generator.bats    # Unit tests for Bats code generation
├── integration/
│   ├── end-to-end.bats        # Full YAML→Bats→execution tests
│   └── fixtures/              # YAML test files for integration testing
└── self-hosting/
    └── bashi-tests.bashi.yml  # Bashi tests itself using YAML interface
```

**Structure Decision**: Single project structure with Bash library approach. Core parsing/transformation logic in `lib/bashi-core/` modules. Schema definition and examples in `schema/`. Self-hosting tests demonstrate real-world usage. No CLI implementation in this feature (deferred to future work) - focus is pure schema definition and transformation library.

## Complexity Tracking

No constitution violations - all complexity is justified and minimal per thin adapter layer principle.

---

## Phase Completion Status

### ✅ Phase 0: Outline & Research - COMPLETE

**Deliverable**: `research.md`

**Key Decisions**:

- YAML parsing: Hybrid approach (pure Bash for basic, optional yq for advanced)
- Regex: POSIX ERE via Bash `[[ =~ ]]` operator
- Temp files: `/tmp/bashi-{pid}/` with trap cleanup
- Variable resolution: Two-pass (variables first, fragments second) with cycle detection
- Assertions: AND logic via sequential Bats conditionals
- Hooks: Direct mapping to Bats `setup()`/`teardown()` functions

### ✅ Phase 1: Design & Contracts - COMPLETE

**Deliverables**:

- `data-model.md` - Complete entity definitions, relationships, validation rules
- `contracts/test-suite-schema.json` - JSON Schema for YAML validation
- `quickstart.md` - User-facing getting started guide with examples
- `.github/copilot-instructions.md` - Updated agent context (via update script)

**Key Artifacts**:

- 5 core entities: TestSuite, TestDefinition, Variable, Fragment, LifecycleHook
- Field validation matrix with error messages
- Complete lifecycle example from YAML → Bats → execution

### ⏭️ Phase 2: Task Breakdown - NOT STARTED

**Next Command**: `/speckit.tasks`

This phase will create detailed implementation tasks based on the design artifacts from Phase 1.

---

## Implementation Readiness

**Constitution Compliance**: ✅ All 10 principles validated  
**Technical Unknowns**: ✅ All resolved in research phase  
**Data Model**: ✅ Complete with validation rules  
**API Contract**: ✅ JSON Schema published  
**Documentation**: ✅ Quickstart guide ready  
**Agent Context**: ✅ Updated for GitHub Copilot

**Status**: 🟢 Ready for task breakdown (`/speckit.tasks`)

---

## Quick Links

- **Specification**: [spec.md](spec.md)
- **Research**: [research.md](research.md)
- **Data Model**: [data-model.md](data-model.md)
- **Quickstart**: [quickstart.md](quickstart.md)
- **Schema Contract**: [contracts/test-suite-schema.json](contracts/test-suite-schema.json)
- **Constitution**: [../../.specify/memory/constitution.md](../../.specify/memory/constitution.md)
