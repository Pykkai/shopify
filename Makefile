# Copyright 2026 Brad Shapcott brad@shapcott.com

# @codex 2026-04-14 10:27
# - fill in the makefile to compile the hello world app
# - create both a release and debug version
# @revision
# - 2026-04-14 10:27 Added a minimal Makefile with separate debug and
#   release builds for the sample application.
# - 2026-04-14 10:44 Refactored the build to compile configuration-specific
#   object files before linking the debug and release binaries.
# @review 2026-04-14 10:27
# @review 2026-04-14 10:44
#
# @codex 2026-04-14 10:44
# - add a rule to convert .cpp to .o separate from building the app
#   so they do not get rebuilt every time
#
# @codex 2026-04-14 12:14
# - add commands to generate doxygen documentation from the doxygen
#   comments in source and place in the doc directory
# @revision
# - 2026-04-14 12:14 Added repository-level Doxygen build targets and a
#   dedicated configuration file that emits generated docs into `doc/`.
# @review 2026-04-14 12:14

# Coding agent commands

codex:
	bin/codex

dox:
	bin/dox

fixit:
	bin/fixit

starter:
	bin/starter


# Keep the build layout explicit so the project is easy to inspect and extend
# during review. The debug and release binaries are emitted separately to avoid
# flag confusion and to make it obvious which artifact is being run.
CXX := c++
CXXFLAGS := -std=c++23 -Wall -Wextra -Wpedantic
SRC_DIR := src
TEST_DIR := test
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
DEBUG_BIN := $(BUILD_DIR)/fizzbuzz-debug
RELEASE_BIN := $(BUILD_DIR)/fizzbuzz-release
TEST_DEBUG_BIN := $(TEST_BUILD_DIR)/fizzbuzz-tests-debug
TEST_RELEASE_BIN := $(TEST_BUILD_DIR)/fizzbuzz-tests-release
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

.PHONY: all debug release test test-debug test-release test-run-debug \
	test-run-release check-cppunit docs doxygen clean clean-doc

# Default to building both variants because the repository-level instruction
# explicitly requests a debug and a release configuration.
all: debug release

debug: $(DEBUG_BIN)

release: $(RELEASE_BIN)

test: test-run-debug

test-debug: check-cppunit $(TEST_DEBUG_BIN)

test-release: check-cppunit $(TEST_RELEASE_BIN)

test-run-debug: check-cppunit $(TEST_DEBUG_BIN)
	$(TEST_DEBUG_BIN)

test-run-release: check-cppunit $(TEST_RELEASE_BIN)
	$(TEST_RELEASE_BIN)

# Create the build output directory on demand so fresh clones can build
# without any manual setup step.
$(BUILD_DIR) $(DEBUG_OBJ_DIR) $(RELEASE_OBJ_DIR) $(TEST_BUILD_DIR) $(TEST_DEBUG_OBJ_DIR) $(TEST_RELEASE_OBJ_DIR):
	mkdir -p $@

# Compile debug objects separately from linking so unchanged translation units
# can be reused across repeated debug builds. The pattern rule keeps the source
# to object mapping explicit without duplicating a rule for each file.
$(DEBUG_OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(DEBUG_OBJ_DIR)
	$(CXX) $(CXXFLAGS) -O0 -g -c $< -o $@

# Compile release objects separately for the same incremental-build benefit
# while also keeping release-only flags isolated from the debug build output.
$(RELEASE_OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(RELEASE_OBJ_DIR)
	$(CXX) $(CXXFLAGS) -O2 -DNDEBUG -c $< -o $@

$(TEST_DEBUG_OBJ_DIR)/%.o: $(TEST_DIR)/%.cpp | $(TEST_DEBUG_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPPUNIT_CFLAGS) -I$(SRC_DIR) -O0 -g -c $< -o $@

$(TEST_RELEASE_OBJ_DIR)/%.o: $(TEST_DIR)/%.cpp | $(TEST_RELEASE_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CPPUNIT_CFLAGS) -I$(SRC_DIR) -O2 -DNDEBUG -c $< -o $@

$(TEST_DEBUG_OBJ_DIR)/src_%.o: $(SRC_DIR)/%.cpp | $(TEST_DEBUG_OBJ_DIR)
	$(CXX) $(CXXFLAGS) -O0 -g -c $< -o $@

$(TEST_RELEASE_OBJ_DIR)/src_%.o: $(SRC_DIR)/%.cpp | $(TEST_RELEASE_OBJ_DIR)
	$(CXX) $(CXXFLAGS) -O2 -DNDEBUG -c $< -o $@

# Link the debug binary from the already-built object files so source changes
# only force recompilation of the affected translation units before the final
# link step runs.
$(DEBUG_BIN): $(DEBUG_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O0 -g $(DEBUG_OBJ) -o $(DEBUG_BIN)

# Link the release binary from the release object files to preserve the same
# dependency shape as the debug build while keeping optimization flags aligned
# with the objects that were compiled for this configuration.
$(RELEASE_BIN): $(RELEASE_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O2 -DNDEBUG $(RELEASE_OBJ) -o $(RELEASE_BIN)

$(TEST_DEBUG_BIN): $(TEST_DEBUG_OBJ) | $(TEST_BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O0 -g $(TEST_DEBUG_OBJ) $(CPPUNIT_LIBS) -o $(TEST_DEBUG_BIN)

$(TEST_RELEASE_BIN): $(TEST_RELEASE_OBJ) | $(TEST_BUILD_DIR)
	$(CXX) $(CXXFLAGS) -O2 -DNDEBUG $(TEST_RELEASE_OBJ) $(CPPUNIT_LIBS) -o $(TEST_RELEASE_BIN)

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
