#!/usr/bin/env bash
# Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

set -euo pipefail

# @codex 2026-04-14 12:20
# - update so this takes arguments on the command line that are passed on to the make command
# - mostly this is to specify make targets
# @revision
# - 2026-04-14 12:20 Forwarded command-line arguments into the generated
#   `make` command while preserving the previous default `debug` target.
# @review 2026-04-14 12:20

main()
{
    # Preserve the original behavior when no explicit target is provided so the
    # script still checks the debug build by default.
    local -a make_args=("debug")

    # Rebuild the argument list from the CLI when the caller wants a specific
    # target or extra `make` flags such as `-j` or `VERBOSE=1`.
    if [[ $# -gt 0 ]]; then
        make_args=("$@")
    fi

    # Quote each token so the prompt shows the exact `make` command that should
    # be executed even when an argument contains spaces or shell metacharacters.
    local make_command="make"
    local argument
    for argument in "${make_args[@]}"; do
        printf -v make_command '%s %q' "$make_command" "$argument"
    done

    cat <<EOF_PROMPT | codex exec -m gpt-5.4 --sandbox workspace-write
- there are errors on the build
- run '${make_command}', note the errors, and fix
EOF_PROMPT
}

main "$@"
