#pragma once
#include <vector>

class Validator {
public:
  static Validator &get();
  Validator(const Validator &) = delete;
  void operator=(const Validator &) = delete;

  void lockbuffer(std::vector<void *> &buffer);
  void unlockbuffer(std::vector<void *> &buffer);
  void checkaccess(void *ptr, const char *context);
  bool islocked(void *ptr);

private:
  Validator() = default;
};
