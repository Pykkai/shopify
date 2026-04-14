// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

#include <cstdlib>

#include <cppunit/TextTestRunner.h>
#include <cppunit/extensions/TestFactoryRegistry.h>

int main()
{
    CppUnit::TextTestRunner runner;
    runner.addTest(CppUnit::TestFactoryRegistry::getRegistry().makeTest());
    const bool was_successful = runner.run("", false);
    return was_successful ? EXIT_SUCCESS : EXIT_FAILURE;
}
