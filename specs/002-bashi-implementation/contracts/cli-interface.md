# CLI Contract: Bashi Command-Line Interface

**Feature**: 002-bashi-implementation  
**Date**: 2025-11-08  
**Purpose**: Define the command-line interface contract for the `bashi` executable

## Command Syntax

```bash
bashi [options] <test-file.yaml>
```

## Arguments

### Positional Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `test-file.yaml` | Yes | Path to YAML test suite file |

**Validation**:

- File must exist
- File must be readable
- File extension should be `.yaml` or `.yml` (warning if not, but still process)

**Error Codes**:

- Exit 1 if file not found
- Exit 1 if file not readable

### Options

| Option | Short | Type | Default | Description |
|--------|-------|------|---------|-------------|
| `--help` | `-h` | Flag | - | Show help message and exit |
| `--version` | `-V` | Flag | - | Show version information and exit |
| `--verbose` | `-v` | Flag | Off | Enable verbose output (debug info) |
| `--validate-only` | - | Flag | Off | Only validate YAML, don't run tests |

## Output

### Standard Output (stdout)

**Default Mode** (test execution):

- Bats TAP output passed through directly
- Format example:

```text
1..3
ok 1 Test name
not ok 2 Another test
ok 3 Third test # SKIP reason
```

**Verbose Mode** (`--verbose`):

- Additional progress messages to stdout before TAP output:

```text
==> Validating YAML schema...
==> Schema validation passed
==> Processing test suite...
==> Generating Bats tests...
==> Executing tests...
1..3
ok 1 Test name
...
```

**Validate-Only Mode** (`--validate-only`):

- Success: `Validation successful`
- Failure: Validation errors to stderr

**Help Mode** (`--help`):

- Usage information, options, examples (see Help Text contract)

**Version Mode** (`--version`):

- Version string: `Bashi v0.1.0`

### Standard Error (stderr)

All error messages and diagnostics:

**Error Format**:

```text
Error: [CATEGORY] [Specific problem]

Location: [file:line or field path]
Found: [what was actually present]
Expected: [what should be present]

Fix: [specific action to resolve]
```

**Error Categories**:

- `YAML Validation` - Schema validation failures
- `Variable Reference` - Undefined variable used
- `Fragment Reference` - Undefined or circular fragment reference
- `Dependency Missing` - Required tool not found (yq, bats)
- `File Error` - File not found, not readable, etc.
- `Processing Error` - Internal processing failures

**Examples**:

```text
Error: Dependency Missing - yq not found

The 'yq' YAML processor is required but not installed.

Fix: Install yq using your package manager:
  macOS:   brew install yq
  Ubuntu:  sudo apt install yq
  RHEL:    sudo yum install yq
```

```text
Error: YAML Validation - Missing required field

Location: test-suite.yaml
Field: tests[2].command
Expected: Non-empty string

Fix: Add a 'command' field to test at index 2
```

```text
Error: Variable Reference - Undefined variable

Location: tests[0].command
Found: {{api_url}}
Expected: Variable 'api_url' defined in 'variables' section

Fix: Add 'api_url: "value"' to the variables section
```

## Exit Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 0 | Success | All tests passed |
| 1 | Test Failure | One or more tests failed |
| 1 | Validation Error | YAML validation failed |
| 1 | Processing Error | Variable/fragment resolution failed |
| 1 | Dependency Error | Required tool missing (yq, bats) |
| 1 | File Error | Input file not found or not readable |
| 2 | Usage Error | Invalid command-line arguments |

**Note**: Most errors use exit code 1. Exit code 2 reserved for argument parsing errors.

## Help Text Contract

When invoked with `--help` or `-h`:

```text
Bashi v0.1.0 - YAML-driven Bash CLI testing framework

Usage: bashi [options] <test-file.yaml>

Options:
    -h, --help       Show this help message
    -v, --verbose    Enable verbose output
    -V, --version    Show version information
    --validate-only  Only validate the YAML file, don't run tests

Arguments:
    test-file.yaml   Path to YAML test suite file

Examples:
    bashi tests/my-tests.bashi.yaml
    bashi --verbose tests/integration.bashi.yaml
    bashi --validate-only tests/draft.bashi.yaml

Documentation: https://github.com/brooke-hamilton/bashi
```

## Dependency Checks

Before processing, bashi MUST check for required dependencies:

1. **yq**: Check with `command -v yq`
   - If missing: Display error with installation instructions (see stderr format above)
   - Exit code 1

2. **bats**: Check with `command -v bats`
   - If missing: Display error with installation instructions
   - Exit code 1

**Check Timing**:

- Check `yq` before YAML validation
- Check `bats` before test execution
- Skip `bats` check if `--validate-only` flag used

## Environment Variables

**Consumed** (optional):

- `BASHI_VERBOSE`: If set to `1`, enable verbose mode (equivalent to `--verbose`)
- `BASHI_TEMP_DIR`: Override temp directory location (default: use `mktemp -d`)

**Set for Bats** (passed through):

- Bashi does not modify environment variables for test execution
- Test commands run in user's current environment
- Variables defined in YAML are substituted into commands, not set as env vars

## Temporary Files

**Location**: `$TMPDIR/bashi.XXXXXX` (system temp dir)

**Files Created**:

- `processed.yaml`: Test suite after variable substitution
- `tests.bats`: Generated Bats test file

**Cleanup**:

- All temp files removed on exit via `trap` cleanup handler
- Cleanup runs even if bashi exits with error
- Cleanup skipped only on SIGKILL (uncatchable)

## Working Directory

- Bashi runs from the directory where it's invoked
- Test commands execute in the same working directory
- No automatic directory changes

**Example**:

```bash
cd /path/to/my/project
bashi tests/suite.yaml  # Tests run from /path/to/my/project
```

## Backwards Compatibility

**Versioning**: Semantic versioning (MAJOR.MINOR.PATCH)

- MAJOR: Breaking CLI changes (flag removal, behavior changes)
- MINOR: New features (new flags, new options)
- PATCH: Bug fixes, no interface changes

**Commitment**:

- v0.x.x: No stability guarantees (alpha/beta)
- v1.0.0+: CLI interface stable, backward compatible

## Security Considerations

**Command Injection Risks**:

- Test commands execute directly in shell (by design)
- Variables substituted into commands without sanitization
- Users responsible for securing their test definitions

**File Permissions**:

- Bashi respects file system permissions
- Temp files created with user's default umask
- No privilege escalation

**Information Disclosure**:

- Error messages may reveal file paths
- Verbose mode shows processing details
- Test output may contain sensitive data (user responsibility)

## Examples

### Basic Usage

```bash
bashi tests/cli-tests.bashi.yaml
```

**Output**:

```text
1..3
ok 1 CLI version command works
ok 2 CLI help displays usage
ok 3 Invalid flag shows error
```

**Exit**: 0 (all pass)

### Validation Only

```bash
bashi --validate-only tests/draft.bashi.yaml
echo $?  # Check exit code
```

**Output** (success):

```text
Validation successful
```

**Exit**: 0

**Output** (failure):

```text
Error: YAML Validation - Missing required field
...
```

**Exit**: 1

### Verbose Mode

```bash
bashi --verbose tests/integration.bashi.yaml
```

**Output**:

```text
==> Validating YAML schema...
==> Schema validation passed
==> Processing test suite...
==> Generating Bats tests...
==> Executing tests...
1..5
ok 1 API endpoint returns 200
ok 2 Database connection succeeds
not ok 3 Cache hit rate exceeds 80%
ok 4 Logs contain expected entries
ok 5 Cleanup completes successfully
```

**Exit**: 1 (test 3 failed)

## Future Enhancements (Not in v0.1.0)

- `--format` flag for alternative output formatters
- `--parallel` flag to control Bats parallel execution
- `--filter` flag to run subset of tests
- `--dry-run` flag to show what would execute
- `--json` flag for machine-readable output

These are intentionally deferred to keep initial implementation simple and focused on core functionality.
