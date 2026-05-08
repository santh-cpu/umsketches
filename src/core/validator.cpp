#include "validator.hpp"
#include "../utils/logger.hpp"
#include "shadowtable.hpp"
#include <stddef.h>

Validator &Validator::get() {
  static Validator instance;
  return instance;
}

void Validator::lockbuffer(std::vector<void *> &buffer) {
  Shadowtable::get().lockbuffer(buffer);
  if (!buffer.empty()) {
    UMSINFO("added    %zu data buffers", buffer.size());
  }
}

void Validator::unlockbuffer(std::vector<void *> &buffer) {
  Shadowtable::get().unlockbuffer(buffer);
  if (!buffer.empty()) {
    UMSINFO("released %zu data buffers", buffer.size());
  }
}

void Validator::checkaccess(void *ptr, const char *context) {
  if (Shadowtable::get().islocked(ptr)) {
    UMSFATAL(context, ptr);
  }
}

bool Validator::islocked(void *ptr) { return Shadowtable::get().islocked(ptr); }
