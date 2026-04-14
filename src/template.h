// Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai

// - idempotency
#ifndef _TEMPLATE_H_
#define _TEMPLATE_H_

// - the @doxygen tag indicates where doxygen documentation should be provided

// - comments should be point form, they are faster to write and faster
//   and easier to read; strip verbiage!

// - system includes go here in alpahbetical order
#include <string>

// - project includes go here in alphabetical order
// - usually have a types.h as the project's type dictionary
#include "types.h"

/******************************************************************************
 ** @brief - hold the project's public types.
 */
// - MyNamespace is the project's namespace
namespace MyNamespace
{
  /**************************************************************************
   ** @brief - demonstrate class declaration documentation style.
   ** - use this layout for real classes in header files
   */
  class ClassName
  {
    // - every private, protected and public section follows the pattern:
    // - member variables in alphabetical order
    // - constructors section
    // - destructors section
    // - methods in alphabetical order
  private:
    /************************************************************************
     ** @brief - store private string state for the instance.
     */
    string my_private_member_variable;
  protected:
    /************************************************************************
     ** @brief - store protected string state for derived classes.
     */
    string my_protected_member_variable;
  public:
    /************************************************************************
     ** @brief - expose public string state for template illustration.
     */
    string my_public_member_variable;

    /************************************************************************
     ** @brief - construct the sample object from a string.
     ** @param foo - source string for member initialization.
     */
    ClassName(string &foo);

    /************************************************************************
     ** @brief - destroy the sample object.
     */
    ~ClassName();

    /************************************************************************
     ** @brief - return a transformed public string value.
     ** @param s - caller supplied string input.
     ** @return - processed string result.
     */
    string my_public_method(string &s);

    /************************************************************************
     ** @brief - demonstrate documentation for a static class method.
     */
    static void my_static_method();

    /************************************************************************
     ** @brief - expose read-only virtual string access.
     ** @return - reference to internal string state.
     */
    virtual const string &my_virtual_method() const;
  };
}

#endif

// - mark the end of file to guard against accidental truncation
// EOF ************************************************************************
