#include <cstdint>
#include <unicase.h>

#include <iostream>

#include "up.h"

uint8_t *up::upcase(const std::string &input) {
  uint8_t *buff = new uint8_t[input.size()];

  // non-trivial text processing
  size_t len;
  u8_toupper(reinterpret_cast<const uint8_t *>(input.c_str()), input.size(),
             uc_locale_language(), NULL, buff, &len);

  return buff;
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    std::cerr << "Please provide a string for us to uppercase" << std::endl;
    return 1;
  }

  std::string upcase_me(argv[1]);
  uint8_t *res = up::upcase(upcase_me);
  std::cout << "String in uppercase:" << std::endl << res << std::endl;

  delete[] res;

  return 0;
}
