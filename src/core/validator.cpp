#include "validator.hpp"
#include "../utils/logger.hpp"
#include <mutex>

Validator &Validator::get_instance() {
  static Validator instance;
  return instance;
}

void Validator::lockbuffer(void *ptr) {
  std::lock_guard guard(tablemutex);
  activelocks.insert(ptr);
  UMSINFO("locked buffer   %p", ptr);
}

void Validator::unlockbuffer(void *ptr) {
  std::lock_guard guard(tablemutex);
  activelocks.erase(ptr);
  UMSINFO("released buffer %p", ptr);
}

void Validator::checkaccess(void *ptr, const char *context) {
  if (gpubusy()) {
    UMSFATAL(context, ptr);
  }
}

bool Validator::islocked(void *ptr) {
  std::lock_guard guard(tablemutex);
  return activelocks.find(ptr) != activelocks.end();
}

bool Validator::gpubusy() {
  std::lock_guard guard(tablemutex);
  return !activelocks.empty();
}
