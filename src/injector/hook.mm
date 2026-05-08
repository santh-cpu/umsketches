#import "../core/validator.hpp"
#import "../utils/logger.hpp"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <iostream>
#import <objc/message.h>
#import <objc/runtime.h>
#include <vector>

void swizzlecommit(id<MTLCommandBuffer> self, SEL _cmd) {
  void *raw = ((__bridge void *)self);
  std::vector<void *> buffer = {raw};
  Validator::get().lockbuffer(buffer);

  [self addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    void *rawb = ((__bridge void *)buffer);
    std::vector<void *> completedbuffer = {rawb};
    Validator::get().unlockbuffer(completedbuffer);
  }];

  SEL ogSelector = NSSelectorFromString(@"ums_original_commit");
  ((void (*)(id, SEL))objc_msgSend)(self, ogSelector);
}

void *swizzlecontent(id<MTLBuffer> self, SEL _cmd) {
  SEL ogSelector = NSSelectorFromString(@"ums_original_content");
  void *raw = ((void *(*)(id, SEL))objc_msgSend)(self, ogSelector);

  void *raws = (__bridge void *)self;
  if (Validator::get().islocked(raws)) {
    NSArray *stacktrace = [NSThread callStackSymbols];
    NSLog(@"[UMS fatality] cpu accessed [MLTBuffer contents] during active gpu"
          @" dispatch");
    NSLog(@"stack trace: \n");
    for (NSString *e in stacktrace) {
      NSLog(@"%@", e);
    }
    Validator::get().checkaccess(
        raw,
        "[UMS fatality] cpu accessed [MLTBuffer contents] during active gpu");
  }
  return raw;
}

__attribute__((constructor)) static void initums() {
  UMSSWIZ("strap on ums");
  id<MTLDevice> device = MTLCreateSystemDefaultDevice();
  id<MTLCommandQueue> queue = [device newCommandQueue];

  // commit
  id<MTLCommandBuffer> cmdbuffer = [queue commandBuffer];
  Class cmdclass = [cmdbuffer class];
  SEL ogcommit = @selector(commit);
  SEL swizcommit = NSSelectorFromString(@"ums_original_commit");
  Method mCommit = class_getInstanceMethod(cmdclass, ogcommit);
  class_addMethod(cmdclass, swizcommit, method_getImplementation(mCommit),
                  method_getTypeEncoding(mCommit));
  method_setImplementation(mCommit, (IMP)swizzlecommit);

  // content
  id<MTLBuffer> databuffer =
      [device newBufferWithLength:16 options:MTLResourceStorageModeShared];
  Class bufferclass = [databuffer class];
  SEL ogcontent = @selector(contents);
  SEL swizcontent = NSSelectorFromString(@"ums_original_content");
  Method mContent = class_getInstanceMethod(bufferclass, ogcontent);
  class_addMethod(bufferclass, swizcontent, method_getImplementation(mContent),
                  method_getTypeEncoding(mContent));
  method_setImplementation(mContent, (IMP)swizzlecontent);

  UMSSWIZ("gateway armed");

  /*
    std::cout << "[Test] spawning cpu zombie" << std::endl;
    id<MTLCommandBuffer> testcmd = [queue commandBuffer];
    [testcmd commit];
    std::cout << "[Test] cpu asking for ram contents" << std::endl;
    [databuffer contents];
  */
}
