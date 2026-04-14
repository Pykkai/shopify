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

namespace
{
constexpr int kMinimumInput = 1;
constexpr int kMaximumInput = 10000;

void print_usage(const char *program_name)
{
    const std::string executable =
        std::filesystem::path(program_name).filename().string();

    std::cerr << "Usage: " << executable << " <positive integer 1-10000>"
              << std::endl;
}

bool parse_input(const char *argument, int &value)
{
    const std::string_view input(argument);

    if (input.empty()) {
        return false;
    }

    for (const char ch : input) {
        if (ch < '0' || ch > '9') {
            return false;
        }
    }

    int parsed_value = 0;
    const auto *begin = input.data();
    const auto *end = begin + input.size();
    const auto [ptr, ec] = std::from_chars(begin, end, parsed_value);

    if (ec != std::errc() || ptr != end) {
        return false;
    }

    if (parsed_value < kMinimumInput || parsed_value > kMaximumInput) {
        return false;
    }

    value = parsed_value;
    return true;
}

std::vector<std::string> fizzbuzz(const int n)
{
    std::vector<std::string> answer;
    answer.reserve(static_cast<std::size_t>(n));

    for (int index = 1; index <= n; ++index) {
        if (index % 15 == 0) {
            answer.emplace_back("FizzBuzz");
            continue;
        }

        if (index % 3 == 0) {
            answer.emplace_back("Fizz");
            continue;
        }

        if (index % 5 == 0) {
            answer.emplace_back("Buzz");
            continue;
        }

        answer.emplace_back(std::to_string(index));
    }

    return answer;
}

void print_answer(const std::vector<std::string> &answer)
{
    std::cout << "[";

    for (std::size_t index = 0; index < answer.size(); ++index) {
        if (index != 0) {
            std::cout << ",";
        }

        std::cout << "\"" << answer[index] << "\"";
    }

    std::cout << "]" << std::endl;
}
}  // namespace

int main(const int argc, const char *argv[])
{
    if (argc != 2) {
        std::cerr << "Error: expected exactly one argument." << std::endl;
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    int n = 0;

    if (!parse_input(argv[1], n)) {
        std::cerr << "Error: argument must be a positive integer between 1 "
                  << "and 10000." << std::endl;
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    print_answer(fizzbuzz(n));
    return EXIT_SUCCESS;
}
