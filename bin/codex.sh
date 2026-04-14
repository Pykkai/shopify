#!/usr/bin/env bash
set -euo pipefail

# - see https://pyyk.ai/?p=19

# - OpenAI seems to be changing which models are eligible for Codex CLI
#   without warning or announcement
# - run the following to determine which models are still eligible
#
# jq -r '.models[].slug' ~/.codex/models_cache.json

readonly MODEL_CACHE="${HOME}/.codex/models_cache.json"
readonly PREFERRED_MODEL="${CODEX_MODEL:-gpt-5.4}"
readonly FALLBACK_MODELS=(
  "gpt-5.4"
  "gpt-5.3-codex"
  "gpt-5.4-mini"
  "gpt-5.2"
)

get_available_models() {
  if [[ -r "$MODEL_CACHE" ]] && command -v jq >/dev/null 2>&1; then
    jq -r '.models[].slug' "$MODEL_CACHE" 2>/dev/null || true
  fi
}

build_candidate_models() {
  local -A seen=()

  if [[ -n "$PREFERRED_MODEL" ]]; then
    seen["$PREFERRED_MODEL"]=1
    echo "$PREFERRED_MODEL"
  fi

  local model
  for model in "${FALLBACK_MODELS[@]}"; do
    if [[ -z "${seen[$model]+x}" ]]; then
      seen["$model"]=1
      echo "$model"
    fi
  done
}

model_is_in_cache() {
  local target="$1"
  local available
  while IFS= read -r available; do
    [[ "$available" == "$target" ]] && return 0
  done
  return 1
}

run_codex_with_model() {
  local model="$1"
  local output_file="$2"

  # Keep all CLI output visible while also capturing it for failure inspection.
  set +e
  codex exec -m "$model" --sandbox workspace-write <<'EOF_PROMPT' 2>&1 | tee "$output_file"
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
EOF_PROMPT
  local status=${PIPESTATUS[0]}
  set -e

  return "$status"
}

is_model_compat_error() {
  local output_file="$1"
  grep -Eqi \
    "model is not supported|unsupported.*model|unknown model|invalid_request_error" \
    "$output_file"
}

main() {
  local -a candidates=()
  local -a available_models=()

  mapfile -t candidates < <(build_candidate_models)
  mapfile -t available_models < <(get_available_models)

  local model
  for model in "${candidates[@]}"; do
    if [[ ${#available_models[@]} -gt 0 ]] && ! model_is_in_cache "$model" < <(printf '%s\n' "${available_models[@]}"); then
      continue
    fi

    echo "Trying Codex model: $model" >&2

    local output_file
    output_file="$(mktemp)"

    if run_codex_with_model "$model" "$output_file"; then
      rm -f "$output_file"
      return 0
    fi

    if is_model_compat_error "$output_file"; then
      echo "Model unavailable in current auth context: $model" >&2
      rm -f "$output_file"
      continue
    fi

    echo "Codex failed with model '$model' for a non-model reason; stopping fallback." >&2
    rm -f "$output_file"
    return 1
  done

  echo "No compatible Codex model succeeded. Set CODEX_MODEL or refresh ~/.codex/models_cache.json." >&2
  return 1
}

main "$@"
