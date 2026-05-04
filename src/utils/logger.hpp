#pragma once
#include <cstdlib>
#include <os/log.h>

extern os_log_t umslog;

#define UMSINFO(msg, ...) os_log_info(umslog, "[UMS] " msg, ##__VA_ARGS__)
#define UMSSWIZ(msg, ...) os_log_info(umslog, "[UMS SWIZ]" msg, ##__VA_ARGS__)
#define UMSFATAL(context, ptr)                                                 \
  do {                                                                         \
    os_log_fault(umslog, "[UMS FATAL RACE] context:%s | address:%p", context,  \
                 ptr);                                                         \
    std::abort();                                                              \
  } while (0)
