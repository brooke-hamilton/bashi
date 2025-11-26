# Bashi YAML Test Examples

This directory contains example YAML test files demonstrating various features of the Bashi schema. All examples use real CLI tools (`yq`, `grep`, and standard Unix utilities) so you can run them on your system.

## Prerequisites

These examples require:

- `yq` - YAML processor (installed as a bashi dependency)
- Standard Unix tools (`echo`, `grep`, `ls`, `cat`, etc.)

## Examples

### 1. `multi-assertion.bashi.yaml`

**Purpose**: Multiple output assertions
**Features**: AND logic, outputEquals, outputMatches, outputContains
**Use case**: Comprehensive output validation
**Tools used**: yq, grep

### 2. `variables.bashi.yaml`

**Purpose**: Variable substitution
**Features**: User variables `{{VAR}}`, environment variables `{{env.VAR}}`
**Use case**: Avoiding duplication, external configuration
**Tools used**: yq, echo

### 3. `setup-teardown.bashi.yaml`

**Purpose**: Test lifecycle management
**Features**: setup, teardown, setupEach, teardownEach
**Use case**: Environment preparation, cleanup, temp files
**Tools used**: yq, standard file operations

### 4. `fragments.bashi.yaml`

**Purpose**: Reusable test patterns
**Features**: Fragment definitions, `$ref` references, field merging
**Use case**: DRY principle, common assertions
**Tools used**: yq

### 5. `complete-suite.bashi.yaml`

**Purpose**: Full-featured test suite
**Features**: All features combined
**Use case**: Real-world CLI testing
**Tools used**: yq with comprehensive YAML operations

## Running Examples

```bash
# Run individual examples
bashi docs/examples/multi-assertion.bashi.yaml
bashi docs/examples/variables.bashi.yaml
bashi docs/examples/setup-teardown.bashi.yaml
bashi docs/examples/fragments.bashi.yaml
bashi docs/examples/complete-suite.bashi.yaml

# Run with verbose output
bashi docs/examples/complete-suite.bashi.yaml --verbose
```

## Schema Validation

Validate examples against the JSON Schema:

```bash
# Using yq to check YAML syntax
yq '.' docs/examples/complete-suite.bashi.yaml

# Using ajv-cli for full schema validation (npm install -g ajv-cli)
ajv validate -s src/bashi-schema.json -d "docs/examples/*.bashi.yaml"
```

## Learning Path

1. Start with `multi-assertion.bashi.yaml` - understand assertion logic
2. Explore `variables.bashi.yaml` - reduce duplication with variables
3. Use `setup-teardown.bashi.yaml` - manage test environment lifecycle
4. Study `fragments.bashi.yaml` - apply DRY principle with reusable fragments
5. Review `complete-suite.bashi.yaml` - see all features working together

## Notes

- All examples use `.bashi.yaml` extension (recommended)
- Examples use `yq` for YAML processing - a real tool you can experiment with
- Setup/teardown blocks create temporary directories for isolation
- Environment variables can be accessed using `{{env.VAR_NAME}}` syntax
