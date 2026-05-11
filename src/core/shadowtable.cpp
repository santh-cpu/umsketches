#include "shadowtable.hpp"
#include "../utils/logger.hpp"
#include <mutex>

Shadowtable &Shadowtable::get() {
  static Shadowtable instance;
  return instance;
}

void Shadowtable::regAlloc(void *ptr, size_t size) {
  std::lock_guard guard(tablemutex);
  memMap[ptr] = {size, 0};
}

void Shadowtable::freeAlloc(void *ptr) {
  std::lock_guard guard(tablemutex);
  memMap.erase(ptr);
}

void Shadowtable::lockbuffer(std::vector<void *> &buffer) {
  std::lock_guard guard(tablemutex);
  for (void *ptr : buffer) {
    auto it = memMap.find(ptr);
    if (it != memMap.end()) {
      ++(it->second.lockcOunt);
    }
  }
}

void Shadowtable::unlockbuffer(std::vector<void *> &buffer) {
  std::lock_guard guard(tablemutex);
  for (void *ptr : buffer) {
    auto it = memMap.find(ptr);
    if (it != memMap.end() && it->second.lockcOunt > 0) {
      --(it->second.lockcOunt);
    }
  }
}

bool Shadowtable::islocked(void *ptr) {
  std::lock_guard guard(tablemutex);
  auto it = memMap.find(ptr);
  if (it != memMap.end()) {
    return it->second.lockcOunt > 0;
  }
  return false;
}

bool Shadowtable::istracked(void *ptr) {
  std::lock_guard guard(tablemutex);
  return memMap.find(ptr) != memMap.end();
}
