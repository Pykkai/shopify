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

# Keep the build layout explicit so the project is easy to inspect and extend
# during review. The debug and release binaries are emitted separately to avoid
# flag confusion and to make it obvious which artifact is being run.
CXX := c++
CXXFLAGS := -std=c++23 -Wall -Wextra -Wpedantic
SRC_DIR := src
# Keep the source discovery automatic for real application files while
# excluding the template translation unit because it is a style guide, not a
# buildable part of the sample program.
SOURCES := $(filter-out $(SRC_DIR)/template.cpp,$(wildcard $(SRC_DIR)/*.cpp))
BUILD_DIR := build
DEBUG_OBJ_DIR := $(BUILD_DIR)/debug
RELEASE_OBJ_DIR := $(BUILD_DIR)/release
DEBUG_BIN := $(BUILD_DIR)/hello-debug
RELEASE_BIN := $(BUILD_DIR)/hello-release
DEBUG_OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(DEBUG_OBJ_DIR)/%.o,$(SOURCES))
RELEASE_OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(RELEASE_OBJ_DIR)/%.o,$(SOURCES))

.PHONY: all debug release clean

# Default to building both variants because the repository-level instruction
# explicitly requests a debug and a release configuration.
all: debug release

debug: $(DEBUG_BIN)

release: $(RELEASE_BIN)

# Create the build output directory on demand so fresh clones can build
# without any manual setup step.
$(BUILD_DIR) $(DEBUG_OBJ_DIR) $(RELEASE_OBJ_DIR):
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

clean:
	rm -rf $(BUILD_DIR)
