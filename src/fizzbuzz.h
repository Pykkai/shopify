// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

#ifndef _FIZZBUZZ_H_
#define _FIZZBUZZ_H_

#include <string>
#include <vector>

/******************************************************************************
 ** @brief - hold reusable FizzBuzz generation helpers.
 */
namespace fizzbuzz
{
/****************************************************************************
 ** @brief - build the FizzBuzz answer list from 1 through n.
 ** @param n - inclusive upper bound for the sequence.
 ** @return - array-form FizzBuzz answer.
 */
std::vector<std::string> generate(int n);
}  // namespace fizzbuzz

#endif  // _FIZZBUZZ_H_

// EOF ************************************************************************
