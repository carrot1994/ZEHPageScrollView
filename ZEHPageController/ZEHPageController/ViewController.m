//
//  ViewController.m
//  ZEHPageController
//
//  Created by 周恩慧 on 2017/8/18.
//  Copyright © 2017年 周恩慧. All rights reserved.
//

#import "ViewController.h"
#import "WTVSegementControl.h"
#import "UIView+Frame.h"

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

@interface ViewController ()<WTVSegmentControlDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WTVSegementControl *segementControl;
@property (nonatomic, strong) NSArray<NSString *> *titleArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.segementControl];
    [self.view addSubview:self.scrollView];
    
    self.titleArray = @[@"我",@"是",@"一只",@"Gluneko迷妹"];
}


#pragma mark - lazyLoad
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.frame  = CGRectMake(0, 64.0f, self.view.width, self.view.height - 64.0f);
    }
    return _scrollView;
}
- (WTVSegementControl *)segementControl {
    
    if (!_segementControl) {
        
        _segementControl =  [[WTVSegementControl alloc] initWithFrame:CGRectMake(20, 20, self.view.width , 44.0f)];
        _segementControl.backgroundColor = [UIColor whiteColor];
        _segementControl.lineImage = [UIImage imageNamed:@"video_line_xuanzhong"];
        _segementControl.selectedColor = [UIColor redColor];
        _segementControl.normalColor = [UIColor blackColor];
        _segementControl.fontSize = 18;
        _segementControl.backgroundColor = [UIColor clearColor];
        _segementControl.gradientBottomMargin = 5;
        _segementControl.selectedFont = [UIFont boldSystemFontOfSize:18];
        _segementControl.eHDelegate = self;
        
        

    }
    return _segementControl;
}

- (void)setTitleArray:(NSArray<NSString *> *)titleArray {
    
    _titleArray = titleArray;
    
    self.segementControl.titleArray = titleArray;
    self.segementControl.scrollView = self.scrollView;
    self.scrollView.contentSize = CGSizeMake(titleArray.count * self.view.width, 0);
    
    
    //这里也可以添加子控制器，然后再addSubview
    [titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        UIView *view =[[UIView alloc]init];
        view.frame = CGRectMake(idx * self.view.width, 0, self.scrollView.width, self.scrollView.height);
        view.backgroundColor = kRandomColor;
        
        [self.scrollView addSubview:view];
    }];
    
    //默认选中位置
    if (_titleArray.count) {
        self.segementControl.index = 0;
    }
    
}


#pragma mark - segementControDelegate
- (void)segmentControlSelected:(NSInteger)tag {
    
    NSLog(@"选中了第%ld个gluneko",tag);
}

@end
