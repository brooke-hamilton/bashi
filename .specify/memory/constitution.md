<!--
Sync Impact Report - Version 1.0.1 (Shellcheck Compliance)
==========================================================
Version Change: 1.0.0 → 1.0.1
Rationale: PATCH - Added shellcheck compliance requirement to existing code quality standards

Modified Principles:
  - Principle V (Code Quality Standards): Added shellcheck compliance requirements

Added Requirements:
  - Shellcheck adherence mandatory with explicit overrides documented
  - Code reviews must verify shellcheck compliance
  - Enhanced rationale explaining shellcheck benefits

Removed Sections: N/A

Template Consistency:
  ✅ .specify/templates/plan-template.md - No changes needed
  ✅ .specify/templates/spec-template.md - No changes needed
  ✅ .specify/templates/tasks-template.md - No changes needed
  ✅ .github/prompts/*.prompt.md - No changes needed

Follow-up TODOs: None
-->

# Bashi Constitution

## Core Principles

### I. Dependency-First Architecture

**Rule**: Bats-core is a dependency, not a fork. Bashi uses Bats-core as a direct dependency without modification unless absolutely critical.

**Requirements**:

- MUST use Bats-core as an external dependency
- MUST maintain minimal wrapper philosophy - thin adapter layer only
- MUST preserve upgrade path for Bats-core updates
- MUST contribute bug fixes upstream to Bats-core, not fork

**Rationale**: Prevents fragmentation, ensures long-term maintainability, and respects the upstream project. Forking would create maintenance burden and break compatibility with the broader Bats ecosystem.

### II. Technology Stack Adherence

**Rule**: Bash 3.2+ compatibility is mandatory. YAML is the primary test interface. Bats-core is the test execution engine.

**Requirements**:

- Language: Bash version 3.2+ (matching Bats-core compatibility)
- Test Format: YAML for test definitions
- Test Engine: Bats-core for execution and TAP output
- Shell Standards: POSIX-compliant where possible
- Error Handling: Use `set -e` for strict error handling in adapter code

**Rationale**: Bash 3.2+ ensures compatibility with macOS default shell and older Linux systems. YAML provides accessibility for non-Bash users. Bats-core provides battle-tested TAP-compliant execution.

### III. YAML Schema Design Philosophy

**Rule**: Test definitions MUST be declarative, intuitive, and follow YAML best practices.

**Requirements**:

- Declarative over imperative: describe what to test, not how
- Variable substitution: Support `{{variableName}}` syntax
- Test fragments: Support JSON Reference (`$ref`) for reusability
- Clear assertions: Explicit fields for expectations (exit codes, output patterns)
- Structured hierarchy: Intuitive YAML organization
- The yaml structure is inspired by JUDO but dictated by the required structure of Bats-core tests.

**Rationale**: Inspired by Judo's declarative approach but adapted for Bash testing. Accessibility for users uncomfortable with Bash syntax while preserving full testing power.

### IV. Adapter Layer Responsibilities

**Rule**: The Bash adapter layer transforms YAML to Bats-core execution without reimplementing testing logic.

**Responsibilities**:

- Parse YAML: Convert test definitions to Bats-core compatible format
- Generate Bats tests: Transform YAML into `@test` blocks dynamically
- Manage execution: Orchestrate Bats-core execution
- Format output: Present TAP output in user-friendly formats
- Handle variables: Resolve `{{var}}` substitutions before execution
- Process fragments: Expand `$ref` references during preprocessing
- Preserve semantics: Ensure YAML behavior maps correctly to Bats-core

**Anti-Requirements**:

- MUST NOT reimplement Bats-core testing features
- MUST NOT break TAP compliance
- MUST NOT modify Bats-core behavior

**Rationale**: Clear separation of concerns - adapter handles translation, Bats-core handles execution. Prevents scope creep and maintains dependency-first architecture.

### V. Code Quality Standards

**Rule**: All Bash code MUST follow strict quality conventions for maintainability and safety.

**Bash Coding Conventions** (MANDATORY):

- Use `#!/usr/bin/env bash` for all scripts
- Enable strict mode: `set -euo pipefail` where appropriate
- Quote variables: `"$var"` not `$var` (prevents word splitting)
- Use `[[ ... ]]` for conditionals (Bash 3.2+ feature)
- Prefer `$(...)` over backticks for command substitution
- Use functions for reusability: `function_name() { ... }`
- Document complex logic with inline comments
- Adhere to shellcheck rules where possible
- Use explicit shellcheck directives (`# shellcheck disable=SCXXXX`) with comments explaining why when rules cannot be followed

**File Organization**:

- Core adapter logic: `lib/bashi/` or similar
- YAML schema definitions: `schema/` directory
- Executable entry points: `bin/` directory
- Test files separate from source code
- Use `.bash` extension for Bash libraries

**Error Handling**:

- Provide clear, actionable error messages
- Validate YAML structure before processing
- Report line numbers for YAML parsing errors where possible
- Exit with appropriate status codes (0 = success, non-zero = failure)
- Log errors to stderr, normal output to stdout

**Rationale**: Bash is error-prone without discipline. These conventions prevent common pitfalls (unquoted variables, word splitting, unclear errors) and ensure maintainability. Shellcheck provides automated detection of common errors and anti-patterns, improving code quality and catching bugs before runtime.

### VI. Testing Philosophy

**Rule**: Bashi MUST be self-hosting and comprehensively tested.

**Requirements**:

- Self-hosting: Bashi tests itself using YAML interface
- Comprehensive coverage: Test both YAML parsing and Bats-core integration
- Example-driven: Maintain library of example test files showing patterns
- Regression prevention: Add tests for any discovered bugs

**Rationale**: Self-hosting proves the tool works and provides real-world examples. Comprehensive testing catches integration issues between adapter and Bats-core.

### VII. Documentation Requirements

**Rule**: Documentation MUST clearly explain Bashi's relationship to Bats-core and how to use it.

**Required Documentation**:

- README: Installation, usage, quick start guide
- YAML Schema Reference: Complete documentation of all supported fields
- Migration Guide: How to convert existing Bats tests to Bashi YAML
- Examples: Real-world test scenarios demonstrating capabilities
- Contributing Guide: How to extend Bashi and contribute
- Comparison: Clear articulation of Bashi as Bats-core dependency, not replacement

**Rationale**: Users must understand that Bashi is a YAML interface to Bats-core, not a competing tool. Clear documentation prevents confusion and enables adoption.

### VIII. Compatibility Commitments

**Rule**: Bashi MUST maintain compatibility with Bats-core and preserve TAP compliance.

**Compatibility Requirements**:

- Target current stable Bats-core release
- Maintain Bash 3.2+ compatibility (matching Bats-core)
- Preserve TAP output format from Bats-core
- Ensure core Bats-core features remain accessible through YAML

**Rationale**: Breaking compatibility defeats the dependency-first architecture. TAP compliance ensures interoperability with CI/CD systems and other TAP-consuming tools.

### IX. Anti-Patterns to Avoid

**Rule**: These patterns are explicitly FORBIDDEN.

**Forbidden Actions**:

- ❌ Do NOT fork Bats-core (use as dependency)
- ❌ Do NOT reimplement Bats-core features (delegate to library)
- ❌ Do NOT break TAP compliance (preserve standard output)
- ❌ Do NOT ignore errors (handle and report all failures)
- ❌ Do NOT use Bash 4+ exclusive features (maintain 3.2 compatibility)
- ❌ Do NOT create unquoted variable expansions (always quote variables)

**Rationale**: These anti-patterns represent common failure modes that would compromise the project's core principles. Explicit prohibition prevents drift.

### X. Extension Points

**Rule**: Design for future extensibility without modifying core adapter.

**Future-Proofing Considerations**:

- Plugin system: Allow extensions without core modifications
- Custom formatters: Support alternative output formats beyond TAP
- Hooks: Pre/post test execution hooks for custom logic
- Schema versioning: Version YAML schema to allow evolution

**Rationale**: Requirements will evolve. Designing extension points now prevents breaking changes later and enables community contributions without core modifications.

## Code Quality Standards

All code submitted to Bashi MUST adhere to the Bash coding conventions specified in Principle V. Code reviews MUST verify:

- Proper variable quoting
- Strict mode usage where appropriate
- Clear error messages with actionable guidance
- Inline documentation for non-obvious logic
- File organization following project structure
- Shellcheck compliance (all scripts must pass shellcheck or contain documented exceptions)

Non-compliant code MUST be rejected in review with specific guidance for fixes.

## Anti-Patterns & Success Criteria

### Anti-Patterns (Reiterated for Emphasis)

The anti-patterns listed in Principle IX are non-negotiable. Any PR violating these patterns MUST be rejected immediately with explanation.

### Success Criteria

Bashi succeeds when:

1. ✅ Users can write CLI tests in YAML without touching Bats syntax
2. ✅ Existing Bats-core features remain fully accessible
3. ✅ Test execution delegates cleanly to Bats-core
4. ✅ YAML tests are more approachable for less Bash-savvy users
5. ✅ The adapter layer remains maintainable and well-tested
6. ✅ Documentation clearly explains the relationship with Bats-core
7. ✅ Bats-core can be upgraded without breaking Bashi

## Governance

This constitution supersedes all other development practices and decisions. All code, documentation, and design decisions MUST align with these principles.

**Amendment Process**:

- Amendments require documented justification
- Must include impact analysis on existing code and templates
- Must provide migration plan if breaking changes introduced
- Constitution version MUST be incremented per semantic versioning

**Versioning Policy**:

- MAJOR: Backward incompatible governance/principle removals or redefinitions
- MINOR: New principle/section added or materially expanded guidance
- PATCH: Clarifications, wording, typo fixes, non-semantic refinements

**Compliance Review**:

- All PRs MUST verify compliance with constitution principles
- Complexity MUST be justified against Principle IX anti-patterns
- Reviewers MUST check for Bash coding convention adherence (Principle V)
- Any deviation from principles requires explicit documentation and justification

**Runtime Guidance**:

- Use `.github/prompts/` command files for runtime development guidance
- All prompts MUST align with constitution principles
- Prompts MUST NOT contradict or weaken constitutional requirements

**License**:
Bashi is distributed under the MIT License, ensuring compatibility with Bats-core's MIT license and allowing broad adoption.

**Version**: 1.0.1 | **Ratified**: 2025-11-06 | **Last Amended**: 2025-11-06
