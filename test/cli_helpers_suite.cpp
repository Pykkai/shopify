// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

#include "cli_helpers_suite.h"

#include <ios>
#include <ostream>
#include <sstream>
#include <string>
#include <vector>

#include <cppunit/extensions/HelperMacros.h>

#define main fizzbuzz_app_main
#include "../src/main.cpp"
#undef main

CPPUNIT_TEST_SUITE_REGISTRATION(CliHelpersSuite);

void CliHelpersSuite::testParseInputAcceptsBoundedInteger()
{
    int value = 0;

    const bool was_parsed = parse_input("42", value);

    CPPUNIT_ASSERT(was_parsed);
    CPPUNIT_ASSERT_EQUAL(42, value);
}

void CliHelpersSuite::testParseInputRejectsEmptyAndNonDigitInput()
{
    int empty_value = 17;
    int nondigit_value = 23;

    CPPUNIT_ASSERT(!parse_input("", empty_value));
    CPPUNIT_ASSERT_EQUAL(17, empty_value);
    CPPUNIT_ASSERT(!parse_input("12a", nondigit_value));
    CPPUNIT_ASSERT_EQUAL(23, nondigit_value);
}

void CliHelpersSuite::testParseInputRejectsValuesOutsideSupportedRange()
{
    int zero_value = 5;
    int large_value = 9;

    CPPUNIT_ASSERT(!parse_input("0", zero_value));
    CPPUNIT_ASSERT_EQUAL(5, zero_value);
    CPPUNIT_ASSERT(!parse_input("10001", large_value));
    CPPUNIT_ASSERT_EQUAL(9, large_value);
}

void CliHelpersSuite::testPrintAnswerFormatsJsonLikeArray()
{
    const std::vector<std::string> answer = {"1", "Fizz", "Buzz"};
    std::ostringstream output;
    std::streambuf *original_buffer = std::cout.rdbuf(output.rdbuf());

    print_answer(answer);

    std::cout.rdbuf(original_buffer);

    CPPUNIT_ASSERT_EQUAL(std::string("[\"1\",\"Fizz\",\"Buzz\"]\n"),
                         output.str());
}
