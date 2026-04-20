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
- find @new tags in README.md
- @new tags apply at the heading level
  - all the content under that heading is part of the specification
  - for example if a @new tag appears in a level 2 heading, all the text up to
    the next level 2 heading or end of file is part of the specification
- these describe new or changed functionality
- update the 
EOF
