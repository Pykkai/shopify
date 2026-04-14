// @codex 2026-04-14 10:19
// - create a helloworld sample app here
// @revision
// - 2026-04-14 10:19 Added a minimal sample application that prints
//   "Hello, world!" and exits successfully.
// @review 2026-04-14 10:19

#include <cstdlib>
#include <iostream>

int main()
{
    // Keep the sample application intentionally small and direct so the file
    // serves as a clear starting point for future expansion without adding
    // extra helpers or framework code.
    std::cout << "Hello, world!" << std::endl;

    // Return an explicit success code so shell scripts and test runners can
    // tell that the program completed normally.
    return EXIT_SUCCESS;
}
