#!/usr/bin/env bash
set -euo pipefail

# - see https://pyyk.ai/?p=19

# - OpenAI seems to be changing which models are eligible for Codex CLI
#   without warning or announcement
# - run the following to determine which models are still eligible
#
# jq -r '.models[].slug' ~/.codex/models_cache.json

codex exec -m gpt-5.4 --sandbox workspace-write <<'EOF'
- add doxygen docs for all namespaces, classes, structs, variables, functions, method, class members
- follow the formats in  src/template.h and src/template.cpp
- add a copyright statement with the current year if any file lacks one
EOF
