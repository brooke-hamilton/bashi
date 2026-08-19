# Bashi

YAML-driven Bash test framework using Bats-core

## Overview

Bashi is a declarative testing framework for command-line tools that allows you to define CLI tests in YAML and execute them using Bats-core. Write your tests once in a simple YAML format, and Bashi handles the rest - validation, variable substitution, test generation, and execution.

## Why Bashi?

**Write tests without writing Bash.** If you're building CLI tools but aren't comfortable with Bash syntax, Bashi lets you write comprehensive test suites in YAML while still getting the power and reliability of Bats-core.

**Perfect for:**

- Testing CLI applications in any language (Go, Python, Rust, Node.js, etc.)
- Documentation-driven testing where test definitions double as specifications
- Teams with mixed skill levels - YAML is more accessible than Bash scripting
- CI/CD pipelines requiring readable, maintainable test definitions
- Projects where test clarity is as important as test coverage

**Not a Bats replacement.** Bashi is a thin adapter that uses Bats-core as a dependency. You get all the benefits of Bats (TAP compliance, robust execution, ecosystem compatibility) with a more approachable interface for CLI testing scenarios.

## Features

- **Declarative YAML syntax** - Define tests in a clear, readable format
- **Variable substitution** - Use `{{varName}}` syntax for reusable values
- **Bats-core integration** - Leverages the proven Bats testing framework
- **Schema validation** - Validates test suites before execution
- **Multiple assertion types** - Exit codes, stdout/stderr matching, and more
- **Bash 3.2+ compatible** - Works on macOS and Linux

## Installation

### Prerequisites

- Bash 3.2 or higher
- [yq](https://github.com/mikefarah/yq) v4+ (YAML processor)
- [Bats-core](https://github.com/bats-core/bats-core) (test execution engine)

### From GitHub Releases (Recommended)

Download the latest release from GitHub:

```bash
# Download the latest bashi executable
curl -L https://github.com/brooke-hamilton/bashi/releases/latest/download/bashi -o bashi
chmod +x bashi
sudo mv bashi /usr/local/bin/

# Verify installation
bashi --version
```

Or download a specific version:

```bash
# Replace v0.1.0 with desired version
VERSION=v0.1.0
curl -L "https://github.com/brooke-hamilton/bashi/releases/download/${VERSION}/bashi" -o bashi
chmod +x bashi
sudo mv bashi /usr/local/bin/
```

You can also download the JSON Schema for IDE integration:

```bash
VERSION=v0.1.0
curl -L "https://github.com/brooke-hamilton/bashi/releases/download/${VERSION}/bashi-schema.json" -o bashi-schema.json
```

### From Source

For development or to use the latest unreleased changes:

1. Clone the repository:

    ```bash
    git clone https://github.com/brooke-hamilton/bashi.git
    cd bashi
    ```

2. Run bashi directly from the source directory:

    ```bash
    ./src/bashi tests/my-suite.bashi.yaml
    ```

3. Optionally, create an alias in your shell profile (e.g., `~/.bashrc` or `~/.zshrc`):

    ```bash
    alias bashi='<path to cloned repo>/src/bashi'
    ```

## Quick Start

Create a test suite file (e.g., `my-tests.bashi.yaml`):

```yaml
name: My First Test Suite
description: Testing my CLI application

variables:
  app_name: myapp
  version: 1.0.0

tests:
  - name: Version command works
    command: {{app_name}} --version
    exitCode: 0
    outputContains:
      - "{{version}}"

  - name: Help command shows usage
    command: {{app_name}} --help
    exitCode: 0
    outputContains:
      - "Usage:"
      - "Options:"

  - name: Invalid option returns error
    command: {{app_name}} --invalid-option
    exitCode: 1
    stderr: "Unknown option: --invalid-option"
```

Run your tests:

```bash
bashi my-tests.bashi.yaml
```

## Usage

```bash
bashi [OPTIONS] <test-suite.bashi.yaml>...
bashi [OPTIONS] <glob-pattern>...
bashi --init

OPTIONS:
    -h, --help              Show this help message
    --version               Show version information
    --init                  Create a new hello-world.bashi.yaml template in the current directory
    -v, --verbose           Enable verbose output
    --validate-only         Only validate the YAML schema, do not run tests
    -t, --tap               Output in TAP format instead of pretty print
    -T, --timing            Show timing information for each test
    -x, --trace             Print test commands as they are executed
    --timeout SECONDS       Set test execution timeout (default: 300)
    -j, --parallel [N]      Run tests in parallel with N jobs (default: CPU count)
    --no-color              Disable colored output (useful for testing)

GLOB PATTERNS:
    **/*.bashi.yaml         Match all .bashi.yaml files recursively
    tests/*.bashi.yaml      Match .bashi.yaml files in tests/ directory

EXAMPLES:
    bashi --init
    bashi tests/my-suite.bashi.yaml
    bashi 'tests/**/*.bashi.yaml'
    bashi -j 4 'tests/**/*.bashi.yaml' 'docs/**/*.bashi.yaml'
    bashi --validate-only tests/my-suite.bashi.yaml
    bashi --verbose --timeout 60 tests/my-suite.bashi.yaml
    bashi --tap --timing tests/my-suite.bashi.yaml
    bashi --trace --verbose tests/my-suite.bashi.yaml
    bashi --timing --no-color tests/my-suite.bashi.yaml
    bashi --parallel 'tests/**/*.bashi.yaml'
    bashi -j 4 tests/my-suite.bashi.yaml
```

## Test Suite Schema

### Top-Level Fields

- `name` (required) - Human-readable identifier for the test suite
- `description` (optional) - Explanation of what this suite validates
- `variables` (optional) - Key-value pairs for variable substitution
- `parallel` (optional) - Whether this suite can run in parallel (default: true)
- `setupFile` (optional) - Commands to run once before all tests
- `teardownFile` (optional) - Commands to run once after all tests
- `setup` (optional) - Commands to run before each individual test
- `teardown` (optional) - Commands to run after each individual test
- `tests` (required) - Array of test definitions

### Test Definition Fields

- `name` (required) - Descriptive name for the test
- `command` (required) - Shell command to execute
- `exitCode` (optional) - Expected exit code (default: 0)
- `outputContains` (optional) - Array of strings that must appear in stdout
- `outputEquals` (optional) - Exact expected stdout
- `outputMatches` (optional) - Regex pattern for stdout
- `stderr` (optional) - Expected stderr output
- `skip` (optional) - Skip this test (boolean or reason string)
- `timeout` (optional) - Maximum execution time in seconds

### Variable Substitution

Use `{{varName}}` syntax anywhere in your test definitions:

```yaml
variables:
  base_url: https://api.example.com
  api_key: test-key-123

tests:
  - name: API health check
    command: curl -H "Authorization: {{api_key}}" {{base_url}}/health
    exitCode: 0
    outputContains:
      - '"status":"ok"'
```

### Lifecycle Hooks

Bashi supports four lifecycle hooks that map directly to Bats-core functions:

| Hook | Runs | Use Case |
|------|------|----------|
| `setupFile` | Once before all tests | Create temp directories, start services |
| `teardownFile` | Once after all tests | Cleanup temp files, stop services |
| `setup` | Before each test | Reset test state, create test files |
| `teardown` | After each test | Clean up test artifacts |

```yaml
name: "Suite with Lifecycle Hooks"

setupFile: |
  export TEST_DIR=$(mktemp -d)
  echo "Created test directory: $TEST_DIR" >&3

teardownFile: |
  rm -rf "$TEST_DIR"

setup: |
  cd "$TEST_DIR"
  echo "initial data" > testfile.txt

teardown: |
  rm -f testfile.txt

tests:
  - name: "File exists after setup"
    command: cat "$TEST_DIR/testfile.txt"
    exitCode: 0
    outputEquals: "initial data"
```

**Tips:**

- Variables exported in `setupFile` are available to all tests
- Use `echo "message" >&3` to display output during test execution

### Parallel Execution

Bashi supports parallel test execution via Bats-core's `--jobs` flag. Use `-j` or `--parallel` to enable:

```bash
# Run with CPU count parallel jobs (default when using --parallel without a number)
bashi --parallel tests/my-suite.bashi.yaml

# Run with specific number of parallel jobs
bashi -j 4 tests/my-suite.bashi.yaml

# Run multiple test suite files in parallel using glob patterns
bashi -j 4 'tests/**/*.bashi.yaml' 'docs/**/*.bashi.yaml'
```

**Note:** Glob patterns must be quoted to prevent shell expansion. Bashi uses `find` internally to expand patterns like `**/*.bashi.yaml`, which works regardless of your shell's `globstar` setting.

**Prerequisites:** Parallel execution requires [GNU parallel](https://www.gnu.org/software/parallel/) or [shenwei356/rush](https://github.com/shenwei356/rush):

```bash
# Debian/Ubuntu
apt-get install parallel

# macOS
brew install parallel
```

#### Writing Parallel-Safe Tests

Not all tests can run in parallel. Test suites that share state or depend on execution order should use `parallel: false` at the suite level:

```yaml
name: "Tests with shared state"
parallel: false  # Forces entire suite to run serially

tests:
  - name: "First test"
    command: echo "1" >> "$SHARED_FILE"
    exitCode: 0

  - name: "Second test depends on first"
    command: cat "$SHARED_FILE"
    exitCode: 0
    outputContains: "1"
```

**Guidelines for parallel-safe tests:**

| Pattern | Parallel-Safe? | Solution |
|---------|---------------|----------|
| Read-only operations | ✅ Yes | No changes needed |
| Per-test temp directories | ✅ Yes | Use `$TEST_TEMP_DIR` (auto-created) |
| Shared counter files | ❌ No | Use `parallel: false` on suite |
| Tests depending on execution order | ❌ No | Use `parallel: false` on suite |
| Writing to same file from multiple tests | ❌ No | Use unique filenames or `parallel: false` |

## Examples

See the `docs/examples/` directory for more examples:

- `basic-test.bashi.yaml` - Minimal test example
- `multi-assertion.bashi.yaml` - Multiple output assertions
- `variables.bashi.yaml` - Variable substitution
- `setup-teardown.bashi.yaml` - Test lifecycle management
- `fragments.bashi.yaml` - Reusable test patterns
- `complete-suite.bashi.yaml` - Full-featured test suite

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed
- `2` - Invalid usage or missing dependencies

## Development

### Project Structure

```text
.
├── src/
│   ├── bashi              # Main executable
│   ├── bashi-schema.json  # JSON Schema definition
│   └── lib/               # Library modules
│       ├── utils.sh       # Common utilities
│       ├── validator.sh   # Schema validation
│       ├── processor.sh   # YAML processing
│       ├── generator.sh   # Bats generation
│       └── executor.sh    # Test execution
└── tests/
    ├── fixtures/          # Test fixtures
    ├── integration/       # Integration tests
    └── unit/              # Unit tests
```

### Running Tests

Bashi tests itself! The repository includes a Makefile for convenient test execution.

**Show available commands:**

```bash
make help
```

**Run all tests:**

```bash
make test
```

**Run all tests with options:**

```bash
make test OPTS='--tap --trace'
```

**Run a specific test file:**

```bash
make test FILE=./tests/basic.bashi.yaml
```

**Run a specific test with options:**

```bash
make test FILE=./tests/basic.bashi.yaml OPTS='--verbose --timing'
```

**Makefile Variables:**

- `OPTS` - Additional command-line options to pass to bashi (e.g., `--tap`, `--trace`, `--verbose`)
- `FILE` - Path to a specific test file (if not set, runs all `*.bashi.yaml` files in `./tests/`)

You can also run bashi directly:

```bash
bashi tests/basic.bashi.yaml
```

## Contributing

Contributions welcome! Please open an issue or pull request.

## Links

- [Bats-core](https://github.com/bats-core/bats-core) - The underlying test framework
- [yq](https://github.com/mikefarah/yq) - YAML processor
- [JSON Schema](https://json-schema.org/) - Schema specification format
