// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

// - comments should be point form, they are faster to write and faster
//   and easier to read; strip verbiage!
// - comments in this file provide instructions on the placement, structure,
//   and content of comments and these instructions should be replaced
//   with the actual comments

// - system includes go here in alpahbetical order
#include <filesystem>
#include <string>

// - project includes go here in alphabetical order
#include "template.h"

// - any using namespace or namespace = goes here
namespace fs = std::filesystem;
using namespace std;

// - the @doxygen tag indicates where doxygen documentation should be provided

// - utility functions (helpers) go at the top of the file before
//   class methods
// - they may be put in an anonymous namespace
namespace
{
  /****************************************************************************
   ** - this is the comment style for helper functions
   ** @doxygen
   */
  string helper(string &s) {
    // - body of helper
    return string("foo");
  }
}

// - class related stuff follows

// - note that I prefer using the full scope in defintions rather than wrapping
//   everything in a namespace pyyka {...}
// - the order is ctors, dtors, followed by methods in alphabetical order
//   (easiest to find)

/******************************************************************************
 ** - mark constructors with CTOR
 ** @doxygen
 ** - note the reference definitions, the ampersand should be associated with
 **   the variable name, NOT the type
 */
CTOR pyyka::ClassName::ClassName(string &foo): my_private_member_variable(foo),
				    my_protected_member_variable(foo),
				    my_public_member_variable(foo)
{
  return;
}

/******************************************************************************
 ** - destructor marked with DTOR
 ** @doxygen
 */
DTOR pyyka::ClassName::~ClassName() {
  return;
}

/******************************************************************************
 ** - method template
 */
string pyyka::ClassName::my_public_method(string &s) {
  return s;
}

/******************************************************************************
 ** - class static method marked with STATIC
 ** - static class methods are preferred over static file methods (helpers)
 **   including anonymous namespaces)
 ** - the class should be the one whose type is modified by the method
 **   or most accessed my the method
 ** - this prevents duplication and cut & paste coding
 ** @doxygen
 */
STATIC void pyyka::ClassName::my_static_method() {
  return;
}

/******************************************************************************
 ** - method template
 ** - virtual methods when first defined are marked with VIRTUAL
 ** - when overridden in a derived class marked with OVERRIDE
 ** @doxygen
 */
VIRTUAL const string &pyyka::ClassName::my_virtual_method() const {
  return my_private_member_variable;
}

// - mark the end of file to guard against accidental truncation
// EOF ************************************************************************
