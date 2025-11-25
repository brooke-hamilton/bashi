# Bashi

YAML-driven Bash test framework using Bats-core

## Overview

Bashi is a declarative testing framework that allows you to define CLI tests in YAML and execute them using Bats-core. Write your tests once in a simple YAML format, and Bashi handles the rest - validation, variable substitution, test generation, and execution.

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

### Install Bashi

Bashi does not have releases yet, and is not published to package managers. A simple way to install Bashi is to clone the repository and create a command alias that points to the full path.

1. Clone the repository:

    ```bash
    git clone https://github.com/brooke-hamilton/bashi.git
    cd bashi
    ```

1. Alias the full path to the `bashi` script. You can add this to your shell profile (e.g., `~/.bashrc` or `~/.zshrc`):

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
bashi [OPTIONS] <test-suite.bashi.yaml>

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show version information
    --verbose               Enable verbose output
    --validate-only         Only validate the YAML schema, don't run tests
    -t, --tap               Output in TAP format instead of pretty print
    -T, --timing            Show timing information for each test
    -x, --trace             Print test commands as they are executed
    --timeout SECONDS       Set test execution timeout (default: 300)
    --no-color              Disable colored output (useful for testing)

EXAMPLES:
    bashi tests/my-suite.bashi.yaml
    bashi --validate-only tests/my-suite.bashi.yaml
    bashi --verbose --timeout 60 tests/my-suite.bashi.yaml
    bashi --tap --timing tests/my-suite.bashi.yaml
    bashi --trace --verbose tests/my-suite.bashi.yaml
    bashi --timing --no-color tests/my-suite.bashi.yaml
```

## Test Suite Schema

### Top-Level Fields

- `name` (required) - Human-readable identifier for the test suite
- `description` (optional) - Explanation of what this suite validates
- `variables` (optional) - Key-value pairs for variable substitution
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
