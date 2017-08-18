//
//  WTVSegementControl.m
//  WoTV
//
//  Created by 周恩慧 on 2017/7/27.
//  Copyright © 2017年 wotv. All rights reserved.
//

#import "WTVSegementControl.h"
#import <mach/mach_time.h>
#import "NSString+Size.h"
#import "UIView+Frame.h"


@interface ZTopButton : UIButton

@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, strong) UIFont *normalFont;


@end

@implementation ZTopButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _normalTitleColor = [UIColor darkGrayColor];
        _selectedTitleColor = [UIColor blackColor];
        [self setTitleColor:_selectedTitleColor forState:UIControlStateSelected];
        [self setTitleColor:_normalTitleColor forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    
    [self setTitleColor:selected ?_selectedTitleColor : _normalTitleColor forState:UIControlStateNormal];
    self.titleLabel.font = selected?self.selectedFont:self.normalFont;
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor{
    _normalTitleColor = normalTitleColor;
    [self setTitleColor:_normalTitleColor forState:UIControlStateNormal];
    self.titleLabel.font = self.normalFont;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor{
    _selectedTitleColor = selectedTitleColor;
    [self setTitleColor:_selectedTitleColor forState:UIControlStateSelected];
}

@end

CGFloat const kScrollViewOffsetDeviation = 10; //误差

NSString * const kCJSegementViewContentOffset = @"contentOffset";

@interface WTVSegementControl()<UIScrollViewDelegate>

@property (nonatomic, weak  ) ZTopButton *lastSelectedButton;
@property (nonatomic, strong) NSMutableArray<ZTopButton *> *mutArr;
//
@property (nonatomic, assign) CGFloat selectionWidth;
@property (nonatomic, assign) CGFloat buttonWith;
@property (nonatomic, assign) CGFloat buttonHeight;

@property (nonatomic ,assign) BOOL isUserTap;
@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) NSMutableArray *withArray;
@property (nonatomic, assign) CGFloat totalW;

@end

@implementation WTVSegementControl

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _mutArr = @[].mutableCopy;
        _gradientOffset = 0;
        _gradientWidth = 30;
        _gradientHeight = 3;
        _gradientBottomMargin = 4;
        _fontSize = 18;
        _normalColor = [UIColor blackColor];
        _selectedColor = [UIColor redColor];
        _selectedFont = [UIFont boldSystemFontOfSize:18];
        
        _buttonMargin = 21;
        self.scrollEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        _buttonHeight = frame.size.height - _gradientHeight - 2 * _gradientBottomMargin;
     
        [self addSubview:self.lineImageView];
        
        
    }
    return self;
}
#pragma mark - Actions

- (void)clickAction:(ZTopButton *)button{
    _isUserTap = YES;
    button.selected = YES;
    
    if (![button isEqual:_lastSelectedButton]) {
        _lastSelectedButton.selected = NO;

    }
    
    _lastSelectedButton = button;
    [self _triggerDelegate];
    [self _adjustSelectedPosition];
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * button.tag, 0) animated:NO];
    [self _adjustProgressLayerFrame];
    
    
    _isUserTap = NO;

}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (_isUserTap) return;
    if (object == _scrollView) {
        
        CGPoint new = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (!_scrollView.dragging && new.x == 0) return;
        if (new.x < 0 || new.x > (_scrollView.contentSize.width - _scrollView.frame.size.width)) return;
      
        CGPoint oldValue = [change[NSKeyValueChangeOldKey] CGPointValue];
        
        //上个按钮和当前按钮之间的width差
        CGFloat buttonGap = 0;
        
        if ((new.x >= (_lastSelectedButton.tag  * _scrollView.frame.size.width + _scrollView.frame.size.width))) {
            _lastSelectedButton.selected = NO;
            ZTopButton *btn = _mutArr[_lastSelectedButton.tag + 1];
            buttonGap = btn.width - _lastSelectedButton.width;
            _lastSelectedButton = btn;
            _selectionWidth = [self withAndMargin:btn];
            _buttonWith = [self withWithBtn:btn];
            
            btn.selected = YES;
            [self _adjustSelectedPosition];
            [self _triggerDelegate];
        }else if (new.x < (_lastSelectedButton.tag * _scrollView.frame.size.width - _scrollView.frame.size.width) + kScrollViewOffsetDeviation){
            _lastSelectedButton.selected = NO;
            ZTopButton *btn = _mutArr[_lastSelectedButton.tag - 1];
             buttonGap = btn.width - _lastSelectedButton.width;
            _lastSelectedButton = btn;
            
            _selectionWidth = [self withAndMargin:btn];
            _buttonWith = [self withWithBtn:btn];
            
            btn.selected = YES;
            [self _adjustSelectedPosition];
            [self _triggerDelegate];
        }else{
            
            
            if (oldValue.x < new.x) { //往左拽，tag+1;
                
                if (_mutArr.count > (_lastSelectedButton.tag +1)) {
                  ZTopButton * btn = _mutArr[_lastSelectedButton.tag + 1];
                     buttonGap = btn.width - _lastSelectedButton.width;
                    _buttonWith = [self withWithBtn:btn];
                    _selectionWidth = [self withAndMargin:btn];
                }
                
                
            }else if (oldValue.x > new.x){ //
                
                if ((_lastSelectedButton.tag - 1)>0) {
                  ZTopButton  *btn = _mutArr[_lastSelectedButton.tag - 1];
                     buttonGap = btn.width - _lastSelectedButton.width;
                    _buttonWith = [self withWithBtn:btn];
                    _selectionWidth = [self withAndMargin:btn];
                }
             

                
            }
            
        }

      
        _selectionWidth = _selectionWidth - buttonGap/2;
        
         CGFloat halfMargin = (_lastSelectedButton.width - _gradientWidth) / 2.;
        CGFloat originX = _lastSelectedButton.x + halfMargin;
        CGFloat scrOriginX = _scrollView.frame.size.width * _lastSelectedButton.tag;
        CGFloat layerY = self.frame.size.height - _gradientBottomMargin - _gradientHeight;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (new.x >= scrOriginX) {
            CGFloat currentMidX = (_lastSelectedButton.tag * _scrollView.frame.size.width + _scrollView.frame.size.width / 2.);
            if (new.x >= currentMidX) {
                CGFloat rate = (new.x - currentMidX) / (_scrollView.frame.size.width / 2.);
                self.lineImageView.frame = CGRectMake( originX +  _selectionWidth + _gradientWidth , layerY, - (_gradientWidth + (1 - rate) * _selectionWidth), _gradientHeight);
            }else{
                CGFloat rate = (currentMidX - new.x) / (_scrollView.frame.size.width / 2.);
                self.lineImageView.frame = CGRectMake( originX  , layerY, _gradientWidth + (1 - rate) * _selectionWidth, _gradientHeight);
            }
        }
        else{
            CGFloat currentMidX = (_lastSelectedButton.tag * _scrollView.frame.size.width - _scrollView.frame.size.width / 2.);
            if (new.x > currentMidX) {
                CGFloat rate = ( new.x - currentMidX) / (_scrollView.frame.size.width / 2.);
                self.lineImageView.frame = CGRectMake( originX + _gradientWidth , layerY, - (_gradientWidth + (1 - rate) * _selectionWidth), _gradientHeight);
            }else{
                CGFloat rate =  (currentMidX -  new.x) / (_scrollView.frame.size.width / 2.);
                self.lineImageView.frame = CGRectMake(originX - _selectionWidth, layerY, (1-rate) * _selectionWidth + _gradientWidth, _gradientHeight);
            }
        }
        
        [CATransaction commit];
    }
}

- (CGFloat)withWithBtn:(ZTopButton *)btn {
    
    if (btn.tag > _withArray.count) {
        return 50;
    }
    NSNumber *number = [_withArray objectAtIndex:btn.tag];
    return  number.floatValue ;
    
}

- (CGFloat)withAndMargin:(ZTopButton *)btn {
    
    if (btn.tag > _withArray.count) {
        return 50;
    }
    NSNumber *number = [_withArray objectAtIndex:btn.tag];
    return  number.floatValue + _buttonMargin ;

}

- (CGFloat)xWithBtn:(ZTopButton *)btn {
    if (btn.tag > _withArray.count) {
        return 0;
    }
    
   __block CGFloat originX = 0;
     [_withArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
         
        
         if (btn.tag == idx) {
            
             *stop = YES;
         }
         if (btn.tag != idx) {
              originX += (obj.floatValue + _buttonMargin);
         }
        
     }];
    return originX;
    
}
#pragma mark - Private Methods

- (void)_adjustSelectedPosition{
    
 
    CGFloat gap = (self.frame.size.width - [self withWithBtn:_lastSelectedButton])/2.;
    CGFloat correctX = _lastSelectedButton.x - gap - _gradientOffset;
    
    if (self.totalW>self.width) {
        if (correctX < 0 ) {
            [self setContentOffset:CGPointMake(0, 0) animated:YES];
            return;
        }
        
        if (correctX > (self.contentSize.width - self.frame.size.width)) {
            [self setContentOffset:CGPointMake(self.contentSize.width - self.frame.size.width, 0) animated:YES];
            return;
        }
        [self setContentOffset:CGPointMake(correctX, 0) animated:YES];

    }
    
    
}


- (void)_triggerDelegate{
    if ([self.eHDelegate respondsToSelector:@selector(segmentControlSelected:)]) {
        [self.eHDelegate segmentControlSelected:_lastSelectedButton.tag];
    }
}

- (void)_adjustProgressLayerFrame{
    CGFloat halfMargin = ([self withWithBtn:_lastSelectedButton] - _gradientWidth) / 2.;
    self.lineImageView.frame = CGRectMake(_lastSelectedButton.x+halfMargin , self.frame.size.height - _gradientBottomMargin - _gradientHeight, _gradientWidth, _gradientHeight);
}

- (void)setScrollView:(UIScrollView *)scrollView {
    

    _scrollView = scrollView;
    _scrollView.bounces = NO;
    if (_scrollView) [_scrollView addObserver:self forKeyPath:kCJSegementViewContentOffset options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:nil];
    
}

- (void)setTitleArray:(NSArray *)titleArray {
    
    _titleArray = titleArray;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[ZTopButton class]]) {
            [obj removeFromSuperview];
        }
    }];
    [self.mutArr removeAllObjects];
    
    
    _withArray = [NSMutableArray array];
  
    

    
     self.totalW = 0;
    for (int i = 0; i < titleArray.count;i++) {
        
        //按钮长度array
        NSString *title = titleArray[i] ;
        CGSize size = [title sizeWithFont:self.selectedFont];
        
        self.totalW += size.width + _buttonMargin ;
        
        [_withArray addObject:@(size.width)];
        
        NSNumber *lastobject = _withArray.lastObject;
        
        ZTopButton *titleButton = [[ZTopButton alloc] initWithFrame:CGRectMake(self.totalW - lastobject.floatValue - _buttonMargin, 5, size.width, _buttonHeight)];
        [titleButton setTitleColor:self.selectedColor forState:UIControlStateSelected];
        titleButton.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
     
        titleButton.selectedFont = self.selectedFont;
        titleButton.normalFont = [UIFont systemFontOfSize:self.fontSize];
        titleButton.selectedTitleColor = self.selectedColor;
        titleButton.normalTitleColor = self.normalColor;
       
        titleButton.userInteractionEnabled = YES;
        titleButton.tag = i;
        [titleButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [titleButton setTitle:title forState:UIControlStateNormal];
        [_mutArr addObject:titleButton];
        if (0 == i) {_lastSelectedButton = titleButton;_lastSelectedButton.selected = YES;};
        [self addSubview:titleButton];
        
        if (i==titleArray.count-1) {
            self.totalW -= _buttonMargin;
        }
        
        
    }
    
     self.contentSize = CGSizeMake(self.totalW, self.frame.size.height);
    
    [self _adjustProgressLayerFrame];
    
    
    
}
#pragma mark - Getter & Setter

- (void)setSelectedFont:(UIFont *)selectedFont {
    
    _selectedFont = selectedFont;
    for (ZTopButton *button in _mutArr) {
        button.selectedFont = _selectedFont;
    }
    
}


- (void)setGradientBottomMargin:(CGFloat)gradientBottomMargin{
    _gradientBottomMargin = gradientBottomMargin;
    [self _adjustProgressLayerFrame];
}

-(void)setButtonMargin:(CGFloat)buttonMargin
{
    _buttonMargin = buttonMargin;
}



- (void)setGradientWidth:(CGFloat)gradientWidth{
    _gradientWidth = gradientWidth;
    [self _adjustProgressLayerFrame];
}

- (void)setGradientHeight:(CGFloat)gradientHeight{
    _gradientHeight = gradientHeight;
    [self _adjustProgressLayerFrame];
}

- (void)setIndex:(NSInteger)index{
    _index = index;
    if (_index == 0 && _mutArr.count) {
        [self clickAction:_mutArr[index]];
        
    }
    if (index-1 >_mutArr.count) return;
    ZTopButton *btn = _mutArr[index];
    [self clickAction:btn];
}

- (void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    for (ZTopButton * button in _mutArr) {
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        button.normalFont = [UIFont systemFontOfSize:fontSize];
    }
}

- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    for (ZTopButton *button in _mutArr) {
        button.normalTitleColor = normalColor;
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
    for (ZTopButton *button in _mutArr) {
        button.selectedTitleColor = selectedColor;
    }
}

- (void)setLineImage:(UIImage *)lineImage {
    
    _lineImage = lineImage;
    
    self.lineImageView.image = _lineImage;
    _gradientWidth = lineImage.size.width;
    _gradientHeight = lineImage.size.height;
}


- (UIImageView *)lineImageView{
    
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc]init];
        _lineImageView.backgroundColor = [UIColor orangeColor];
        _lineImageView.clipsToBounds = YES;
        _lineImageView.layer.cornerRadius = 2;
    }
    
    return _lineImageView;
    
}


#pragma mark - Life Circle

- (void)dealloc{
    if (_scrollView) [_scrollView removeObserver:self forKeyPath:kCJSegementViewContentOffset];
}
@end
