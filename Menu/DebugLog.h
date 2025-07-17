// DisableLogging.h
#import <Foundation/Foundation.h>

// 定义一个完全不进行任何操作的 NSLog
#define NSLog(...) do { } while (0)
