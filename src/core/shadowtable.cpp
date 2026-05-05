#include "shadowtable.hpp"
#include "../utils/logger.hpp"

void Shadowtable::regAlloc(void *ptr, size_t size) {
  std::lock_guard guard(tablemutex);
  memMap[ptr] = {size, memState::cpuowned};
}

void Shadowtable::freeAlloc(void *ptr) {
  std::lock_guard guard(tablemutex);
  memMap.erase(ptr);
}

void Shadowtable::lockbuffer(std::vector<void *> &buffer) {
  std::lock_guard guard(tablemutex);
  for (void *ptr : buffer) {
    if (memMap.find(ptr) != memMap.end()) {
      memMap[ptr].state = memState::gpulocked;
    }
  }
}

void Shadowtable::unlockbuffer(std::vector<void *> &buffer) {
  std::lock_guard guard(tablemutex);
  for (void *ptr : buffer) {
    if (memMap.find(ptr) != memMap.end()) {
      memMap[ptr].state = memState::cpuowned;
    }
  }
}

bool Shadowtable::islocked(void *ptr) {
  std::lock_guard guard(tablemutex);
  auto it = memMap.find(ptr);
  if (it != memMap.end()) {
    return it->second.state == memState::gpulocked;
  }
  return false;
}
