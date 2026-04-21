#import "../core/validator.hpp"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <iostream>
#import <objc/message.h>
#import <objc/runtime.h>

void swizzle_commit(id<MTLCommandBuffer> self, SEL _cmd) {
  Validator::get_instance().lock_buffer((__bridge void *)self);
}
