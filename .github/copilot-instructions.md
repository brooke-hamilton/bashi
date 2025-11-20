# bashi Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-11-06

## Active Technologies
- Bash 3.2+ (macOS and Linux compatibility requirement) + `yq` (YAML processor), Bats-core (test execution engine) (002-bashi-implementation)
- File-based (YAML test files, generated Bats scripts in temp directory) (002-bashi-implementation)

- Bash 3.2+ (macOS and Linux compatibility requirement) + Bats-core (external test execution engine), optional: yq or jq for YAML parsing (001-yaml-schema)

## Project Structure

```text
src/
tests/
```

