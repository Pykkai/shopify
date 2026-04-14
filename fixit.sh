#!/usr/bin/env bash
set -euo pipefail

codex exec -m gpt-5-codex <<'EOF'
- there are errors on the build
- run 'make debug', note the errors, and fix
EOF
