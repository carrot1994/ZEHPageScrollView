//
//  WTVSegementControl.h
//  WoTV
//
//  Created by 周恩慧 on 2017/7/27.
//  Copyright © 2017年 wotv. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WTVSegmentControlDelegate <NSObject>

@optional
- (void)segmentControlSelected:(NSInteger)tag;

@end

@interface WTVSegementControl : UIScrollView


@property (nonatomic, weak  ) id<WTVSegmentControlDelegate> eHDelegate;

@property (nonatomic, assign) NSInteger index;


@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) UIColor *normalColor;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, strong) UIFont *selectedFont;

///  default 30
@property (nonatomic, assign) CGFloat gradientWidth;
///  default 3
@property (nonatomic, assign) CGFloat gradientHeight;
///  default 4
@property (nonatomic, assign) CGFloat gradientBottomMargin;

@property (nonatomic, assign) CGFloat gradientOffset;

@property (nonatomic, assign) CGFloat buttonMargin;

@property (nonatomic, strong) UIImage *lineImage;

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UIScrollView *scrollView;


@end
