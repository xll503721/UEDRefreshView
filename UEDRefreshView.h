//
//  UEDRefreshView.h
//  TestUEDRefreshView
//
//  Created by xlL on 16/12/24.
//  Copyright © 2016年 UED. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 ==================State Transform==================
 */
/*
 UEDRefreshViewStateNormal<-------------------------
            |                                      |
            v                                      |
 UEDRefreshViewStatePulling                        |
            |                                      |
            v                                      |
 UEDRefreshViewStateSpringbackToRefreshing         |
            |                                      |
            v                                      |
 UEDRefreshViewStateRefreshing                     |
            |                                      |
            v                                      |
 UEDRefreshViewStateSpringbackToNormal -------------
 */

@class UEDRefreshView;

typedef enum : NSUInteger {
    UEDRefreshViewStateNormal,                  //initial state, or no action, for static state
    UEDRefreshViewStatePulling,                 //when user finger dragging down the scrollView
    UEDRefreshViewStateSpringbackToRefreshing,  //it is going to refreshing, will turn to UEDRefreshViewStateRefreshing
    UEDRefreshViewStateRefreshing,              //now is refreshing, scrollView offset stop on UEDRefreshView's 'refreshViewHeight'
    UEDRefreshViewStateSpringbackToNormal,      //it is going to the UEDRefreshViewStateNormal
} UEDRefreshViewState;

typedef enum : NSUInteger {
    UEDRefreshViewSubviewPinTop,
    UEDRefreshViewSubviewPinBottom,
} UEDRefreshViewSubviewPin;

@protocol UEDRefreshViewProtocol <NSObject>

@optional
/**
    if current state is UEDRefreshViewStateNormal,
    so it will change to next state is UEDRefreshViewStatePulling,
    see about state transform in above(State Transform)
 */
- (void)refreshView:(UEDRefreshView *)refreshView willChangeNextState:(UEDRefreshViewState)state height:(CGFloat)height;

/**
 'UEDRefreshViewState' will change, before set the new state
 */
- (BOOL)refreshView:(UEDRefreshView *)refreshView willChangeState:(UEDRefreshViewState)state height:(CGFloat)height;

/**
 'UEDRefreshViewState' did change, after set the new state
 */
- (void)refreshView:(UEDRefreshView *)refreshView didChangeState:(UEDRefreshViewState)state height:(CGFloat)height;

@end

@interface UEDRefreshView : UIControl

@property (nonatomic, readonly) UEDRefreshViewState refreshState;
@property (nonatomic, assign) CGFloat refreshViewHeight;

- (instancetype)initWithContentViewXibName:(NSString *)xibName;
- (void)beginRefreshing;
- (void)endRefreshing;

/**
    when you need to layout view in user finger dragging down the scrollView, you can use this method
 
    1. after set 'UEDRefreshViewSubviewPinTop', view will scroll, when scrollView did scroll.
       'offset' set the new frame.origin.y for the view, and the view scroll when scrollView did scroll, then stop on view's original frame.origin.y.
    2. after set 'UEDRefreshViewSubviewPinBottom', view will scroll, when scrollView did scroll.
       'offset' set the distance between view bottom and UEDRefreshView bottom.
 */
- (void)scrollPinView:(UIView *)view pin:(UEDRefreshViewSubviewPin)pin offset:(CGFloat)offset;

@end
