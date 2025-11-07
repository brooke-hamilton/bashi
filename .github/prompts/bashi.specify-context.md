## Project Context

**Bashi** is a YAML-based testing framework for command-line interfaces (CLIs) that leverages Bats-core (Bash Automated Testing System) as its core testing engine. When writing specifications for Bashi features, keep these constraints and principles in mind.

## Key Constraints for Feature Specifications

### Technology Stack (Fixed)

The following technology decisions are already made and should NOT appear as clarification questions:

- **Language**: Bash 3.2+ (for macOS and Linux compatibility)
- **Test Engine**: Bats-core (dependency, not a fork)
- **Test Format**: YAML for user-facing test definitions
- **Output Format**: TAP (Test Anything Protocol) from Bats-core
- **Error Handling**: Bash strict mode (`set -euo pipefail`)
- **Code Quality**: Shellcheck compliance mandatory

### Architecture Principles (Non-Negotiable)

Features MUST align with these principles from the constitution:

1. **Dependency-First Architecture**: Bats-core is a dependency, not a fork. Features must delegate testing execution to Bats-core, not reimplement it.

2. **Thin Adapter Layer**: Bashi is a YAML-to-Bats translator. Features should focus on parsing, transforming, and orchestrating, not on implementing test execution logic.

3. **TAP Compliance**: All test output must preserve Bats-core's TAP format for CI/CD compatibility.

4. **Bash 3.2+ Compatibility**: No Bash 4+ exclusive features (associative arrays, etc.).

## Feature Categories for Bashi

When specifying Bashi features, they typically fall into these categories:

### 1. YAML Schema Extensions
Features that extend the YAML test definition language:

- **User Scenarios**: Focus on what test authors want to express declaratively
- **Requirements**: YAML field definitions, validation rules, default behaviors
- **Success Criteria**: Ease of use for non-Bash users, clarity of test intent
- **Key Entities**: YAML structure elements, test metadata, assertion types

**Example assumptions to make**:
- Variable substitution uses `{{variableName}}` syntax (already established)
- JSON Reference (`$ref`) pattern for fragments (already established)
- Exit code expectations default to 0 if not specified
- Output assertions are case-sensitive by default

### 2. Adapter Layer Features
Features that transform YAML to Bats-core execution:

- **User Scenarios**: Focus on test execution workflows (parse, transform, run, report)
- **Requirements**: Parsing accuracy, Bats-core command generation, error handling
- **Success Criteria**: Correct Bats-core invocation, preserved TAP output, clear error messages
- **Key Entities**: YAML parser state, generated Bats test blocks, execution context

**Example assumptions to make**:
- YAML parsing uses standard POSIX tools (yq, jq, or pure Bash)
- Generated Bats tests are temporary files cleaned up after execution
- Errors include YAML line numbers where possible
- Setup/teardown map directly to Bats `setup()` and `teardown()` functions

### 3. CLI Features
Features for the `bashi` command-line interface:

- **User Scenarios**: How users invoke Bashi from the command line
- **Requirements**: Command-line flags, argument parsing, file discovery
- **Success Criteria**: Intuitive CLI UX, helpful error messages, standard exit codes
- **Key Entities**: CLI arguments, configuration files, test file paths

**Example assumptions to make**:
- CLI follows standard POSIX conventions (`--flag` for long, `-f` for short)
- Help text follows `--help` and `-h` conventions
- Exit codes: 0 = all tests passed, 1 = test failures, 2 = execution error
- Recursive test discovery by default (like Bats-core)

### 4. Output Formatting Features
Features that present test results to users:

- **User Scenarios**: How users consume test output (CI logs, terminal display)
- **Requirements**: TAP preservation, optional human-readable formats, color support
- **Success Criteria**: Clear pass/fail indication, preserved TAP for CI/CD, accessible formatting
- **Key Entities**: TAP stream, formatted output, color codes, summary statistics

**Example assumptions to make**:
- TAP output is the default (delegated from Bats-core)
- Color output respects `NO_COLOR` environment variable
- Summary includes pass/fail/skip counts
- Verbose mode shows YAML test definitions alongside results

## Specification Guidelines for Bashi

### What to Clarify (Maximum 3 Total)

Only ask for clarification on:

1. **Scope boundaries**: When a feature could reasonably expand beyond the core adapter role (e.g., "Should this feature validate YAML schema or just parse it?")

2. **User experience trade-offs**: When multiple UX approaches have significantly different learning curves (e.g., "Should variables be resolved before or after `$ref` expansion?")

3. **Bats-core integration decisions**: When unclear how to map YAML semantics to Bats-core behavior (e.g., "Should parallel execution use Bats-core's `--jobs` flag or implement custom parallelism?")

### What NOT to Clarify (Make Informed Guesses)

DO NOT ask about:

- **Technology choices**: Language, testing engine, output format (all fixed)
- **Standard behaviors**: Exit codes, error output location (stderr), YAML syntax
- **Bash conventions**: Quoting variables, shellcheck compliance, function naming
- **Bats-core features**: TAP output, `@test` syntax, setup/teardown lifecycle
- **CLI patterns**: Flag syntax, help text format, configuration file locations

### Reasonable Defaults for Bashi Features

When specification is vague, apply these defaults:

| Aspect | Default Assumption | Rationale |
|--------|-------------------|-----------|
| YAML validation | Fail fast with clear error messages | Better UX than cryptic Bash errors |
| Variable resolution | Before test execution, after fragment expansion | Most intuitive for users |
| Test discovery | Recursive in current directory, `*.bashi.yml` or `*.bashi.yaml` | Follows Bats-core conventions |
| Parallel execution | Delegate to Bats-core `--jobs` flag | Honors dependency-first principle |
| Error reporting | YAML line numbers + Bash error message | Helps users debug test definitions |
| Configuration | `.bashirc` in project root, XDG conventions | Standard for CLI tools |
| Setup/teardown | Per-test by default, suite-level optional | Matches Bats-core behavior |
| Output verbosity | TAP by default, `--verbose` for details | Standard testing tool pattern |

### Success Criteria for Bashi Features

When defining success criteria, focus on:

1. **Non-Bash users can accomplish X**: Emphasize accessibility over Bash expertise
2. **Generated Bats tests are correct**: Ensure YAML maps correctly to Bats-core
3. **Error messages are actionable**: Users can fix issues without Bash knowledge
4. **TAP output is preserved**: CI/CD integration works seamlessly
5. **Bats-core features remain accessible**: Don't limit what users can test

**Good success criteria examples**:

- "Users with no Bash experience can write CLI tests using only YAML"
- "All YAML syntax errors include file path and line number"
- "Generated Bats tests execute identically to hand-written Bats tests"
- "TAP output from Bashi is indistinguishable from Bats-core TAP output"
- "Test execution time is within 5% of equivalent Bats-core tests"

**Avoid implementation-focused criteria**:

- ❌ "Parser uses yq for YAML processing" (implementation detail)
- ❌ "Bash functions follow naming convention" (internal code quality)
- ❌ "Generated Bats files are stored in /tmp" (implementation detail)

## Anti-Patterns to Flag in Specifications

If a feature specification implies any of these, it violates the constitution:

1. **Forking Bats-core**: Any suggestion to modify Bats-core behavior internally
2. **Reimplementing test execution**: Features that run tests without delegating to Bats-core
3. **Breaking TAP compliance**: Output formats that replace TAP instead of augmenting it
4. **Bash 4+ dependencies**: Features requiring associative arrays, `readarray`, etc.
5. **Ignoring errors**: Features without clear error handling and reporting

## Example Feature Specifications for Bashi

### Good: YAML Schema Extension

> **Feature**: Support regex patterns in `outputContains` assertions
>
> **User Scenario**: Test authors want to match dynamic output like timestamps or IDs without brittle exact string matching.
>
> **Requirements**:
> - FR-001: System MUST support regex patterns in `outputContains` fields
> - FR-002: System MUST support literal strings for backward compatibility
> - FR-003: System MUST distinguish regex from literals (e.g., `/pattern/` syntax)
>
> **Success Criteria**:
> - Users can match timestamps: `outputContains: ["/\d{4}-\d{2}-\d{2}/"]`
> - Existing literal string assertions continue working unchanged
> - Invalid regex patterns produce clear error messages with line numbers

### Good: Adapter Layer Enhancement

> **Feature**: Generate informative test names from YAML metadata
>
> **User Scenario**: When viewing TAP output, users want descriptive test names instead of generic ones.
>
> **Requirements**:
> - FR-001: System MUST use YAML `name` field for Bats `@test` names
> - FR-002: System MUST sanitize test names to be Bats-compatible
> - FR-003: System MUST fall back to command string if `name` is missing
>
> **Success Criteria**:
> - TAP output shows YAML test names verbatim when valid
> - Special characters in names are escaped appropriately
> - Missing names default to first 50 chars of command

### Bad: Violates Constitution

> **Feature**: Implement parallel test execution with custom job scheduler
>
> **Problem**: This reimplements functionality that should be delegated to Bats-core's `--jobs` flag. Violates Principle I (Dependency-First Architecture).
>
> **Better approach**: "Support Bats-core parallel execution via `--jobs` flag passthrough"

## Quick Reference

When writing Bashi specifications:

- ✅ Focus on YAML schema design and user experience
- ✅ Assume standard Bash/Bats-core conventions
- ✅ Make informed guesses about CLI patterns
- ✅ Emphasize non-Bash user accessibility
- ✅ Ensure TAP output preservation
- ❌ Don't ask about technology choices (already fixed)
- ❌ Don't suggest reimplementing Bats-core features
- ❌ Don't specify Bash implementation details
- ❌ Don't break TAP compliance

