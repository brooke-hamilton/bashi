---
name: code-review-instructions
description: Guidelines for Copilot code review to ensure quality, consistency, and adherence to project standards
---

# Bashi Code Review Standards

These instructions guide Copilot code review to enforce quality standards, best practices, and project-specific conventions for the bashi testing framework.

## Purpose & Scope

This file defines code review expectations for all code in the bashi repository. Use these guidelines to ensure consistency, maintainability, and adherence to bash scripting best practices across the project.

---

## General Review Principles

- Enforce all rules and best practices defined in `.github/instructions/shell.instructions.md` for shell scripts (`**/*.sh`)
- Enforce all rules and best practices defined in `.github/instructions/markdown.instructions.md` for Markdown files (`**/*.md`)
- Flag code that violates POSIX compatibility when Bash 3.2+ specific features aren't necessary
- Identify potential security issues (command injection, unquoted variables, unsafe file operations)
- Verify error handling is present for critical operations
- Check that changes align with the project's modular architecture (processor, generator, validator, executor, utils)
- Ensure new features have corresponding tests in `tests/` directory
- Make sure the README.md file is up-to-date with the code, especially when command-line options change.
- Make sure that the examples in ./docs/examples/ are updated when features are added or changed.
- IMPORTANT: When the bashi-schema.json file is changed, ensure that all example test files in ./docs/examples/ are updated to conform to the new schema and any examples in the README.md file are also updated.

## Naming Conventions

- Use `snake_case` for function names (e.g., `validate_yaml_file`, `generate_bats_test`)
- Use `UPPER_CASE` for global constants and environment variables
- Use descriptive names that clearly indicate purpose
- Prefix internal/helper functions with underscore (e.g., `_parse_yaml_fragment`)

## Code Style

- Always quote variables to prevent word splitting: `"$variable"` not `$variable`
- Use `[[ ]]` for conditional tests instead of `[ ]` for better error handling
- Prefer `$()` for command substitution over backticks
- Use `local` keyword for all function-local variables
- Limit line length to 100 characters for readability
- Use consistent indentation (2 spaces, no tabs)
- Add blank lines between logical sections of code

## Error Handling

- Use `set -euo pipefail` at the top of scripts for strict error handling
- Check exit codes of critical commands explicitly when needed
- Provide meaningful error messages that help users diagnose issues
- Use `trap` for cleanup operations in scripts that create temporary files
- Validate all user inputs and file paths before use

## Testing Requirements

- All new functions must have corresponding tests in `tests/` directory
- Test files should use `.bashi.yaml` extension for YAML-based tests
- Tests should cover both success and failure cases
- Mock external dependencies when possible
- Verify tests pass with both `bash` and `sh` when applicable

## Security

- Never use `eval` unless absolutely necessary and with sanitized input
- Quote all variables, especially those derived from user input or file content
- Validate file paths to prevent directory traversal attacks
- Use absolute paths or carefully validated relative paths
- Check file permissions before reading sensitive files

## YAML Processing

- Use `yq` as the primary YAML processor (compatible with project requirements)
- Validate YAML structure against `src/bashi-schema.json` before processing
- Handle missing or malformed YAML gracefully with clear error messages
- Support both single-test files and multi-test suites
- Preserve YAML anchors and aliases during processing

## Bats Integration

- Generate Bats tests in temporary directory (not version controlled)
- Include proper setup and teardown functions
- Use descriptive test names that match YAML test descriptions
- Ensure generated tests are executable and properly formatted
- Clean up temporary files after test execution

---

## Code Examples

### Correct Pattern

```bash
# Good: Proper error handling, quoting, and validation
validate_yaml_file() {
  local yaml_file="$1"
  
  if [[ ! -f "$yaml_file" ]]; then
    echo "Error: File not found: $yaml_file" >&2
    return 1
  fi
  
  if ! yq eval '.' "$yaml_file" > /dev/null 2>&1; then
    echo "Error: Invalid YAML in $yaml_file" >&2
    return 1
  fi
  
  return 0
}
```

### Incorrect Pattern

```bash
# Bad: Missing quotes, no error handling, unclear variable names
validate_yaml_file() {
  f=$1
  yq eval '.' $f
}
```

---

## Project-Specific Rules

### Architecture Compliance

- Code should respect the modular structure: processor → validator → generator → executor
- Shared utilities belong in `lib/utils.sh`
- Each module should have a single, clear responsibility
- Avoid circular dependencies between modules

### Compatibility Requirements

- Must work with Bash 3.2+ (macOS default)
- Must work on both macOS and Linux
- External dependencies: `yq` and `bats-core` only
- Avoid GNU-specific extensions when POSIX alternatives exist

### Documentation Standards

- All public functions must have header comments describing purpose, parameters, and return values
- Include usage examples for complex functions
- Update README.md when adding new features or changing CLI interface
- Keep spec documentation in `specs/` directory in sync with implementation

---

## Advanced Guidance

### Performance Considerations

- Minimize subprocess calls in loops
- Use built-in bash string manipulation instead of external commands when possible
- Cache repeated YAML queries when processing large files
- Consider batch operations instead of processing files one at a time

### Edge Cases to Check

- Empty YAML files or files with only whitespace
- YAML files with only comments
- Tests with no assertions
- Extremely long test descriptions or command outputs
- Special characters in test names or descriptions
- Concurrent execution scenarios

---

## What Not to Flag

- Use of Bash 3.2+ features (arrays, `[[`, etc.) - these are allowed and expected
- Dependency on `yq` - this is a project requirement
- Generated Bats code style - focus on correctness, not style of generated output
- Temporary file usage - expected for Bats generation workflow
