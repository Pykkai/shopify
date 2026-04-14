// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

/******************************************************************************
 ** @file fizzbuzz.cpp
 ** @brief - implement reusable FizzBuzz generation helpers.
 */

#include "fizzbuzz.h"

#include <string>
#include <vector>

/******************************************************************************
 ** @brief - hold file-local constants for FizzBuzz generation.
 */
namespace
{
/****************************************************************************
 ** @brief - define the divisor used for Fizz checks.
 */
constexpr int kFizzDivisor = 3;

/****************************************************************************
 ** @brief - define the divisor used for Buzz checks.
 */
constexpr int kBuzzDivisor = 5;
}  // namespace

/******************************************************************************
 ** @brief - build the FizzBuzz answer list from 1 through n.
 ** @param n - inclusive upper bound for the sequence.
 ** @return - array-form FizzBuzz answer.
 */
std::vector<std::string> fizzbuzz::generate(const int n)
{
    std::vector<std::string> answer;
    answer.reserve(static_cast<std::size_t>(n));

    for (int index = 1; index <= n; ++index) {
        if (index % (kFizzDivisor * kBuzzDivisor) == 0) {
            answer.emplace_back("FizzBuzz");
            continue;
        }

        if (index % kFizzDivisor == 0) {
            answer.emplace_back("Fizz");
            continue;
        }

        if (index % kBuzzDivisor == 0) {
            answer.emplace_back("Buzz");
            continue;
        }

        answer.emplace_back(std::to_string(index));
    }

    return answer;
}

// EOF ************************************************************************
