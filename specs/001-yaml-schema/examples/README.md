# Bashi YAML Test Examples

This directory contains example YAML test files demonstrating various features of the Bashi schema.

## Examples

### 1. `basic-test.bashi.yml`
**Purpose**: Minimal test example  
**Features**: Simple command, exit code, outputContains  
**Use case**: Getting started, basic validation

### 2. `multi-assertion.bashi.yml`
**Purpose**: Multiple output assertions  
**Features**: AND logic, outputEquals, outputMatches, outputContains  
**Use case**: Comprehensive output validation

### 3. `variables.bashi.yml`
**Purpose**: Variable substitution  
**Features**: User variables `{{VAR}}`, environment variables `{{env.VAR}}`  
**Use case**: Avoiding duplication, external configuration

### 4. `setup-teardown.bashi.yml`
**Purpose**: Test lifecycle management  
**Features**: setup, teardown, setupEach, teardownEach  
**Use case**: Environment preparation, cleanup, temp files

### 5. `fragments.bashi.yml`
**Purpose**: Reusable test patterns  
**Features**: Fragment definitions, `$ref` references, field merging  
**Use case**: DRY principle, common assertions

### 6. `complete-suite.bashi.yml`
**Purpose**: Full-featured test suite  
**Features**: All features combined  
**Use case**: Real-world CLI testing

## Running Examples

```bash
# Once Bashi is implemented:
bashi examples/basic-test.bashi.yml
bashi examples/complete-suite.bashi.yml

# For now, these serve as reference for schema implementation
```

## Schema Validation

Validate examples against the JSON Schema:

```bash
# Using ajv-cli (npm install -g ajv-cli)
ajv validate -s ../contracts/test-suite-schema.json -d "*.bashi.yml"
```

## Learning Path

1. Start with `basic-test.bashi.yml` - understand core concepts
2. Try `multi-assertion.bashi.yml` - learn assertion logic
3. Explore `variables.bashi.yml` - reduce duplication
4. Use `setup-teardown.bashi.yml` - manage test environment
5. Study `fragments.bashi.yml` - apply DRY principle
6. Review `complete-suite.bashi.yml` - see everything together

## Notes

- All examples use `.bashi.yml` extension (recommended)
- Examples assume a hypothetical `myapp` CLI tool
- Variable values and URLs are placeholders for demonstration
- Some examples require test environment setup (temp directories, etc.)
