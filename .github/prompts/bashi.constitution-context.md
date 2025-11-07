/speckit.constitution

This prompt is used to provide context to the speckit.constitution prompt.

## Project Identity

**Bashi** is a YAML-based testing framework for command-line interfaces (CLIs) that leverages Bats-core (Bash Automated Testing System) as its core testing engine. While Bashi can test Bash scripts, its primary goal is to provide a declarative, human-readable YAML schema for testing any CLI tool invoked from the command line. Bashi maintains the full power and TAP-compliance of Bats-core underneath while making CLI testing accessible to users who may not be comfortable writing Bash test syntax directly.

## Core Principles

### 1. Dependency-First Architecture
- **Bats-core is a dependency, not a fork**: Bashi uses Bats-core as a direct dependency without modification unless absolutely critical
- **Minimal wrapper philosophy**: Bashi serves as a thin adapter layer between YAML definitions and Bats-core execution
- **Upgrade path**: When Bats-core releases updates, Bashi should be able to adopt them with minimal friction
- **Respect upstream**: Bug fixes and enhancements for core testing functionality belong in Bats-core, not Bashi

### 2. Technology Stack Adherence
- **Language**: Bash (version 3.2+, maintaining Bats-core compatibility)
- **Test Format**: YAML as the primary interface for test definitions
- **Test Engine**: Bats-core for test execution and TAP output
- **Shell Standards**: POSIX-compliant where possible, with Bash-specific features used intentionally
- **Error Handling**: Use `set -e` for strict error handling in adapter code

### 3. YAML Schema Design Philosophy
Inspired by Judo's declarative approach but adapted for Bash testing:

- **Declarative over imperative**: Test definitions should describe what to test, not how to test
- **Intuitive structure**: Follow YAML best practices with clear hierarchies
- **Variable substitution**: Support `{{variableName}}` syntax for dynamic test values
- **Test fragments**: Support JSON Reference (`$ref`) for reusable test components
- **Clear assertions**: Explicit fields for expectations (exit codes, output patterns, etc.)

#### Core YAML Structure
```yaml
# Test metadata
name: string
description: string
vars:
  variableName: value

# Test suite definition
tests:
  - name: string
    description: string
    setup:
      - command strings (optional)
    command: string
    cwd: string (optional)
    expectCode: integer
    outputContains:
      - patterns or strings
    outputDoesntContain:
      - patterns or strings
    teardown:
      - command strings (optional)

# Reusable components
components:
  fragmentName:
    - reusable definitions
```

### 4. Adapter Layer Responsibilities
The Bash adapter layer in Bashi must:

- **Parse YAML**: Convert YAML test definitions into Bats-core compatible test files
- **Generate Bats tests**: Transform YAML test cases into `@test` blocks dynamically
- **Manage execution**: Orchestrate Bats-core execution for YAML-defined test suites
- **Format output**: Present Bats-core TAP output in user-friendly formats
- **Handle variables**: Resolve variable substitutions before test execution
- **Process fragments**: Expand `$ref` references during YAML preprocessing
- **Preserve semantics**: Ensure YAML-defined behavior maps correctly to Bats-core execution

### 5. Code Quality Standards

#### Bash Coding Conventions
- Use `#!/usr/bin/env bash` for all scripts
- Enable strict mode: `set -euo pipefail` where appropriate
- Quote variables: `"$var"` not `$var`
- Use `[[ ... ]]` for conditionals (Bash 3.2+ feature)
- Prefer `$(...)` over backticks for command substitution
- Use functions for reusability: `function_name() { ... }`
- Document complex logic with inline comments

#### File Organization
- Place core adapter logic in `lib/bashi/` or similar structure
- Keep YAML schema definitions in `schema/` directory
- Store executable entry points in `bin/` directory
- Maintain test files separate from source code
- Use `.bash` extension for Bash libraries

#### Error Handling
- Provide clear, actionable error messages
- Validate YAML structure before processing
- Report line numbers for YAML parsing errors where possible
- Exit with appropriate status codes (0 = success, non-zero = failure)
- Log errors to stderr, normal output to stdout

### 6. Testing Philosophy
- **Self-hosting**: Bashi should be able to test itself using its own YAML interface
- **Comprehensive coverage**: Test both YAML parsing and Bats-core integration
- **Example-driven**: Maintain a library of example test files showing common patterns
- **Regression prevention**: Add tests for any bugs discovered

### 7. Documentation Requirements
- **README**: Clear installation, usage, and quick start guide
- **YAML Schema Reference**: Complete documentation of all supported YAML fields
- **Migration Guide**: How to convert existing Bats tests to Bashi YAML format
- **Examples**: Real-world test scenarios demonstrating capabilities
- **Contributing Guide**: How to extend Bashi and contribute back
- **Comparison**: Clear articulation of how Bashi relates to Bats-core (dependency, not replacement)

### 8. Compatibility Commitments
- **Bats-core version support**: Target current stable Bats-core release
- **Bash version**: Maintain Bash 3.2+ compatibility (matching Bats-core)
- **TAP compliance**: Preserve TAP output format from Bats-core
- **Feature parity**: Core Bats-core features should remain accessible through YAML

### 9. Anti-Patterns to Avoid
- ❌ **Do NOT fork Bats-core**: Use it as a dependency
- ❌ **Do NOT reimplement Bats-core features**: Delegate to the library
- ❌ **Do NOT break TAP compliance**: Preserve standard output formats
- ❌ **Do NOT ignore errors**: Handle and report all failure cases
- ❌ **Do NOT use Bash 4+ exclusive features**: Maintain 3.2 compatibility
- ❌ **Do NOT create unquoted variable expansions**: Always quote to prevent word splitting

### 10. Extension Points
Future-proofing considerations:

- **Plugin system**: Allow extensions without modifying core adapter
- **Custom formatters**: Support for alternative output formats beyond TAP
- **Hooks**: Pre/post test execution hooks for custom logic
- **Schema versioning**: Version YAML schema to allow evolution

## Success Criteria
Bashi succeeds when:

1. ✅ Users can write Bash tests in YAML without touching Bats syntax
2. ✅ Existing Bats-core features remain fully accessible
3. ✅ Test execution delegates cleanly to Bats-core
4. ✅ YAML tests are more approachable for less Bash-savvy users
5. ✅ The adapter layer remains maintainable and well-tested
6. ✅ Documentation clearly explains the relationship with Bats-core
7. ✅ Bats-core can be upgraded without breaking Bashi

## License
Bashi is distributed under the MIT License, ensuring compatibility with Bats-core's MIT license and allowing broad adoption.

---

*This constitution serves as the foundational guide for all development decisions in Bashi. When in doubt, refer back to these principles.*
