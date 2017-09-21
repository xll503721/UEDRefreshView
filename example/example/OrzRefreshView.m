//
//  OrzRefreshView.m
//  TestUEDRefreshView
//
//  Created by xlL on 16/12/24.
//  Copyright © 2016年 UED. All rights reserved.
//

#import "OrzRefreshView.h"
#import "UEDRefreshView.h"

static const CGFloat kOrzRefreshViewFaceImageViewAnimationTimeInterval = 0.1;
static const CGFloat kOrzRefreshViewHeight = 68.0;

@interface OrzRefreshView ()<UEDRefreshViewProtocol>
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *handImageView;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageViewAnimation;
@property (weak, nonatomic) IBOutlet UIImageView *bodyImageView;

@property (nonatomic, strong) NSArray<UIImage *> *faceAnimationImages;
@property (nonatomic, strong) NSTimer *faceAnimationTimer;
@property (nonatomic, assign) NSInteger faceAnimationImagesIndex;

@end

@implementation OrzRefreshView

- (void)dealloc
{
//    NSLog(@"OrzRefreshView dealloc");
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.faceAnimationImagesIndex = 1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tipsLabel.center = CGPointMake(self.superview.frame.size.width / 2, self.tipsLabel.center.y);
    self.faceImageViewAnimation.center = CGPointMake(self.superview.frame.size.width / 2, self.faceImageViewAnimation.center.y);
    self.headerImageView.center = CGPointMake(self.superview.frame.size.width / 2, self.headerImageView.center.y);
    self.faceImageView.center = CGPointMake(self.superview.frame.size.width / 2, self.faceImageView.center.y);
    self.handImageView.center = CGPointMake(self.superview.frame.size.width / 2, self.handImageView.center.y);
    self.bodyImageView.center = CGPointMake(self.superview.frame.size.width / 2, self.bodyImageView.center.y);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if ([newSuperview isKindOfClass:[UEDRefreshView class]]) {
        [(UEDRefreshView *)newSuperview scrollPinView:self.tipsLabel pin:UEDRefreshViewSubviewPinTop offset:-30];
        [(UEDRefreshView *)newSuperview scrollPinView:self.handImageView pin:UEDRefreshViewSubviewPinBottom offset:0];
        [(UEDRefreshView *)newSuperview scrollPinView:self.headerImageView pin:UEDRefreshViewSubviewPinTop offset:-10];
        
        [(UEDRefreshView *)newSuperview setRefreshViewHeight:kOrzRefreshViewHeight];
    }
    
    if (!newSuperview) {
        [self.faceAnimationTimer invalidate];
    }
}

#pragma mark -  UEDRefreshViewProtocol
- (void)refreshView:(UEDRefreshView *)refreshView willChangeNextState:(UEDRefreshViewState)state height:(CGFloat)height {
    switch (state) {
        case UEDRefreshViewStateNormal:{
            
        }
            break;
        case UEDRefreshViewStatePulling:
            
            break;
        case UEDRefreshViewStateSpringbackToRefreshing: {
            self.tipsLabel.text = @"松手即可刷新";
            self.tipsLabel.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                self.tipsLabel.alpha = 1;
            }];
            self.faceImageView.image = [UIImage imageNamed:@"ued_refresh_control_face_pull_laugh"];
        }
            break;
        case UEDRefreshViewStateSpringbackToNormal: {
            if (height != kOrzRefreshViewHeight) {
                self.tipsLabel.text = @"下拉刷新";
                self.tipsLabel.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    self.tipsLabel.alpha = 1;
                }];
            }
            self.faceImageView.image = [UIImage imageNamed:@"ued_refresh_control_face_pull"];
        }
            break;
        case UEDRefreshViewStateRefreshing:{
            
        }
            break;
            
        default:
            break;
    }
}

- (void)refreshView:(UEDRefreshView *)refreshView didChangeState:(UEDRefreshViewState)state height:(CGFloat)height {
    switch (state) {
        case UEDRefreshViewStateNormal:{
            self.tipsLabel.text = @"下拉刷新";
            self.headerImageView.hidden = NO;
            self.faceImageView.hidden = NO;
            self.faceImageViewAnimation.hidden = YES;
            self.bodyImageView.hidden = YES;

            [self.faceAnimationTimer invalidate];
            self.faceAnimationImagesIndex = 1;
            self.faceImageViewAnimation.image = self.faceAnimationImages[self.faceAnimationImagesIndex];
        }
            break;
        case UEDRefreshViewStatePulling:
            
            break;
        case UEDRefreshViewStateSpringbackToRefreshing: {
            
        }
            break;
        case UEDRefreshViewStateSpringbackToNormal:
        
            break;
        case UEDRefreshViewStateRefreshing:{
            self.tipsLabel.text = @"正在卖力刷新中...";
            self.tipsLabel.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                self.tipsLabel.alpha = 1;
            }];
            self.headerImageView.hidden = YES;
            self.faceImageView.hidden = YES;
            self.faceImageViewAnimation.hidden = NO;
            self.bodyImageView.hidden = NO;
            
            [self.faceAnimationTimer invalidate];
            self.faceAnimationTimer = [NSTimer timerWithTimeInterval:kOrzRefreshViewFaceImageViewAnimationTimeInterval target:self selector:@selector(faceLoopAnimation) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.faceAnimationTimer forMode:NSRunLoopCommonModes];
        }
            break;
            
        default:
            break;
    }
}

- (void)faceLoopAnimation {
    
    if (self.faceAnimationImagesIndex == self.faceAnimationImages.count) {
        self.faceAnimationImagesIndex = 6;
    }
    
    self.faceImageViewAnimation.image = self.faceAnimationImages[self.faceAnimationImagesIndex];
    self.faceAnimationImagesIndex++;
}

#pragma mark - setter getter

- (NSArray <UIImage *>*)faceAnimationImages {
    if (!_faceAnimationImages) {
        _faceAnimationImages = @[[UIImage imageNamed:@"0"], [UIImage imageNamed:@"1"], [UIImage imageNamed:@"2"], [UIImage imageNamed:@"3"], [UIImage imageNamed:@"4"], [UIImage imageNamed:@"5"], [UIImage imageNamed:@"6"], [UIImage imageNamed:@"7"], [UIImage imageNamed:@"8"], [UIImage imageNamed:@"9"], [UIImage imageNamed:@"10"]];
    }
    return _faceAnimationImages;
}

@end
