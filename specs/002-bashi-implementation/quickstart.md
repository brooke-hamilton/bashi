# Quickstart: Bashi Test Framework Implementation

**Feature**: 002-bashi-implementation  
**Date**: 2025-11-08  
**Purpose**: Quick reference for developers implementing the Bashi test framework

## Project Overview

Bashi is a YAML-driven test framework for Bash CLI tools that generates and executes Bats-core tests. It consists of a thin adapter layer (Bash scripts) that transforms declarative YAML test definitions into executable Bats tests.

**Core Principle**: Bashi is a dependency-first architecture - it uses Bats-core as an external test execution engine without forking or modifying it.

## Prerequisites

Before starting implementation:

- Bash 3.2+ installed (standard on macOS and Linux)
- `yq` v4+ installed (for YAML processing)
- Bats-core installed (for running generated tests)
- Basic understanding of Bats test syntax
- Familiarity with JSON schema and YAML

**Install dependencies**:

```bash
# macOS
brew install yq bats-core

# Ubuntu/Debian
sudo apt install yq bats

# Verify installations
yq --version
bats --version
```

## Quick Start for Developers

### 1. Clone and Setup

```bash
git clone https://github.com/brooke-hamilton/bashi.git
cd bashi
git checkout 002-bashi-implementation

# Review existing artifacts
ls specs/002-bashi-implementation/
# - spec.md          (feature specification)
# - plan.md          (this implementation plan)
# - research.md      (technical decisions)
# - data-model.md    (entity definitions)
# - contracts/       (CLI and API contracts)
# - quickstart.md    (this file)
```

### 2. Understand the Architecture

```text
┌─────────────┐
│   User      │
└──────┬──────┘
       │ runs: bashi test.yaml
       ↓
┌─────────────────────┐
│ src/bashi (main CLI)│ ← Entry point, arg parsing
└──────┬──────────────┘
       │ sources lib modules
       ↓
┌────────────────────────────────────────────┐
│ src/lib/                                   │
│  ├── validator.sh   (YAML schema check)    │
│  ├── processor.sh   (vars + fragments)     │
│  ├── generator.sh   (YAML → Bats code)     │
│  └── executor.sh    (run Bats, report)     │
└──────┬─────────────────────────────────────┘
       │ generates
       ↓
┌─────────────────┐
│ Generated .bats │ ← Temp file with @test blocks
└──────┬──────────┘
       │ executed by
       ↓
┌─────────────────┐
│   Bats-core     │ ← External dependency
└──────┬──────────┘
       │ produces TAP output
       ↓
┌─────────────────┐
│ Test Results    │ ← Passed through to user
└─────────────────┘
```

### 3. Implementation Order (Recommended)

Implement modules in dependency order for easier testing:

**Phase 1**: Core Infrastructure

1. `src/lib/validator.sh` - YAML validation logic
   - Parse YAML with `yq`
   - Check required fields
   - Validate types and patterns
   - Report clear errors

2. `src/bashi` - Main executable
   - Argument parsing
   - Dependency checks (yq, bats)
   - Orchestrate workflow
   - Error handling

**Phase 2**: Processing Pipeline

1. `src/lib/processor.sh` - Variable and fragment resolution
   - Substitute `{{variables}}`
   - Resolve `$ref` fragments
   - Detect circular references
   - Handle merge conflicts

**Phase 3**: Code Generation & Execution

1. `src/lib/generator.sh` - Bats code generation
   - Generate setup/teardown functions
   - Create @test blocks
   - Map assertions to Bats syntax
   - Handle timeouts and skips

1. `src/lib/executor.sh` - Test execution
   - Run Bats with generated file
   - Capture and pass through output
   - Propagate exit codes

**Phase 4**: Testing & Refinement

1. Create integration tests in `tests/integration/`
1. Self-host: Use Bashi to test itself
1. Add example test files
1. Documentation

### 4. Key Implementation Details

#### Variable Substitution (processor.sh)

```bash
# Extract variables from YAML
variables=$(yq '.variables' input.yaml -o=json)

# Find and replace {{varName}} patterns
while IFS= read -r line; do
  # Replace all {{key}} with values from variables
  for key in $(echo "$variables" | jq -r 'keys[]'); do
    value=$(echo "$variables" | jq -r ".[\"$key\"]")
    line="${line//\{\{$key\}\}/$value}"
  done
  echo "$line"
done < input.yaml > processed.yaml
```

#### Fragment Resolution (processor.sh)

```bash
# Extract fragments section
fragments=$(yq '.fragments' input.yaml -o=json)

# For each test with $ref
for test_idx in $(yq '.tests | length' input.yaml); do
  ref=$(yq ".tests[$test_idx].\"\$ref\"" input.yaml)
  
  if [[ "$ref" != "null" ]]; then
    # Extract fragment name from "#/fragments/name"
    fragment_name="${ref#\#/fragments/}"
    
    # Get fragment fields
    fragment=$(echo "$fragments" | jq ".\"$fragment_name\"")
    
    # Merge: fragment fields + test fields (test wins)
    # ... merging logic ...
  fi
done
```

#### Bats Generation (generator.sh)

```bash
# Generate test file header
cat > output.bats <<'EOF'
#!/usr/bin/env bats
EOF

# Add setup functions if defined
if [[ $(yq '.setup' input.yaml) != "null" ]]; then
  cat >> output.bats <<EOF
setup_file() {
  $(yq '.setup' input.yaml)
}
EOF
fi

# Generate each test
yq -o=json '.tests[]' input.yaml | while read -r test; do
  name=$(echo "$test" | jq -r '.name')
  command=$(echo "$test" | jq -r '.command')
  exit_code=$(echo "$test" | jq -r '.exitCode // 0')
  
  cat >> output.bats <<EOF
@test "$name" {
  run $command
  [ "\$status" -eq $exit_code ]
}
EOF
done
```

### 5. Testing Your Implementation

#### Unit Test Example (using Bats)

```bash
# tests/unit/validator.bats
@test "validator detects missing required field" {
  cat > /tmp/invalid.yaml <<EOF
name: "Test Suite"
# Missing required 'tests' field
EOF
  
  run src/lib/validator.sh /tmp/invalid.yaml
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Missing required field" ]]
}
```

#### Integration Test Example

```bash
# tests/integration/basic-execution.bats
@test "bashi executes simple test successfully" {
  cat > /tmp/test.yaml <<EOF
tests:
  - name: "Echo test"
    command: "echo hello"
    outputContains: ["hello"]
EOF
  
  run src/bashi /tmp/test.yaml
  [ "$status" -eq 0 ]
  [[ "$output" =~ "ok 1 Echo test" ]]
}
```

### 6. Validation Checklist

Before considering implementation complete:

- [ ] All constitution principles followed (see plan.md)
- [ ] Bash 3.2 compatible (no associative arrays, no mapfile)
- [ ] All variables quoted (`"$var"` not `$var`)
- [ ] Shellcheck passes (or exceptions documented)
- [ ] `yq` and `bats` dependencies checked at startup
- [ ] Clear error messages for common failures
- [ ] Temp files cleaned up on exit
- [ ] Exit codes match contract (0 = success, 1 = failure)
- [ ] TAP output passed through from Bats
- [ ] Self-hosting tests pass (Bashi tests itself)

### 7. Common Pitfalls

**Avoid These Mistakes**:

1. **Using Bash 4+ features** → Use Bash 3.2 compatible alternatives
   - ❌ `declare -A arr` (associative array)
   - ✅ Use parallel indexed arrays or grep

2. **Unquoted variables** → Always quote
   - ❌ `if [ $var = "x" ]`
   - ✅ `if [ "$var" = "x" ]`

3. **Reimplementing Bats features** → Delegate to Bats-core
   - ❌ Custom test runner
   - ✅ Generate Bats code, let Bats run it

4. **Complex YAML parsing in Bash** → Use yq
   - ❌ `grep` and `sed` to parse YAML
   - ✅ `yq` queries

5. **Ignoring errors** → Use `set -e` and check exit codes
   - ❌ `command; next_command`
   - ✅ `command || return 1`

### 8. Debugging Tips

**Verbose Mode**:

```bash
# Run with verbose flag to see processing steps
src/bashi --verbose tests/debug.yaml
```

**Inspect Generated Bats**:

```bash
# Modify bashi to preserve temp files
# Add: BASHI_DEBUG=1 environment check
# Skip cleanup if BASHI_DEBUG=1
BASHI_DEBUG=1 src/bashi tests/mytest.yaml
cat /tmp/bashi.*/tests.bats
```

**Test Individual Modules**:

```bash
# Test validator directly
bash src/lib/validator.sh tests/valid.yaml
echo $?  # Should be 0

# Test with invalid file
bash src/lib/validator.sh tests/invalid.yaml
echo $?  # Should be 1
```

### 9. Next Steps After Implementation

1. **Documentation**:
   - Update README with installation and usage
   - Document YAML schema reference
   - Add examples directory with common patterns

2. **CI/CD**:
   - Set up GitHub Actions with macOS runner (Bash 3.2 test)
   - Add Linux runner (Bash 4+ test)
   - Run shellcheck in CI

3. **Release**:
   - Tag v0.1.0
   - Publish to package managers
   - Announce to community

## Reference Materials

- **Spec**: [spec.md](./spec.md) - Feature requirements
- **Plan**: [plan.md](./plan.md) - Implementation plan
- **Research**: [research.md](./research.md) - Technical decisions
- **Data Model**: [data-model.md](./data-model.md) - Entity definitions
- **CLI Contract**: [contracts/cli-interface.md](./contracts/cli-interface.md)
- **Constitution**: `../.specify/memory/constitution.md` - Project principles

## Getting Help

- Review spec and plan documents
- Check constitution for architectural guidance
- Look at existing Bats tests for syntax examples
- Consult `yq` documentation for query syntax
- Test on both macOS (Bash 3.2) and Linux (Bash 4+)

## Success Criteria

Implementation is complete when:

1. ✅ User can create YAML test file
2. ✅ Running `bashi test.yaml` validates YAML
3. ✅ Bashi generates valid Bats code
4. ✅ Bats executes tests and reports results
5. ✅ All assertion types work (exitCode, output*, stderr, skip)
6. ✅ Variables and fragments resolve correctly
7. ✅ Setup/teardown hooks execute properly
8. ✅ Error messages are clear and actionable
9. ✅ Bashi tests itself successfully
10. ✅ Works on both macOS and Linux

Good luck with the implementation! 🚀
