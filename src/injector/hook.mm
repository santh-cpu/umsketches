#include "../core/shadowtable.hpp"
#import "../core/validator.hpp"
#import "../utils/logger.hpp"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <iostream>
#import <objc/message.h>
#import <objc/runtime.h>
#include <vector>

static char keyUsedResources;

@interface BufferDeallocNotifier : NSObject
@property(nonatomic, assign) void *bufptr;
@end
@implementation BufferDeallocNotifier
- (void)dealloc {
  Shadowtable::get().freeAlloc(_bufptr);
  [super dealloc];
}
@end

id<MTLBuffer> swiznewbuflen(id<MTLDevice> self, SEL _cmd, NSUInteger length,
                            MTLResourceOptions options) {
  SEL org = NSSelectorFromString(@"ums_original_newBufferWithLength:options:");
  id<MTLBuffer> buf = ((
      id<MTLBuffer> (*)(id, SEL, NSUInteger, MTLResourceOptions))objc_msgSend)(
      self, org, length, options);
  if (buf) {
    Shadowtable::get().regAlloc((__bridge void *)buf, length);
    BufferDeallocNotifier *notifier = [[BufferDeallocNotifier alloc] init];
    notifier.bufptr = (__bridge void *)buf;
    objc_setAssociatedObject(buf, (__bridge const void *)notifier, notifier,
                             OBJC_ASSOCIATION_RETAIN);
  }
  return buf;
}

id<MTLCommandBuffer> swizcmdbuf(id<MTLCommandQueue> self, SEL _cmd) {
  SEL org = NSSelectorFromString(@"ums_original_commandBuffer");
  id<MTLCommandBuffer> cb =
      ((id<MTLCommandBuffer> (*)(id, SEL))objc_msgSend)(self, org);
  objc_setAssociatedObject(cb, &keyUsedResources, [NSMutableSet set],
                           OBJC_ASSOCIATION_RETAIN);
  return cb;
}

void swizzleUseResource(id<MTLComputeCommandEncoder> self, SEL _cmd,
                        id<MTLResource> resource, MTLResourceUsage usage) {
  SEL og = NSSelectorFromString(@"ums_original_useResource:usage:");
  ((void (*)(id, SEL, id<MTLResource>, MTLResourceUsage))objc_msgSend)(
      self, og, resource, usage);
  if ([resource conformsToProtocol:@protocol(MTLBuffer)]) {
    id<MTLCommandBuffer> cb = [((id)self) commandBuffer];
    NSMutableSet *used = objc_getAssociatedObject(cb, &keyUsedResources);
    [used addObject:[NSValue valueWithPointer:(__bridge void *)resource]];
  }
}

void swizzleUseResources(id<MTLComputeCommandEncoder> self, SEL _cmd,
                         const id<MTLResource> *resources, NSUInteger count,
                         MTLResourceUsage usage) {
  SEL og = NSSelectorFromString(@"ums_original_useResources:count:usage:");
  ((void (*)(id, SEL, const id<MTLResource> *, NSUInteger,
             MTLResourceUsage))objc_msgSend)(self, og, resources, count, usage);
  id<MTLCommandBuffer> cb = [((id)self) commandBuffer];
  NSMutableSet *used = objc_getAssociatedObject(cb, &keyUsedResources);
  for (NSUInteger i = 0; i < count; i++) {
    if ([resources[i] conformsToProtocol:@protocol(MTLBuffer)]) {
      [used addObject:[NSValue valueWithPointer:(__bridge void *)resources[i]]];
    }
  }
}

void swizzleFillBuffer(id<MTLBlitCommandEncoder> self, SEL _cmd,
                       id<MTLBuffer> buffer, NSRange range, uint8_t value) {
  SEL og = NSSelectorFromString(@"ums_original_fillBuffer:range:value:");
  ((void (*)(id, SEL, id<MTLBuffer>, NSRange, uint8_t))objc_msgSend)(
      self, og, buffer, range, value);
  if (buffer) {
    id<MTLCommandBuffer> cb = [((id)self) commandBuffer];
    NSMutableSet *used = objc_getAssociatedObject(cb, &keyUsedResources);
    [used addObject:[NSValue valueWithPointer:(__bridge void *)buffer]];
  }
}

void swizzlecommit(id<MTLCommandBuffer> self, SEL _cmd) {
  NSMutableSet *u = objc_getAssociatedObject(self, &keyUsedResources);
  auto buftolockPtr = std::make_shared<std::vector<void *>>();
  if (u) {
    buftolockPtr->reserve([u count]);
    for (NSValue *val in u) {
      buftolockPtr->push_back(val.pointerValue);
    }
  }
  if (!buftolockPtr->empty()) {
    Validator::get().lockbuffer(*buftolockPtr);
  }
  [self addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    if (!buftolockPtr->empty()) {
      Validator::get().unlockbuffer(*buftolockPtr);
    }
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
    NSLog(@"[UMS fatality] cpu accessed [MLTBuffer contents] during active gpu "
          @"dispatch");
    NSLog(@"stack trace: \n");
    for (NSString *e in stacktrace) {
      NSLog(@"%@", e);
    }
    Validator::get().checkaccess(
        raws,
        "[UMS fatality] cpu accessed [MLTBuffer contents] during active gpu");
  }
  return raw;
}

void swizzleSetBufferOffsetAtIndex(id<MTLComputeCommandEncoder> self, SEL _cmd,
                                   id<MTLBuffer> buffer, NSUInteger offset,
                                   NSUInteger index) {
  SEL og = NSSelectorFromString(@"ums_original_setBuffer:offset:atIndex:");
  ((void (*)(id, SEL, id<MTLBuffer>, NSUInteger, NSUInteger))objc_msgSend)(
      self, og, buffer, offset, index);
  if (buffer) {
    id<MTLCommandBuffer> cb = [((id)self) commandBuffer];
    NSMutableSet *used = objc_getAssociatedObject(cb, &keyUsedResources);
    [used addObject:[NSValue valueWithPointer:(__bridge void *)buffer]];
  }
}

void swizzleSetBuffersOffsetsWithRange(id<MTLComputeCommandEncoder> self,
                                       SEL _cmd, const id<MTLBuffer> *buffers,
                                       const NSUInteger *offsets,
                                       NSRange range) {
  SEL og = NSSelectorFromString(@"ums_original_setBuffers:offsets:withRange:");
  ((void (*)(id, SEL, const id<MTLBuffer> *, const NSUInteger *,
             NSRange))objc_msgSend)(self, og, buffers, offsets, range);
  id<MTLCommandBuffer> cb = [((id)self) commandBuffer];
  NSMutableSet *used = objc_getAssociatedObject(cb, &keyUsedResources);
  for (NSUInteger i = range.location;
       i < range.location + range.length && buffers[i] != nil; i++) {
    [used addObject:[NSValue valueWithPointer:(__bridge void *)buffers[i]]];
  }
}

__attribute__((constructor)) static void initums() {
  UMSSWIZ("strap on ums");
  id<MTLDevice> device = MTLCreateSystemDefaultDevice();
  id<MTLCommandQueue> queue = [device newCommandQueue];

  Class queueClass = [queue class];
  SEL ogCmdBuf = @selector(commandBuffer);
  SEL swizCmdBuf = NSSelectorFromString(@"ums_original_commandBuffer");
  Method mCmdBuf = class_getInstanceMethod(queueClass, ogCmdBuf);
  if (mCmdBuf) {
    class_addMethod(queueClass, swizCmdBuf, method_getImplementation(mCmdBuf),
                    method_getTypeEncoding(mCmdBuf));
    method_setImplementation(mCmdBuf, (IMP)swizcmdbuf);
  }

  id<MTLCommandBuffer> tempCmd = [queue commandBuffer];
  id<MTLComputeCommandEncoder> compEnc = [tempCmd computeCommandEncoder];
  Class compEncClass = [compEnc class];

  SEL ogSetBuf = @selector(setBuffer:offset:atIndex:);
  SEL swizSetBuf =
      NSSelectorFromString(@"ums_original_setBuffer:offset:atIndex:");
  Method mSetBuf = class_getInstanceMethod(compEncClass, ogSetBuf);
  if (mSetBuf) {
    class_addMethod(compEncClass, swizSetBuf, method_getImplementation(mSetBuf),
                    method_getTypeEncoding(mSetBuf));
    method_setImplementation(mSetBuf, (IMP)swizzleSetBufferOffsetAtIndex);
  }

  SEL ogSetBufs = @selector(setBuffers:offsets:withRange:);
  SEL swizSetBufs =
      NSSelectorFromString(@"ums_original_setBuffers:offsets:withRange:");
  Method mSetBufs = class_getInstanceMethod(compEncClass, ogSetBufs);
  if (mSetBufs) {
    class_addMethod(compEncClass, swizSetBufs,
                    method_getImplementation(mSetBufs),
                    method_getTypeEncoding(mSetBufs));
    method_setImplementation(mSetBufs, (IMP)swizzleSetBuffersOffsetsWithRange);
  }

  SEL ogUseRes = @selector(useResource:usage:);
  SEL swizUseRes = NSSelectorFromString(@"ums_original_useResource:usage:");
  Method mUseRes = class_getInstanceMethod(compEncClass, ogUseRes);
  if (mUseRes) {
    class_addMethod(compEncClass, swizUseRes, method_getImplementation(mUseRes),
                    method_getTypeEncoding(mUseRes));
    method_setImplementation(mUseRes, (IMP)swizzleUseResource);
  }

  SEL ogUseRess = @selector(useResources:count:usage:);
  SEL swizUseRess =
      NSSelectorFromString(@"ums_original_useResources:count:usage:");
  Method mUseRess = class_getInstanceMethod(compEncClass, ogUseRess);
  if (mUseRess) {
    class_addMethod(compEncClass, swizUseRess,
                    method_getImplementation(mUseRess),
                    method_getTypeEncoding(mUseRess));
    method_setImplementation(mUseRess, (IMP)swizzleUseResources);
  }

  [compEnc endEncoding];
  [tempCmd commit];

  id<MTLCommandBuffer> tempBlit = [queue commandBuffer];
  id<MTLBlitCommandEncoder> blitEnc = [tempBlit blitCommandEncoder];
  Class blitClass = [blitEnc class];

  SEL ogFill = @selector(fillBuffer:range:value:);
  SEL swizFill = NSSelectorFromString(@"ums_original_fillBuffer:range:value:");
  Method mFill = class_getInstanceMethod(blitClass, ogFill);
  if (mFill) {
    class_addMethod(blitClass, swizFill, method_getImplementation(mFill),
                    method_getTypeEncoding(mFill));
    method_setImplementation(mFill, (IMP)swizzleFillBuffer);
  }

  [blitEnc endEncoding];
  [tempBlit commit];

  Class deviceClass = [device class];
  SEL ogAlloc = @selector(newBufferWithLength:options:);
  SEL swizAlloc =
      NSSelectorFromString(@"ums_original_newBufferWithLength:options:");
  Method mAlloc = class_getInstanceMethod(deviceClass, ogAlloc);
  if (mAlloc) {
    class_addMethod(deviceClass, swizAlloc, method_getImplementation(mAlloc),
                    method_getTypeEncoding(mAlloc));
    method_setImplementation(mAlloc, (IMP)swiznewbuflen);
  }

  id<MTLCommandBuffer> cmdbuffer = [queue commandBuffer];
  Class cmdclass = [cmdbuffer class];
  SEL ogcommit = @selector(commit);
  SEL swizcommit = NSSelectorFromString(@"ums_original_commit");
  Method mCommit = class_getInstanceMethod(cmdclass, ogcommit);
  class_addMethod(cmdclass, swizcommit, method_getImplementation(mCommit),
                  method_getTypeEncoding(mCommit));
  method_setImplementation(mCommit, (IMP)swizzlecommit);

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
}
