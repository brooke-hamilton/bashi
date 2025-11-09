# Implementation Plan: Bashi Test Framework Implementation

**Branch**: `002-bashi-implementation` | **Date**: 2025-11-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-bashi-implementation/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement the core Bashi test framework that reads YAML test definitions, validates them against a JSON schema, generates Bats-core test code, executes tests, and reports results. The implementation must maintain strict Bash 3.2+ compatibility, use `yq` for YAML processing, delegate all test execution to Bats-core as a dependency, and provide clear error messages for validation failures.

## Technical Context

**Language/Version**: Bash 3.2+ (macOS and Linux compatibility requirement)  
**Primary Dependencies**: `yq` (YAML processor), Bats-core (test execution engine)  
**Storage**: File-based (YAML test files, generated Bats scripts in temp directory)  
**Testing**: Self-hosting via Bats-core (Bashi tests itself using YAML interface)  
**Target Platform**: macOS, Linux (any system with Bash 3.2+)  
**Project Type**: Single CLI tool  
**Performance Goals**: Schema validation <1 second, <10% test execution overhead vs direct Bats  
**Constraints**: Bash 3.2+ compatibility (no Bash 4+ features), no forking of Bats-core, TAP output compliance  
**Scale/Scope**: Support test suites with dozens to hundreds of tests, handle unlimited command output

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Dependency-First Architecture ✅

- **Status**: PASS
- Bats-core used as external dependency for test execution
- No forking planned
- Thin adapter layer generates Bats code from YAML

### Principle II: Technology Stack Adherence ✅

- **Status**: PASS
- Bash 3.2+ compatibility enforced
- YAML as primary test interface
- Bats-core as test execution engine
- `yq` for YAML processing (required dependency)

### Principle III: YAML Schema Design Philosophy ✅

- **Status**: PASS
- Schema already defined with declarative structure
- Variable substitution via `{{varName}}`
- Fragment reuse via `$ref`
- Clear assertion fields (exitCode, outputContains, etc.)

### Principle IV: Adapter Layer Responsibilities ✅

- **Status**: PASS
- Planned responsibilities align exactly with constitution:
  - Parse YAML with `yq`
  - Generate Bats `@test` blocks
  - Orchestrate Bats-core execution
  - Format output for users
  - Handle variable/fragment resolution
- No reimplementation of testing logic
- TAP compliance preserved

### Principle V: Code Quality Standards ✅

- **Status**: PASS - REQUIRES ONGOING VIGILANCE
- All scripts will use `#!/usr/bin/env bash`
- Strict mode (`set -euo pipefail`) in adapter code
- Variable quoting enforced
- `[[ ... ]]` conditionals for Bash 3.2+
- Shellcheck compliance required
- Clear error messages with actionable guidance

### Principle VI: Testing Philosophy ✅

- **Status**: PASS
- Self-hosting: Bashi will test itself using YAML
- Example test files already exist in specs/001-yaml-schema/examples
- Comprehensive coverage planned

### Principle VII: Documentation Requirements 🟡

- **Status**: PARTIAL - TO BE COMPLETED POST-IMPLEMENTATION
- README, schema reference, examples needed
- Migration guide for existing Bats users
- Contributing guide

### Principle VIII: Compatibility Commitments ✅

- **Status**: PASS
- Target current stable Bats-core
- Bash 3.2+ compatibility maintained
- TAP output preserved
- No breaking of Bats-core features

### Principle IX: Anti-Patterns to Avoid ✅

- **Status**: PASS
- No Bats-core fork ✅
- No feature reimplementation ✅
- TAP compliance preserved ✅
- Error handling required ✅
- No Bash 4+ exclusive features ✅
- Variable quoting enforced ✅

### Principle X: Extension Points 🟡

- **Status**: DEFERRED - POST-MVP
- Future plugin system consideration
- Custom formatters for alternative output
- Schema versioning for evolution

**Overall Gate Status**: ✅ **PASS** - Proceed to Phase 0

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
src/
├── bashi                # Main CLI executable
└── lib/                 # Adapter layer modules
    ├── validator.sh     # YAML validation against JSON schema
    ├── processor.sh     # Variable substitution & fragment resolution
    ├── generator.sh     # Bats test code generation
    └── executor.sh      # Bats execution & result reporting

tests/
├── integration/         # End-to-end tests using Bashi's YAML interface
├── unit/                # Unit tests for individual lib modules
└── fixtures/            # Test data and sample YAML files

test-suite-schema.json   # JSON schema for YAML test definitions (already exists)
```

**Structure Decision**: Single project structure selected. This is a CLI tool with a straightforward adapter layer. The `src/lib/` directory contains modular Bash scripts for each responsibility (validation, processing, generation, execution), sourced by the main `bashi` executable. This aligns with Principle IV (Adapter Layer Responsibilities) and keeps the codebase simple and maintainable.

## Phase 0: Research & Technical Decisions

**Status**: ✅ COMPLETE

See [research.md](./research.md) for detailed analysis of:

- YAML processing with `yq` v4+
- JSON schema validation strategy (custom Bash validation)
- Variable substitution approach
- Fragment resolution algorithm
- Bats code generation templates
- Setup/teardown mapping to Bats functions
- Test execution and TAP output handling
- Error message formatting best practices
- Timeout implementation
- Bash 3.2 compatibility constraints

**Key Decisions**:

- Use `yq` v4+ as required dependency for YAML processing
- Implement custom schema validation using `yq` queries (avoid Python/Node dependencies)
- Generate Bats test files programmatically using heredoc templates
- Delegate all test execution to Bats-core (pass-through TAP output)
- Wrap test commands with `timeout` utility for timeout support
- Maintain Bash 3.2+ compatibility (no associative arrays, no `mapfile`)

## Phase 1: Design & Contracts

**Status**: ✅ COMPLETE

**Artifacts Created**:

- [data-model.md](./data-model.md) - Complete entity definitions and data flow
- [contracts/cli-interface.md](./contracts/cli-interface.md) - CLI contract with all options, error formats, exit codes
- [quickstart.md](./quickstart.md) - Developer quickstart guide

**Data Model Summary**:

- Test Suite → Variables, Fragments, Test Definitions
- Processing pipeline: YAML → Variable Substitution → Fragment Resolution → Bats Generation → Execution
- Clear validation points at each stage
- Error states and handling defined

**CLI Contract Summary**:

- Command: `bashi [options] <test-file.yaml>`
- Options: `--help`, `--version`, `--verbose`, `--validate-only`
- Exit codes: 0 (success), 1 (failure/error), 2 (usage error)
- Structured error message format
- Dependency checks for `yq` and `bats`

**Agent Context Updated**: ✅

- Technology stack added to `.github/copilot-instructions.md`
- Bash 3.2+ compatibility noted
- Dependencies documented (`yq`, Bats-core)

## Phase 2: Task Breakdown

**Status**: ⏸️ NOT STARTED (use `/speckit.tasks` command)

The implementation plan is complete through Phase 1. To proceed with implementation:

1. Run `/speckit.tasks` to generate task breakdown
2. Tasks will be created in `tasks.md` based on this plan
3. Implementation can begin following the task sequence

## Constitution Re-Check (Post-Design)

Re-evaluating constitution compliance after completing design phase:

### Dependency-First Architecture (Re-check) ✅

- **Status**: PASS
- Design maintains Bats-core as external dependency
- No plans to fork or modify Bats-core
- Generator creates Bats-compatible code

### Technology Stack Adherence (Re-check) ✅

- **Status**: PASS
- Bash 3.2+ compatibility validated in research
- YAML interface confirmed
- Bats-core execution confirmed
- `yq` selected as YAML processor

### YAML Schema Philosophy (Re-check) ✅

- **Status**: PASS
- Schema already defined (from 001-yaml-schema)
- Declarative design preserved
- Variable and fragment support planned

### Adapter Responsibilities (Re-check) ✅

- **Status**: PASS
- Clear module boundaries (validator, processor, generator, executor)
- Each module has single responsibility
- No testing logic reimplementation
- Delegates to Bats-core for execution

### Code Quality (Re-check) ✅

- **Status**: PASS - READY FOR IMPLEMENTATION
- Quickstart includes coding standards checklist
- Shellcheck compliance required
- Variable quoting enforced
- Bash 3.2 compatibility validated

### All Other Principles (Re-check) ✅

- **Status**: PASS
- No changes from initial check
- Design aligns with all constitution principles

**Overall Re-Check Status**: ✅ **PASS** - Ready for Phase 2 (Tasks)

## Planning Summary

This implementation plan provides:

- ✅ Complete technical context
- ✅ Constitution compliance verification (passed)
- ✅ Comprehensive research on all technical decisions
- ✅ Data model with clear entities and relationships
- ✅ CLI contract with error handling and exit codes
- ✅ Quickstart guide for developers
- ✅ Updated agent context

**Next Command**: `/speckit.tasks` to generate task breakdown for implementation
