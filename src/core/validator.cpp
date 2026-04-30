#include "validator.hpp"
#include <iostream>
#include <mutex>

Validator &Validator::get_instance() {
  static Validator instance;
  return instance;
}

void Validator::lockbuffer(void *ptr) {
  std::lock_guard guard(tablemutex);
  activelocks.insert(ptr);
  std::cout << "[UMS Lock Table] added    " << ptr << std::endl;
}

void Validator::unlockbuffer(void *ptr) {
  std::lock_guard guard(tablemutex);
  activelocks.erase(ptr);
  std::cout << "[UMS Lock Table] released " << ptr << std::endl;
}

void Validator::checkaccess(void *ptr, const char *context) {
  if (islocked(ptr)) {
    std::cout << "[UMA Race Detected]" << std::endl;
    std::cout << "context: " << context << std::endl;
    std::cout << "cpu attempted to access " << ptr << " while locked by gpu"
              << std::endl;
    // TODO:abort
    __builtin_trap();
    // todone
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
