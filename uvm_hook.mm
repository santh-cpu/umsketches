#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <iostream>
#import <objc/message.h>
#import <objc/runtime.h>

void swizzle_commit(id self, SEL _cmd) {
  std::cout << "[UVM handoff] intercepted metal commit from mlx" << std::endl;

  SEL originalSelector = NSSelectorFromString(@"umv_orignal_commit");
  ((void (*)(id, SEL))objc_msgSend)(self, originalSelector);
}

__attribute__((constructor)) static void initialize_umv() {
  std::cout << "[UMV] injecting into process" << std::endl;
  id<MTLDevice> device = MTLCreateSystemDefaultDevice();
  id<MTLCommandQueue> queue = [device newCommandQueue];
  id<MTLCommandBuffer> buffer = [queue commandBuffer];
  Class concreteclass = [buffer class];

  SEL originalSelector = @selector(commit);
  SEL swizzle_selector = NSSelectorFromString(@"umv_orignal_commit");

  Method originalMethod;
}
