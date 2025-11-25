# Contributing to Bashi

Thank you for your interest in contributing to Bashi! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** describing the issue
- **Steps to reproduce** the behavior
- **Expected behavior** vs. what actually happened
- **Environment details**: OS, Bash version, yq version, Bats version
- **Sample YAML test file** that demonstrates the issue (if applicable)

### Suggesting Features

Feature requests are welcome! Please include:

- **Clear description** of the proposed feature
- **Use case** explaining why this would be useful
- **Example YAML** showing how the feature might work (if applicable)

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the code style guidelines below
3. **Add tests** for any new functionality
4. **Run the test suite** to ensure nothing is broken: `make test`
5. **Run linting** to ensure code quality: `make lint`
6. **Submit your pull request** with a clear description of the changes

## Development Setup

### Prerequisites

- Bash 3.2 or higher
- [yq](https://github.com/mikefarah/yq) v4+ (YAML processor)
- [Bats-core](https://github.com/bats-core/bats-core) (test execution engine)
- [ShellCheck](https://github.com/koalaman/shellcheck) (for linting)

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/bashi.git
cd bashi

# Install bats-core
make install-bats

# Run tests to verify setup
make test

# Run linting
make lint
```

## Code Style Guidelines

### Shell Scripts

- Use `shellcheck` for linting - all scripts must pass without errors
- Use `set -euo pipefail` at the start of scripts
- Use lowercase with underscores for variable names: `my_variable`
- Use uppercase for exported/environment variables: `BASHI_VERBOSE`
- Quote all variable expansions: `"${variable}"`
- Use `[[ ]]` for conditionals instead of `[ ]`
- Add comments for complex logic

### YAML Test Files

- Use `.bashi.yaml` extension for test suite files
- Use descriptive test names that explain what's being tested

## Testing

Test files are located in the `tests/` directory. For some tests, Bashi tests itself using its own framework. Use Bashi-testing-Bashi only for command options or other features that cannot be tested with standard Bashi tests.

```bash
# Run all tests
make test

# Run a specific test file
make test FILE=./tests/basic.bashi.yaml

# Run tests with verbose output
make test OPTS='--verbose --trace'
```

## Questions?

If you have questions, feel free to open an issue with the "question" label.

Thank you for contributing! 🎉
