// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

#ifndef _CLI_HELPERS_SUITE_H_
#define _CLI_HELPERS_SUITE_H_

#include <cppunit/TestFixture.h>
#include <cppunit/extensions/HelperMacros.h>

/******************************************************************************
 ** @brief - define CppUnit coverage for file-local CLI helper functions.
 */
class CliHelpersSuite : public CppUnit::TestFixture
{
  CPPUNIT_TEST_SUITE(CliHelpersSuite);
  CPPUNIT_TEST(testParseInputAcceptsBoundedInteger);
  CPPUNIT_TEST(testParseInputRejectsEmptyAndNonDigitInput);
  CPPUNIT_TEST(testParseInputRejectsValuesOutsideSupportedRange);
  CPPUNIT_TEST(testPrintAnswerFormatsJsonLikeArray);
  CPPUNIT_TEST_SUITE_END();

public:
  void testParseInputAcceptsBoundedInteger();
  void testParseInputRejectsEmptyAndNonDigitInput();
  void testParseInputRejectsValuesOutsideSupportedRange();
  void testPrintAnswerFormatsJsonLikeArray();
};

#endif  // _CLI_HELPERS_SUITE_H_
