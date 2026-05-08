#pragma once
#include <cstddef>
#include <mutex>
#include <stddef.h>
#include <unordered_map>
#include <vector>

enum class memState { cpuowned, gpulocked };

struct memDesc {
  size_t size;
  int lockcOunt;
};

class Shadowtable {
public:
  static Shadowtable &get();
  Shadowtable(const Shadowtable &) = delete;
  void operator=(const Shadowtable &) = delete;

  void regAlloc(void *ptr, size_t size);
  void freeAlloc(void *ptr);

  void lockbuffer(std::vector<void *> &buffer);
  void unlockbuffer(std::vector<void *> &buffer);
  bool islocked(void *ptr);
  bool istracked(void *ptr);

private:
  Shadowtable() = default;
  std::unordered_map<void *, memDesc> memMap;
  std::mutex tablemutex;
};
