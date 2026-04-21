#pragma once
#include <iostream>

class Validator {
public:
  static Validator &get_instance();
  Validator(const Validator &) = delete;
  void operator=(const Validator &) = delete;

  void lock_buffer(void *ptr);
  void unlock_buffer(void *ptr);
  void check_access(void *ptr);

private:
  Validator() = default;
};
