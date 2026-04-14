#!/usr/bin/env bash
# Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

set -euo pipefail

# - see https://pyyk.ai/?p=19

# - OpenAI seems to be changing which models are eligible for Codex CLI
#   without warning or announcement
# - run the following to determine which models are still eligible
#
# jq -r '.models[].slug' ~/.codex/models_cache.json

main() {
  cat <<'EOF_PROMPT' | codex exec -m gpt-5.4 --sandbox workspace-write
- look for the @test tag in C++ sources and add a CppUnit test
- in function or method scope, add tests for the function or method
- in class scope, add a suite of tests for all member methods
- in other block scope, add tests that will cover that block
- once the tests are implemented, remove the corresponding @test tag
EOF_PROMPT
}

main "$@"
