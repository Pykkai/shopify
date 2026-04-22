# Copyright 2026 Brad Shapcott brad@shapcott.com

# Keep the repository helper commands near the top for discoverability while
# still making the application release build the default `make` entry point.
.DEFAULT_GOAL := release

# Coding agent commands

codex:
	bash bin/codex

dox:
	bash bin/dox

broken:
	bash bin/broken

starter:
	bash bin/starter

testable:
	bash bin/testable

update:
	bash bin/update

# Keep the build layout explicit so the project is easy to inspect and extend
# during review. The debug and release binaries are emitted separately to avoid
# flag confusion and to make it obvious which artifact is being run.
CXX := c++
CXXFLAGS := -std=c++23 -Wall -Wextra -Wpedantic
USE_TORCH ?= 1
USE_MLPACK ?= 1
CPP_DEFINES := -DUSE_TORCH=$(USE_TORCH)
TORCH_DIR ?= 3p/libtorch
MLPACK_DIR ?= 3p/mlpack-4.6.2/src
# Treat libtorch headers as third-party system headers so warnings from those
# upstream headers do not drown out warnings from this project.
TORCH_INC = -isystem $(TORCH_DIR)/include -isystem $(TORCH_DIR)/include/torch/csrc/api/include
TORCH_LIB = -L$(TORCH_DIR)/lib -Wl,-rpath,$(TORCH_DIR)/lib -ltorch -ltorch_cpu -lc10
MLPACK_INC = -isystem $(MLPACK_DIR) -isystem /opt/homebrew/include
MLPACK_LIB = -L/opt/homebrew/lib -Wl,-rpath,/opt/homebrew/lib -larmadillo
TORCH_CXXFLAGS :=
TORCH_LDFLAGS :=
MLPACK_CXXFLAGS :=
MLPACK_LDFLAGS :=
SQLITE_LIBS ?= -lsqlite3
SRC_DIR := src
TEST_DIR := test
DATA_DIR := data
TEST_DATA_CSV := $(DATA_DIR)/generated_test_data.csv
TEST_DATA_DB := $(DATA_DIR)/generated_test_data.sqlite3
TEST_DATA_ROWS ?= 10000
# Keep the source discovery automatic for real application files while
# excluding the template translation unit because it is a style guide, not a
# buildable part of the sample program.
APP_SOURCES := $(filter-out $(SRC_DIR)/template.cpp,$(wildcard $(SRC_DIR)/*.cpp))
LIB_SOURCES := $(filter-out $(SRC_DIR)/main.cpp,$(APP_SOURCES))
TEST_SOURCES := $(wildcard $(TEST_DIR)/*.cpp)
BUILD_DIR := build
DEBUG_OBJ_DIR := $(BUILD_DIR)/debug
RELEASE_OBJ_DIR := $(BUILD_DIR)/release
TEST_BUILD_DIR := $(BUILD_DIR)/test
TEST_DEBUG_OBJ_DIR := $(TEST_BUILD_DIR)/debug
TEST_RELEASE_OBJ_DIR := $(TEST_BUILD_DIR)/release
DEBUG_BIN := $(BUILD_DIR)/app-debug
RELEASE_BIN := $(BUILD_DIR)/app-release
TEST_DEBUG_BIN := $(TEST_BUILD_DIR)/app-tests-debug
TEST_RELEASE_BIN := $(TEST_BUILD_DIR)/app-tests-release
DEBUG_OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(DEBUG_OBJ_DIR)/%.o,$(APP_SOURCES))
RELEASE_OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(RELEASE_OBJ_DIR)/%.o,$(APP_SOURCES))
TEST_DEBUG_TEST_OBJ := $(patsubst $(TEST_DIR)/%.cpp,$(TEST_DEBUG_OBJ_DIR)/%.o,$(TEST_SOURCES))
TEST_RELEASE_TEST_OBJ := $(patsubst $(TEST_DIR)/%.cpp,$(TEST_RELEASE_OBJ_DIR)/%.o,$(TEST_SOURCES))
TEST_DEBUG_LIB_OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(TEST_DEBUG_OBJ_DIR)/src_%.o,$(LIB_SOURCES))
TEST_RELEASE_LIB_OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(TEST_RELEASE_OBJ_DIR)/src_%.o,$(LIB_SOURCES))
TEST_DEBUG_OBJ := $(TEST_DEBUG_TEST_OBJ) $(TEST_DEBUG_LIB_OBJ)
TEST_RELEASE_OBJ := $(TEST_RELEASE_TEST_OBJ) $(TEST_RELEASE_LIB_OBJ)
DOXYGEN := doxygen
DOXYFILE := Doxyfile
DOC_DIR := doc
PKG_CONFIG_CPPUNIT_PATH := /opt/homebrew/lib/pkgconfig
CPPUNIT_CFLAGS ?=
CPPUNIT_LIBS ?=

ifeq ($(USE_TORCH),1)
TORCH_CXXFLAGS := $(TORCH_INC)
TORCH_LDFLAGS := $(TORCH_LIB)
endif

ifeq ($(USE_MLPACK),1)
MLPACK_CXXFLAGS := $(MLPACK_INC)
MLPACK_LDFLAGS := $(MLPACK_LIB)
endif

ifneq ($(strip $(CPPUNIT_CFLAGS)$(CPPUNIT_LIBS)),)
ifeq ($(strip $(CPPUNIT_CFLAGS)),)
CPPUNIT_MISSING := 1
CPPUNIT_SOURCE := environment-incomplete
else ifeq ($(strip $(CPPUNIT_LIBS)),)
CPPUNIT_MISSING := 1
CPPUNIT_SOURCE := environment-incomplete
else
CPPUNIT_SOURCE := environment
endif
else ifeq ($(shell PKG_CONFIG_PATH="$(PKG_CONFIG_CPPUNIT_PATH):$$PKG_CONFIG_PATH" pkg-config --exists cppunit >/dev/null 2>&1 && echo yes),yes)
CPPUNIT_CFLAGS := $(shell PKG_CONFIG_PATH="$(PKG_CONFIG_CPPUNIT_PATH):$$PKG_CONFIG_PATH" pkg-config --cflags cppunit)
CPPUNIT_LIBS := $(shell PKG_CONFIG_PATH="$(PKG_CONFIG_CPPUNIT_PATH):$$PKG_CONFIG_PATH" pkg-config --libs cppunit)
CPPUNIT_SOURCE := pkg-config
else ifeq ($(shell command -v cppunit-config >/dev/null 2>&1 && echo yes),yes)
CPPUNIT_CFLAGS := $(shell cppunit-config --cflags)
CPPUNIT_LIBS := $(shell cppunit-config --libs)
CPPUNIT_SOURCE := cppunit-config
else ifneq ($(wildcard /opt/homebrew/opt/cppunit/include/cppunit),)
CPPUNIT_CFLAGS := -I/opt/homebrew/opt/cppunit/include
CPPUNIT_LIBS := -L/opt/homebrew/opt/cppunit/lib -lcppunit
CPPUNIT_SOURCE := homebrew
else
CPPUNIT_MISSING := 1
CPPUNIT_SOURCE := missing
endif

.PHONY: codex dox fixit starter testit help all debug release test test-debug \
	test-release test-run-debug test-run-release test-data run-test-data \
	check-cppunit check-torch docs doxygen clean clean-doc

# Default to building both variants because the repository-level instruction
# explicitly requests a debug and a release configuration.
all: debug release

# Keep the help text hand-written so it stays readable in the Makefile and so
# review does not depend on parsing comments or shell helpers to understand the
# advertised interface. The target groups the commands by common workflow to
# make the repository entry points obvious for a quick human scan.
help:
	@printf '%s\n' \
		'Project targets:' \
		'  all              Build both debug and release binaries.' \
		'  debug            Build the debug application binary.' \
		'  release          Build the release application binary.' \
		'  test             Build and run the debug test suite.' \
		'  test-debug       Build the debug test binary.' \
		'  test-release     Build the release test binary.' \
		'  test-run-debug   Build and run the debug test binary.' \
		'  test-run-release Build and run the release test binary.' \
		'  test-data        Generate matching CSV and SQLite fixtures in data/.' \
		'  run-test-data    Build the debug app, generate fixtures, then load both sources.' \
		'  docs             Generate Doxygen output in doc/.' \
		'  doxygen          Same as docs.' \
		'  clean            Remove build/ and doc/.' \
		'  clean-doc        Remove doc/ only.' \
		'  codex            Run the repository Codex helper command.' \
		'  dox              Run the documentation helper command.' \
		'  fixit            Run the repository fix helper command.' \
		'  starter          Run the starter helper command.' \
		'  testit           Run the repository test helper command.' \
		'' \
		'Key variables:' \
		'  USE_TORCH=1      Enable libtorch include and link flags.' \
		'  USE_MLPACK=1     Enable mlpack and Armadillo include/link flags.' \
		'  TORCH_DIR=PATH   Override the libtorch installation root.' \
		'  MLPACK_DIR=PATH  Override the vendored mlpack include root.' \
		'  TEST_DATA_ROWS=N Number of generated fixture rows.' \
		'  CPPUNIT_CFLAGS   Override detected CppUnit compiler flags.' \
		'  CPPUNIT_LIBS     Override detected CppUnit linker flags.'

debug: check-torch check-mlpack $(DEBUG_BIN)

release: check-torch check-mlpack $(RELEASE_BIN)

test: test-run-debug

test-debug: check-torch check-mlpack check-cppunit $(TEST_DEBUG_BIN)

test-release: check-torch check-mlpack check-cppunit $(TEST_RELEASE_BIN)

test-run-debug: check-torch check-mlpack check-cppunit $(TEST_DEBUG_BIN)
	$(TEST_DEBUG_BIN)

test-run-release: check-torch check-mlpack check-cppunit $(TEST_RELEASE_BIN)
	$(TEST_RELEASE_BIN)

test-data: debug
	mkdir -p $(DATA_DIR)
	$(DEBUG_BIN) --generate-test-data --size "$(TEST_DATA_ROWS)"

run-test-data: debug test-data
	bin/load-test-data.sh $(DEBUG_BIN)

# Create the build output directory on demand so fresh clones can build
# without any manual setup step.
$(BUILD_DIR) $(DEBUG_OBJ_DIR) $(RELEASE_OBJ_DIR) $(TEST_BUILD_DIR) $(TEST_DEBUG_OBJ_DIR) $(TEST_RELEASE_OBJ_DIR):
	mkdir -p $@

# Compile debug objects separately from linking so unchanged translation units
# can be reused across repeated debug builds. The pattern rule keeps the source
# to object mapping explicit without duplicating a rule for each file.
$(DEBUG_OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(DEBUG_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPP_DEFINES) $(TORCH_CXXFLAGS) $(MLPACK_CXXFLAGS) -O0 -g -c $< -o $@

# Compile release objects separately for the same incremental-build benefit
# while also keeping release-only flags isolated from the debug build output.
$(RELEASE_OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(RELEASE_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPP_DEFINES) $(TORCH_CXXFLAGS) $(MLPACK_CXXFLAGS) -O2 -DNDEBUG -c $< -o $@

$(TEST_DEBUG_OBJ_DIR)/%.o: $(TEST_DIR)/%.cpp | $(TEST_DEBUG_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPP_DEFINES) $(TORCH_CXXFLAGS) $(MLPACK_CXXFLAGS) $(CPPUNIT_CFLAGS) -I$(SRC_DIR) -O0 -g -c $< -o $@

$(TEST_RELEASE_OBJ_DIR)/%.o: $(TEST_DIR)/%.cpp | $(TEST_RELEASE_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPP_DEFINES) $(TORCH_CXXFLAGS) $(MLPACK_CXXFLAGS) $(CPPUNIT_CFLAGS) -I$(SRC_DIR) -O2 -DNDEBUG -c $< -o $@

$(TEST_DEBUG_OBJ_DIR)/src_%.o: $(SRC_DIR)/%.cpp | $(TEST_DEBUG_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPP_DEFINES) $(TORCH_CXXFLAGS) $(MLPACK_CXXFLAGS) -O0 -g -c $< -o $@

$(TEST_RELEASE_OBJ_DIR)/src_%.o: $(SRC_DIR)/%.cpp | $(TEST_RELEASE_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPP_DEFINES) $(TORCH_CXXFLAGS) $(MLPACK_CXXFLAGS) -O2 -DNDEBUG -c $< -o $@

# Link the debug binary from the already-built object files so source changes
# only force recompilation of the affected translation units before the final
# link step runs.
$(DEBUG_BIN): $(DEBUG_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O0 -g $(DEBUG_OBJ) $(TORCH_LDFLAGS) $(MLPACK_LDFLAGS) $(SQLITE_LIBS) -o $(DEBUG_BIN)

# Link the release binary from the release object files to preserve the same
# dependency shape as the debug build while keeping optimization flags aligned
# with the objects that were compiled for this configuration.
$(RELEASE_BIN): $(RELEASE_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O2 -DNDEBUG $(RELEASE_OBJ) $(TORCH_LDFLAGS) $(MLPACK_LDFLAGS) $(SQLITE_LIBS) -o $(RELEASE_BIN)

$(TEST_DEBUG_BIN): $(TEST_DEBUG_OBJ) | $(TEST_BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O0 -g $(TEST_DEBUG_OBJ) $(CPPUNIT_LIBS) $(TORCH_LDFLAGS) $(MLPACK_LDFLAGS) $(SQLITE_LIBS) -o $(TEST_DEBUG_BIN)

$(TEST_RELEASE_BIN): $(TEST_RELEASE_OBJ) | $(TEST_BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O2 -DNDEBUG $(TEST_RELEASE_OBJ) $(CPPUNIT_LIBS) $(TORCH_LDFLAGS) $(MLPACK_LDFLAGS) $(SQLITE_LIBS) -o $(TEST_RELEASE_BIN)

check-torch:
ifeq ($(USE_TORCH),1)
	@if [ ! -d "$(TORCH_DIR)/include/torch/csrc/api/include" ]; then \
		echo "Error: libtorch include path not found under TORCH_DIR='$(TORCH_DIR)'." >&2; \
		echo "Expected: $(TORCH_DIR)/include/torch/csrc/api/include" >&2; \
		echo "Example override: make debug USE_TORCH=1 TORCH_DIR=/path/to/libtorch" >&2; \
		exit 1; \
	fi
	@if [ ! -d "$(TORCH_DIR)/lib" ]; then \
		echo "Error: libtorch library path not found under TORCH_DIR='$(TORCH_DIR)'." >&2; \
		echo "Expected: $(TORCH_DIR)/lib" >&2; \
		echo "Example override: make debug USE_TORCH=1 TORCH_DIR=/path/to/libtorch" >&2; \
		exit 1; \
	fi
endif

check-mlpack:
ifeq ($(USE_MLPACK),1)
	@if [ ! -d "$(MLPACK_DIR)/mlpack" ]; then \
		echo "Error: mlpack headers not found under MLPACK_DIR='$(MLPACK_DIR)'." >&2; \
		echo "Expected: $(MLPACK_DIR)/mlpack" >&2; \
		echo "Example override: make debug USE_MLPACK=1 MLPACK_DIR=/path/to/mlpack/src" >&2; \
		exit 1; \
	fi
	@if [ ! -f "/opt/homebrew/include/armadillo" ]; then \
		echo "Error: Armadillo headers not found at /opt/homebrew/include/armadillo." >&2; \
		echo "Install Armadillo or adjust MLPACK include/link flags in the Makefile." >&2; \
		exit 1; \
	fi
	@if [ ! -f "/opt/homebrew/lib/libarmadillo.dylib" ]; then \
		echo "Error: Armadillo library not found at /opt/homebrew/lib/libarmadillo.dylib." >&2; \
		echo "Install Armadillo or adjust MLPACK include/link flags in the Makefile." >&2; \
		exit 1; \
	fi
endif

check-cppunit:
ifeq ($(CPPUNIT_MISSING),1)
	@echo "Error: CppUnit not found." >&2
	@echo "If you set environment overrides, both CPPUNIT_CFLAGS and CPPUNIT_LIBS must be non-empty." >&2
	@echo "Tried CPPUNIT_CFLAGS/CPPUNIT_LIBS, pkg-config cppunit, cppunit-config, and /opt/homebrew/opt/cppunit." >&2
	@echo "Install CppUnit (for example: brew install cppunit) or set CPPUNIT_CFLAGS and CPPUNIT_LIBS." >&2
	@false
else
	@echo "Using CppUnit flags from $(CPPUNIT_SOURCE)." >&2
endif

# Keep a short alias for the actual Doxygen target so the documentation build
# reads naturally at the command line while still exposing the underlying tool
# name explicitly for users who expect `make doxygen`.
docs: doxygen

doxygen: $(DOXYFILE)
	@if ! command -v $(DOXYGEN) >/dev/null 2>&1; then \
		echo "Error: doxygen is not installed or not on PATH." >&2; \
		exit 1; \
	fi
	rm -rf $(DOC_DIR)
	$(DOXYGEN) $(DOXYFILE)

clean-doc:
	rm -rf $(DOC_DIR)

clean:
	rm -rf $(BUILD_DIR) $(DOC_DIR)
