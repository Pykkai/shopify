#!/usr/bin/env bash
set -euo pipefail

# - see https://pyyk.ai/?p=19

# - OpenAI seems to be changing which models are eligible for Codex CLI
#   without warning or announcement
# - run the following to determine which models are still eligible
#
# jq -r '.models[].slug' ~/.codex/models_cache.json

codex exec -m gpt-5.4 --sandbox workspace-write <<'EOF'
- find source files in this repository with the tag @codex in comments
- hint: these files will appear in a git status or git diff
- the comments following the @codex tags are instructions for you
- instructions end with the comment block or tag @xedoc
- generate a session timestap at the beginning of each session in the form
  YYYY-MM-DD HH:mm
- check if codex.md exists and if it has changes since the last commit
- concentrate on the parts of codex.md that are new or changed
- after you make modifications related to a particular @codex tag,
  add the session timestamp after the @codex tag
- only update for @codex tags without revision timestamps; those with
  revision timestamps are from previous sessions
- record the revision timestamp in the comment block marked @revision
  with one revision per line with a brief summary of the revisions
- comment code copiously for human review, in particular any block
  larger than a dozen lines
- mark your changes with a @review tag with the session timestamp
- do not look at files in the retired directory, these files are archived
  and not active parts of the project
- prototype quality is sufficient unless otherwise instructed; bloat and slop
  are discouraged, stick to core functionality
- keep helper functions and lambda helpers to a minimum; try to reuse existing
  functionality
- readability matters
- src/template.h and src/template.cpp are provided as style guides and should be followed
  especially when adding new source files, classes, methods, functions, and
  variables; these templates should also be used in refactoring when
  moving methods etc.
EOF
