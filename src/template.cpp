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

/******************************************************************************
 ** @brief - hold file-local helper functions for the template.
 */
// - the @doxygen tag indicates where doxygen documentation should be provided

// - utility functions (helpers) go at the top of the file before
//   class methods
// - they may be put in an anonymous namespace
namespace
{
  /****************************************************************************
   ** @brief - demonstrate helper documentation style in implementation files.
   ** @param s - caller supplied string input.
   ** @return - sample helper result.
   */
  string helper(string &s) {
    // - body of helper
    return string("foo");
  }
}

// - class related stuff follows

// - note that I prefer using the full scope in defintions rather than wrapping
//   everything in a namespace MyNamespace {...}
// - the order is ctors, dtors, followed by methods in alphabetical order
//   (easiest to find)

/******************************************************************************
 ** @brief - construct the sample object from a string.
 ** - mark constructors with CTOR
 ** - source string initializes all member state from the header contract.
 ** - note the reference definitions, the ampersand should be associated with
 **   the variable name, NOT the type
 */
CTOR MyNamespace::ClassName::ClassName(string &foo): my_private_member_variable(foo),
				    my_protected_member_variable(foo),
				    my_public_member_variable(foo)
{
  return;
}

/******************************************************************************
 ** @brief - destroy the sample object.
 ** - destructor marked with DTOR
 */
DTOR MyNamespace::ClassName::~ClassName() {
  return;
}

/******************************************************************************
 ** @brief - return the provided string unchanged.
 ** - implementation follows the API contract documented in the header.
 */
string MyNamespace::ClassName::my_public_method(string &s) {
  return s;
}

/******************************************************************************
 ** @brief - demonstrate documentation for a static class method.
 ** - class static method marked with STATIC
 ** - static class methods are preferred over static file methods (helpers)
 **   including anonymous namespaces)
 ** - the class should be the one whose type is modified by the method
 **   or most accessed my the method
 ** - this prevents duplication and cut & paste coding
 */
STATIC void MyNamespace::ClassName::my_static_method() {
  return;
}

/******************************************************************************
 ** @brief - return read-only access to private string state.
 ** @return - private member string reference.
 ** - method template
 ** - virtual methods when first defined are marked with VIRTUAL
 ** - when overridden in a derived class marked with OVERRIDE
 */
VIRTUAL const string &MyNamespace::ClassName::my_virtual_method() const {
  return my_private_member_variable;
}

// - mark the end of file to guard against accidental truncation
// EOF ************************************************************************
