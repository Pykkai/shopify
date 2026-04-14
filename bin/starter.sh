#!/usr/bin/env bash
# Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

set -euo pipefail

# - see https://pyyk.ai/?p=19

# - OpenAI seems to be changing which models are eligible for Codex CLI
#   without warning or announcement
# - run the following to determine which models are still eligible
#
# jq -r '.models[].slug' ~/.codex/models_cache.json

codex exec -m gpt-5.4 --sandbox workspace-write <<'EOF'
- generate an application from the specification in the README.md
EOF
