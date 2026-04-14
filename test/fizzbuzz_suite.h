// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

#ifndef _FIZZBUZZ_SUITE_H_
#define _FIZZBUZZ_SUITE_H_

#include <cppunit/TestFixture.h>
#include <cppunit/extensions/HelperMacros.h>

/******************************************************************************
 ** @brief - define CppUnit coverage for reusable FizzBuzz generation.
 */
class FizzBuzzSuite : public CppUnit::TestFixture
{
  CPPUNIT_TEST_SUITE(FizzBuzzSuite);
  CPPUNIT_TEST(testGenerateReturnsEmptySequenceForZero);
  CPPUNIT_TEST(testGenerateReturnsExpectedSequenceUpToFifteen);
  CPPUNIT_TEST_SUITE_END();

public:
  void testGenerateReturnsEmptySequenceForZero();
  void testGenerateReturnsExpectedSequenceUpToFifteen();
};

#endif  // _FIZZBUZZ_SUITE_H_
