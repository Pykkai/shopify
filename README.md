<!-- Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai -->

# Application Starter

This repository is a greenfield C++ application scaffold.

Use this README as your project specification source, then run `./bin/starter.sh`
to apply scaffold-driven updates.

## Purpose

- Provide a minimal C++23 app skeleton with debug/release builds.
- Keep infrastructure ready for CppUnit tests, optional libtorch, and Doxygen docs.

## Requirements

- `c++` compiler with C++23 support.
- `make`.
- Optional:
- `cppunit` for test targets.
- `doxygen` for docs targets.
- `libtorch` when building with `USE_TORCH=1`.

## Build

- Debug: `make debug`
- Release: `make release`

## Run

- Debug binary: `./build/app-debug`
- Release binary: `./build/app-release`

## Test

- Build debug tests: `make test-debug`
- Run debug tests: `make test`
- Build release tests: `make test-release`
- Run release tests: `make test-run-release`

## Next Steps

- Define your app behavior and interfaces in this README.
- Implement application logic in `src/`.
- Replace placeholder tests in `test/` with real CppUnit suites.
- Keep API, CLI, and acceptance criteria updated as the project evolves.
