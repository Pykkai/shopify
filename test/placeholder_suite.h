// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

#ifndef _PLACEHOLDER_SUITE_H_
#define _PLACEHOLDER_SUITE_H_

#include <cppunit/TestFixture.h>
#include <cppunit/extensions/HelperMacros.h>

/******************************************************************************
 ** @brief - define a placeholder CppUnit suite for future test cases.
 */
class PlaceholderSuite : public CppUnit::TestFixture
{
  CPPUNIT_TEST_SUITE(PlaceholderSuite);
  CPPUNIT_TEST_SUITE_END();
};

#endif  // _PLACEHOLDER_SUITE_H_
