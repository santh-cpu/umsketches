#import "../core/validator.hpp"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <iostream>
#import <objc/message.h>
#import <objc/runtime.h>

void swizzlecommit(id<MTLCommandBuffer> self, SEL _cmd) {
  Validator::get_instance().lockbuffer((__bridge void *)self);

  [self addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    Validator::get_instance().unlockbuffer((__bridge void *)buffer);
  }];

  SEL ogSelector = NSSelectorFromString(@"ums_original_commit");
  ((void (*)(id, SEL))objc_msgSend)(self, ogSelector);
}

void *swizzlecontent(id<MTLBuffer> self, SEL _cmd) {
  SEL ogSelector = NSSelectorFromString(@"ums_original_content");
  void *raw = ((void *(*)(id, SEL))objc_msgSend)(self, ogSelector);

  if (Validator::get_instance().gpubusy()) {
    NSArray *stacktrace = [NSThread callStackSymbols];
    NSLog(@"[UMS fatality] cpu accessed [MLTBuffer contents] during active gpu"
          @" dispatch");
    NSLog(@"stack trace: \n");
    for (NSString *e in stacktrace) {
      NSLog(@"%@", e);
    }
    Validator::get_instance().checkaccess(
        raw,
        "[UMS fatality] cpu accessed [MLTBuffer contents] during active gpu");
  }
  return raw;
}

__attribute__((constructor)) static void initums() {
  std::cout << "strap on ums" << std::endl;
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

  std::cout << "gateway armed" << std::endl;

  std::cout << "[Test] spawning cpu zombie" << std::endl;
  id<MTLCommandBuffer> testcmd = [queue commandBuffer];
  [testcmd commit];
  std::cout << "[Test] cpu asking for ram contents" << std::endl;
  [databuffer contents];
}
