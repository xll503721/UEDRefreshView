//
//  UEDRefreshView.m
//  TestUEDRefreshView
//
//  Created by xlL on 16/12/24.
//  Copyright © 2016年 UED. All rights reserved.
//

#import "UEDRefreshView.h"

@interface UEDRefreshViewSubviewPinModel : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) UEDRefreshViewSubviewPin pin;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat originalY;
@property (nonatomic, assign) BOOL animated;

@end

@implementation UEDRefreshViewSubviewPinModel

//no overwrite method hash, becase no use model in NSSet or NSDictionary

- (BOOL)isEqual:(UEDRefreshViewSubviewPinModel *)object {
    if (self.view == object.view && self.pin == object.pin && self.offset == object.offset) {
        return YES;
    }
    return NO;
}

@end

static NSString * const kUEDRefreshViewScrollViewContentOffset = @"contentOffset";

@interface UEDRefreshView ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) UIEdgeInsets scrollViewOriginalInset;
@property (nonatomic, assign) UEDRefreshViewState refreshNextState;

@property (nonatomic, assign) BOOL changeStateToRefreshing;

@property (nonatomic, strong) NSMutableArray <UEDRefreshViewSubviewPinModel *>*subviewPins;

@end

@implementation UEDRefreshView

- (void)dealloc
{
//    NSLog(@"UEDRefreshView dealloc");
}

- (instancetype)initWithContentViewXibName:(NSString *)xibName
{
    self = [super init];
    if (self) {
        self.subviewPins = [[NSMutableArray alloc] init];
        
        self.contentView = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil].firstObject;
        [self addSubview:self.contentView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if ((newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]])) {
        return;
    }
    
    [self.superview removeObserver:self forKeyPath:kUEDRefreshViewScrollViewContentOffset];
    if (newSuperview != self.superview && newSuperview) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, 0);
        [self.scrollView addObserver:self forKeyPath:kUEDRefreshViewScrollViewContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)setRefreshViewHeight:(CGFloat)refreshViewHeight {
    _refreshViewHeight = refreshViewHeight;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = self.scrollView.frame.size.width;
    frame.size.height = self.scrollView.contentOffset.y + self.scrollView.contentInset.top;
    if (self.refreshState == UEDRefreshViewStateRefreshing) {
        frame.size.height = self.refreshViewHeight;
        frame.origin.y = -self.refreshViewHeight;
    }
    else {
        self.scrollViewOriginalInset = self.scrollView.contentInset;
    }
    self.frame = frame;
    
    [self layoutPin];
    
    if (self.refreshState != UEDRefreshViewStateRefreshing) {
        self.changeStateToRefreshing = fabs(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) >= self.refreshViewHeight;
    }
    
    if (fabs(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) < self.refreshViewHeight
        && self.scrollView.contentOffset.y + self.scrollView.contentInset.top > 0
        && self.refreshState != UEDRefreshViewStateRefreshing
        && self.refreshState != UEDRefreshViewStateNormal
        && self.refreshState != UEDRefreshViewStateSpringbackToRefreshing) {
        self.refreshState = UEDRefreshViewStateSpringbackToNormal;
        self.refreshNextState = UEDRefreshViewStateNormal;
    }
    
    if (self.scrollView.isDragging) {
        if (self.scrollView.contentOffset.y + self.scrollView.contentInset.top < 0 && self.refreshState != UEDRefreshViewStateRefreshing) {
            self.refreshState = UEDRefreshViewStatePulling;
            self.refreshNextState = (self.changeStateToRefreshing ? UEDRefreshViewStateSpringbackToRefreshing : UEDRefreshViewStateSpringbackToNormal);
        }
    }
    else {
        
        if (self.changeStateToRefreshing) {
            if (fabs(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) <= self.refreshViewHeight  && self.refreshState == UEDRefreshViewStateSpringbackToRefreshing) {
                self.changeStateToRefreshing = NO;
                self.refreshState = UEDRefreshViewStateRefreshing;
                self.refreshNextState = UEDRefreshViewStateSpringbackToNormal;
            }
            
            if (fabs(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) > self.refreshViewHeight && self.refreshState == UEDRefreshViewStatePulling) {
                self.refreshState = UEDRefreshViewStateSpringbackToRefreshing;
                self.refreshNextState = UEDRefreshViewStateRefreshing;
            }
        }
    }
}

- (void)layoutPin {
    
    if (self.refreshState == UEDRefreshViewStateRefreshing) {
        return;
    }
    
    [self.subviewPins enumerateObjectsUsingBlock:^(UEDRefreshViewSubviewPinModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = obj.view.frame;
        if (obj.pin == UEDRefreshViewSubviewPinBottom) {
            frame.origin.y = -(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) - obj.view.frame.size.height + obj.offset;
        }
        else if (obj.pin == UEDRefreshViewSubviewPinTop) {
            frame.origin.y = MIN(-(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) + obj.offset, obj.originalY);
        }
        obj.view.frame = frame;
    }];
}

- (void)setRefreshState:(UEDRefreshViewState)state {
    
    if (_refreshState != state) {
        CGFloat height = -(self.scrollView.contentOffset.y + self.scrollView.contentInset.top);
        if (self.refreshState == UEDRefreshViewStateRefreshing) {
            height = self.refreshViewHeight;
        }
        
        if ([self.contentView respondsToSelector:@selector(refreshView:willChangeState:height:)]) {
            if (![(id<UEDRefreshViewProtocol>)self.contentView refreshView:self willChangeState:_refreshState height:height]) {
                return;
            }
        }
        _refreshState = state;
        
        switch (state) {
            case UEDRefreshViewStateNormal:{
                NSLog(@"UEDRefreshViewStateNormal");
                
            }
                break;
            case UEDRefreshViewStatePulling:
                NSLog(@"UEDRefreshViewStatePulling");
                break;
            case UEDRefreshViewStateSpringbackToRefreshing: {
                NSLog(@"UEDRefreshViewStateSpringbackToRefreshing");
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -(self.scrollViewOriginalInset.top + self.refreshViewHeight)) animated:YES];
            }
                break;
            case UEDRefreshViewStateSpringbackToNormal: {
                NSLog(@"UEDRefreshViewStateSpringbackToNormal");
                [UIView animateWithDuration:0.25 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollViewOriginalInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
                } completion:^(BOOL finished) {
                    self.refreshState = UEDRefreshViewStateNormal;
                }];
            }
                break;
            case UEDRefreshViewStateRefreshing: {
                NSLog(@"UEDRefreshViewStateRefreshing");
                self.scrollViewOriginalInset = self.scrollView.contentInset;
                self.scrollView.contentInset = UIEdgeInsetsMake((self.scrollViewOriginalInset.top + self.refreshViewHeight), self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
                break;
                
            default:
                break;
        }
        
        if ([self.contentView respondsToSelector:@selector(refreshView:didChangeState:height:)]) {
            [(id<UEDRefreshViewProtocol>)self.contentView refreshView:self didChangeState:_refreshState height:height];
        }
    }
}

- (void)setRefreshNextState:(UEDRefreshViewState)refreshNextState {
    if (_refreshNextState != refreshNextState) {
        _refreshNextState = refreshNextState;
        
        switch (_refreshNextState) {
            case UEDRefreshViewStateNormal:{
                NSLog(@"next UEDRefreshViewStateNormal");
                
            }
                break;
            case UEDRefreshViewStatePulling:
                NSLog(@"next UEDRefreshViewStatePulling");
                break;
            case UEDRefreshViewStateSpringbackToRefreshing: {
                NSLog(@"next UEDRefreshViewStateSpringbackToRefreshing");
            }
                break;
            case UEDRefreshViewStateSpringbackToNormal:
                NSLog(@"next UEDRefreshViewStateSpringbackToNormal");
                break;
            case UEDRefreshViewStateRefreshing:
                NSLog(@"next UEDRefreshViewStateRefreshing");
                break;
                
            default:
                break;
        }
        
        if ([self.contentView respondsToSelector:@selector(refreshView:willChangeNextState:height:)]) {
            CGFloat height = -(self.scrollView.contentOffset.y + self.scrollView.contentInset.top);
            if (self.refreshState == UEDRefreshViewStateRefreshing) {
                height = self.refreshViewHeight;
            }
            [(id<UEDRefreshViewProtocol>)self.contentView refreshView:self willChangeNextState:_refreshNextState height:height];
        }
    }
}

- (void)beginRefreshing {
    self.refreshState = UEDRefreshViewStateSpringbackToRefreshing;
    self.refreshNextState = UEDRefreshViewStateRefreshing;
}

- (void)endRefreshing {
    self.refreshState = UEDRefreshViewStateSpringbackToNormal;
    self.refreshNextState = UEDRefreshViewStateNormal;
}

- (void)scrollPinView:(UIView *)view pin:(UEDRefreshViewSubviewPin)pin offset:(CGFloat)offset {
    
    UEDRefreshViewSubviewPinModel *model = UEDRefreshViewSubviewPinModel.new;
    model.view = view;
    model.pin = pin;
    model.offset = offset;
    model.originalY = view.frame.origin.y;
    if (![self.subviewPins containsObject:model]) {
        [self.subviewPins addObject:model];
    }
}

@end
