# Copilot Instructions for Bashi

## Project Guidelines

When working on this repository, follow the project constitution located at `.github/memory/constitution.md`. This document defines the core principles, coding standards, and architectural decisions for Bashi.

## Key Principles

- **Dependency-First**: Bats-core is a dependency, not a fork. Do not reimplement Bats-core features.
- **Bash 3.2+ Compatibility**: All shell code must work with Bash 3.2 and later.
- **YAML Schema Design**: Test definitions should be declarative and intuitive.
- **Code Quality**: Follow shellcheck rules, use strict mode (`set -euo pipefail`), and quote all variables.

## Before Making Changes

1. Read `.github/memory/constitution.md` for full project guidelines
2. Run `make lint` to verify shellcheck compliance
3. Run `make test` to ensure tests pass
