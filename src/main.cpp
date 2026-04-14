// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

/******************************************************************************
 ** @file main.cpp
 ** @brief - implement the FizzBuzz command-line application entry point.
 */

// @codex 2026-04-14 11:14
// - replace the hello world sample with the README FizzBuzz application
// - validate a single positive integer argument
// - print the result in array form
// @revision
// - 2026-04-14 11:14 Implemented a strict FizzBuzz CLI with usage and
//   error handling for invalid input.
// @review 2026-04-14 11:14

#include <charconv>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <limits>
#include <string>
#include <string_view>
#include <vector>

#include "fizzbuzz.h"

/******************************************************************************
 ** @brief - hold file-local constants and helpers for the FizzBuzz CLI.
 */
namespace
{
/****************************************************************************
 ** @brief - define the minimum accepted CLI input.
 */
constexpr int kMinimumInput = 1;

/****************************************************************************
 ** @brief - define the maximum accepted CLI input.
 */
constexpr int kMaximumInput = 10000;

/****************************************************************************
 ** @brief - print CLI usage for invalid invocations.
 ** @param program_name - executable path from argv[0].
 */
void print_usage(const char *program_name)
{
    /************************************************************************
     ** @brief - store the executable basename for usage output.
     */
    const std::string executable =
        std::filesystem::path(program_name).filename().string();

    std::cerr << "Usage: " << executable << " <positive integer 1-10000>"
              << std::endl;
}

/****************************************************************************
 ** @brief - parse and validate the single integer CLI argument.
 ** @param argument - raw CLI argument text.
 ** @param value - parsed integer result on success.
 ** @return - true when the argument is a valid bounded integer.
 ** - rejects empty input
 ** - rejects non-digit characters
 ** - rejects values outside the supported range
 */
bool parse_input(const char *argument, int &value)
{
    /************************************************************************
     ** @brief - hold the raw argument text as a lightweight string view.
     */
    const std::string_view input(argument);

    if (input.empty()) {
        return false;
    }

    for (const char ch : input) {
        if (ch < '0' || ch > '9') {
            return false;
        }
    }

    /************************************************************************
     ** @brief - store the parsed integer before range validation.
     */
    int parsed_value = 0;

    /************************************************************************
     ** @brief - mark the first character in the parse range.
     */
    const auto *begin = input.data();

    /************************************************************************
     ** @brief - mark one past the final character in the parse range.
     */
    const auto *end = begin + input.size();

    /************************************************************************
     ** @brief - capture the low-level parse result from `std::from_chars`.
     */
    const std::from_chars_result result =
        std::from_chars(begin, end, parsed_value);

    /************************************************************************
     ** @brief - mark where numeric parsing stopped.
     */
    const char *parsed_end = result.ptr;

    /************************************************************************
     ** @brief - store the parse status code.
     */
    const std::errc error_code = result.ec;

    if (error_code != std::errc() || parsed_end != end) {
        return false;
    }

    if (parsed_value < kMinimumInput || parsed_value > kMaximumInput) {
        return false;
    }

    value = parsed_value;
    return true;
}

/****************************************************************************
 ** @brief - print the answer in JSON-like array form.
 ** @param answer - FizzBuzz values to emit.
 */
void print_answer(const std::vector<std::string> &answer)
{
    std::cout << "[";

    /************************************************************************
     ** @brief - iterate across each answer element for output formatting.
     */
    for (std::size_t index = 0; index < answer.size(); ++index) {
        if (index != 0) {
            std::cout << ",";
        }

        std::cout << "\"" << answer[index] << "\"";
    }

    std::cout << "]" << std::endl;
}
}  // namespace

/****************************************************************************
 ** @brief - run the FizzBuzz command-line application.
 ** @param argc - number of CLI arguments.
 ** @param argv - CLI argument vector.
 ** @return - `EXIT_SUCCESS` on success, otherwise `EXIT_FAILURE`.
 */
int main(const int argc, const char *argv[])
{
    if (argc != 2) {
        std::cerr << "Error: expected exactly one argument." << std::endl;
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    /************************************************************************
     ** @brief - store the validated upper bound for the FizzBuzz run.
     */
    int n = 0;

    if (!parse_input(argv[1], n)) {
        std::cerr << "Error: argument must be a positive integer between 1 "
                  << "and 10000." << std::endl;
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    print_answer(fizzbuzz::generate(n));
    return EXIT_SUCCESS;
}
