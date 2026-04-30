#pragma once

#include <unordered_set>
class Validator {
public:
  static Validator &get_instance();
  Validator(const Validator &) = delete;
  void operator=(const Validator &) = delete;

  void lockbuffer(void *ptr);
  void unlockbuffer(void *ptr);
  void checkaccess(void *ptr, const char *context);
  bool islocked(void *ptr);
  bool gpubusy();

private:
  Validator() = default;

  std::unordered_set<void *> activelocks;
  std::mutex tablemutex;
};
