#include "validator.hpp"

Validator &Validator::get_instance() {
  static Validator instance;
  return instance;
}

void Validator::lock_buffer(void *ptr) {
  std::cout << "[UMV Core] gpu locked memory address" << ptr << std::endl;
}

void Validator::unlock_buffer(void *ptr) {
  std::cout << "[UMV Core] gpu released memory address" << ptr << std::endl;
}

void Validator::check_access(void *ptr) {
  std::cout << "[UMV Core] gpu checking access to: " << ptr << std::endl;
}
