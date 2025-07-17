//
//  color.h
//  XLZZ
//
//  Created by 小李 on 2022/2/10.
//  Copyright © 2022 小李. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

// 默认alpha位1
+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end

