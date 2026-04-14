// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

#include "fizzbuzz_suite.h"

#include <string>
#include <vector>

#include <cppunit/extensions/HelperMacros.h>

#include "fizzbuzz.h"

CPPUNIT_TEST_SUITE_REGISTRATION(FizzBuzzSuite);

void FizzBuzzSuite::testGenerateReturnsEmptySequenceForZero()
{
    const std::vector<std::string> answer = fizzbuzz::generate(0);

    CPPUNIT_ASSERT(answer.empty());
}

void FizzBuzzSuite::testGenerateReturnsExpectedSequenceUpToFifteen()
{
    const std::vector<std::string> expected = {
        "1",    "2",    "Fizz", "4",    "Buzz",
        "Fizz", "7",    "8",    "Fizz", "Buzz",
        "11",   "Fizz", "13",   "14",   "FizzBuzz"};

    const std::vector<std::string> answer = fizzbuzz::generate(15);

    CPPUNIT_ASSERT_EQUAL(expected.size(), answer.size());

    for (std::size_t index = 0; index < expected.size(); ++index) {
        CPPUNIT_ASSERT_EQUAL(expected[index], answer[index]);
    }
}
