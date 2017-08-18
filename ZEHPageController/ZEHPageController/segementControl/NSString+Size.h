//
//  NSString+Size.h
//  HLWJ
//
//  Created by 周恩慧 on 2017/8/7.
//  Copyright © 2017年 wotv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)

- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW maxH:(CGFloat)maxH;
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;
- (CGSize)sizeWithFont:(UIFont *)font;

@end
