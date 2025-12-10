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

## Release Process

Bashi uses an automated release process that creates a consolidated single-file executable and publishes it as a GitHub Release.

### Version Management

Bashi tracks two independent version numbers:

1. **Tool Version** (`VERSION` in `src/bashi`) - Increments with any code changes
2. **Schema Version** (`version` in `src/bashi-schema.json`) - Only increments when the YAML schema changes

### Creating a Release

Releases are created automatically when a version tag is pushed to the repository:

1. **Update version numbers**:

   ```bash
   # Update tool version in src/bashi
   VERSION="0.2.0"
   
   # Only update schema version if schema changed
   # Edit src/bashi-schema.json: "version": "1.1.0"
   ```

2. **Commit version updates**:

   ```bash
   git add src/bashi src/bashi-schema.json
   git commit -m "Release v0.2.0"
   ```

3. **Create and push tag**:

   ```bash
   git tag v0.2.0
   git push origin main
   git push origin v0.2.0
   ```

4. **GitHub Actions will automatically**:
   - Run all tests
   - Build the consolidated executable using `scripts/consolidate.sh`
   - Verify the consolidated version works
   - Create a GitHub Release with:
     - `bashi` - Single-file executable
     - `bashi-schema.json` - JSON Schema file
     - Auto-generated release notes

### Manual Release Trigger

You can also trigger a release manually from the GitHub Actions UI:

1. Go to Actions → Release workflow
2. Click "Run workflow"
3. Enter the version (e.g., `v0.2.0`)
4. Click "Run workflow"

### Release Artifacts

Each release includes:

- **bashi** - Consolidated single-file executable containing all library code
- **bashi-schema.json** - JSON Schema for YAML test definitions

### Testing Releases

Before creating an official release, test the consolidation process locally:

```bash
# Build consolidated executable
./scripts/consolidate.sh dist/bashi

# Verify it works
./dist/bashi --version
./dist/bashi tests/hello.bashi.yaml

# Run all tests
./dist/bashi 'tests/**/*.bashi.yaml'
```

## Questions?

If you have questions, feel free to open an issue with the "question" label.

Thank you for contributing! 🎉
