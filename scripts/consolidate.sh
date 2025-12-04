#!/usr/bin/env bash
# consolidate.sh - Create a single-file bashi executable
# Merges src/bashi and all src/lib/*.sh files into one executable

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${PROJECT_ROOT}/src"
OUTPUT_FILE="${1:-${PROJECT_ROOT}/dist/bashi}"

# Create output directory
mkdir -p "$(dirname "${OUTPUT_FILE}")"

echo "Consolidating bashi into single executable: ${OUTPUT_FILE}"

# Start with shebang and header
cat > "${OUTPUT_FILE}" <<'EOF'
#!/usr/bin/env bash
# bashi - YAML-driven Bash test framework
# https://github.com/brooke-hamilton/bashi
# 
# This is a consolidated single-file version of bashi.
# All library functions are included inline below.

set -euo pipefail

# ============================================================================
# Library: utils.sh - Utility functions for Bashi
# ============================================================================

EOF

# Extract and append utils.sh (skip shebang and set -euo pipefail)
sed '1,/^set -euo pipefail$/d' "${SRC_DIR}/lib/utils.sh" >> "${OUTPUT_FILE}"

cat >> "${OUTPUT_FILE}" <<'EOF'

# ============================================================================
# Library: validator.sh - YAML validation against schema
# ============================================================================

EOF

# Extract and append validator.sh (skip shebang and set -euo pipefail)
sed '1,/^set -euo pipefail$/d' "${SRC_DIR}/lib/validator.sh" >> "${OUTPUT_FILE}"

cat >> "${OUTPUT_FILE}" <<'EOF'

# ============================================================================
# Library: processor.sh - YAML processing and variable substitution
# ============================================================================

EOF

# Extract and append processor.sh (skip shebang and set -euo pipefail)
sed '1,/^set -euo pipefail$/d' "${SRC_DIR}/lib/processor.sh" >> "${OUTPUT_FILE}"

cat >> "${OUTPUT_FILE}" <<'EOF'

# ============================================================================
# Library: generator.sh - Bats test code generation
# ============================================================================

EOF

# Extract and append generator.sh (skip shebang and set -euo pipefail)
sed '1,/^set -euo pipefail$/d' "${SRC_DIR}/lib/generator.sh" >> "${OUTPUT_FILE}"

cat >> "${OUTPUT_FILE}" <<'EOF'

# ============================================================================
# Library: executor.sh - Bats test execution and result reporting
# ============================================================================

EOF

# Extract and append executor.sh (skip shebang and set -euo pipefail)
sed '1,/^set -euo pipefail$/d' "${SRC_DIR}/lib/executor.sh" >> "${OUTPUT_FILE}"

cat >> "${OUTPUT_FILE}" <<'EOF'

# ============================================================================
# Main Script: bashi
# ============================================================================

# For consolidated version, PROJECT_ROOT points to the directory containing the schema
# This is set to empty since schema validation is self-contained
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"

EOF

# Extract and append main bashi script, excluding:
# - shebang
# - comments at the top
# - set -euo pipefail
# - SCRIPT_DIR and PROJECT_ROOT definitions
# - source statements for library modules
sed '1,/^set -euo pipefail$/d' "${SRC_DIR}/bashi" | \
    sed '/^SCRIPT_DIR=/,/^PROJECT_ROOT=/d' | \
    sed '/^# Source library modules$/,/^source.*executor\.sh/d' >> "${OUTPUT_FILE}"

# Make executable
chmod +x "${OUTPUT_FILE}"

echo "✓ Consolidated executable created: ${OUTPUT_FILE}"
echo "  Size: $(du -h "${OUTPUT_FILE}" | cut -f1)"
echo "  Lines: $(wc -l < "${OUTPUT_FILE}")"
