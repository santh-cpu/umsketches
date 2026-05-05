#pragma once

#include <unordered_set>
class Validator {
public:
  static Validator &get_instance();
  Validator(const Validator &) = delete;
  void operator=(const Validator &) = delete;

  void lockbuffer(std::vector<void *> &buffer);
  void unlockbuffer(std::vector<void *> &buffer);
  void checkaccess(void *ptr, const char *context);
  bool islocked(void *ptr);
  bool gpubusy();

private:
  Validator() = default;

  std::unordered_set<void *> activelocks;
  std::mutex tablemutex;
};
