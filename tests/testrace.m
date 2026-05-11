#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <objc/runtime.h>

int main() {
  id<MTLDevice> device = MTLCreateSystemDefaultDevice();
  id<MTLCommandQueue> queue = [device newCommandQueue];

  NSUInteger size = 512 * 1024 * 1024;
  id<MTLBuffer> buf = [device newBufferWithLength:size
                                          options:MTLResourceStorageModeShared];

  NSLog(@"[testrace] buf class: %s", class_getName(object_getClass(buf)));
  IMP imp =
      class_getMethodImplementation(object_getClass(buf), @selector(contents));
  NSLog(@"[testrace] contents IMP: %p", (void *)imp);

  id<MTLCommandBuffer> cmd = [queue commandBuffer];
  id<MTLBlitCommandEncoder> blit = [cmd blitCommandEncoder];
  [blit fillBuffer:buf range:NSMakeRange(0, buf.length) value:0xFF];
  [blit endEncoding];

  // commit triggers lockbuffer in ums
  [cmd commit];

  NSLog(@"[testrace] calling contents immediately after commit...");
  volatile uint8_t *ptr = (volatile uint8_t *)[buf contents];
  NSLog(@"[testrace] read byte: %d -- no abort means buf was not locked",
        ptr[0]);

  [cmd waitUntilCompleted];
  return 0;
}
