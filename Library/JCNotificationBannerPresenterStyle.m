#import "JCNotificationBannerPresenterStyle.h"
#import "JCNotificationBannerPresenter_Private.h"
#import "JCNotificationBannerViewStyle.h"
#import "JCNotificationBannerViewController.h"
#import "dispatch_cancelable_block.h"

@interface JCNotificationBannerPresenterStyle()

@property (nonatomic, strong) JCNotificationBannerViewStyle *banner;
@property (nonatomic, strong) UIView* containerView;

@end

@implementation JCNotificationBannerPresenterStyle

- (id) init {
  if (self = [super init]) {
    self.bannerHeight = 68.0;
  }
  return self;
}

- (void) presentNotification:(JCNotificationBanner*)notification inWindow:(JCNotificationBannerWindow*)window finished:(JCNotificationBannerPresenterFinishedBlock)finished {
    self.banner = (JCNotificationBannerViewStyle*)[self newBannerViewForNotification:notification];

    JCNotificationBannerViewController* bannerViewController = [JCNotificationBannerViewController new];
    window.rootViewController = bannerViewController;
    UIView* originalControllerView = bannerViewController.view;

    self.containerView = [self newContainerViewForNotification:notification];
    [self.containerView addSubview:self.banner];
    bannerViewController.view = self.containerView;

    window.bannerView = self.banner;

    self.containerView.bounds = originalControllerView.bounds;
    self.containerView.transform = originalControllerView.transform;
    [self.banner getCurrentPresentingStateAndAtomicallySetPresentingState:YES];

    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    // Make the banner fill the width of the screen, minus any requested margins,
    // up to self.bannerMaxWidth.
    CGSize bannerSize = CGSizeMake(originalControllerView.bounds.size.width, self.bannerHeight);
    
    CGFloat x = 0;
    // Position the banner offscreen vertically.
    CGFloat y = -self.bannerHeight;

#ifdef __IPHONE_7_0
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    BOOL accountForStatusBarHeight = ([[UIDevice currentDevice].systemVersion intValue] < 7);
#else
    // We're building for a pre-iOS7 base SDK.
    BOOL accountForStatusBarHeight = YES;
#endif
#else
    // We don't even have access to the iOS 7 availability constants.
    BOOL accountForStatusBarHeight = YES;
#endif
    if (accountForStatusBarHeight) {
        y -= (MIN(statusBarSize.width, statusBarSize.height));
    }

    self.banner.frame = CGRectMake(x, y, bannerSize.width, bannerSize.height);

    JCNotificationBannerTapHandlingBlock originalTapHandler = self.banner.notificationBanner.tapHandler;
    JCNotificationBannerTapHandlingBlock wrappingTapHandler = ^{
        if ([self.banner getCurrentPresentingStateAndAtomicallySetPresentingState:NO]) {
            if (originalTapHandler) {
                originalTapHandler();
            }

            [self.banner removeFromSuperview];
            finished();
            // Break the retain cycle
            notification.tapHandler = nil;
        }
    };
    self.banner.notificationBanner.tapHandler = wrappingTapHandler;

    // Slide it down while fading it in.
    self.banner.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = CGRectOffset(self.banner.frame, 0, self.banner.frame.size.height);
        self.banner.frame = newFrame;
        self.banner.alpha = 0.9;
    } completion:^(BOOL finished) {
        // Empty.
    }];


    // On timeout, slide it up while fading it out.
    if (notification.timeout > 0.0) {
        dispatch_cancelable_block_t block = dispatch_after_delay(notification.timeout, ^{
            [self closeBannerAnimationWithNotification:notification AndFinished:finished];
        });
        
        typeof(self) __weak weakSelf = self;
        [self.banner setCloseBanner:^() {
            [weakSelf closeBannerAnimationWithNotification:notification AndFinished:finished];
            block(YES);
        }];
    }
}

#pragma mark - Animations

- (void)closeBannerAnimationWithNotification:(JCNotificationBanner*)notification AndFinished:(JCNotificationBannerPresenterFinishedBlock)finished{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.banner.frame = CGRectOffset(self.banner.frame, 0, -self.banner.frame.size.height);
        self.banner.alpha = 0;
    } completion:^(BOOL didFinish) {
        if ([self.banner getCurrentPresentingStateAndAtomicallySetPresentingState:NO]) {
            [self.banner removeFromSuperview];
            [self.containerView removeFromSuperview];
            if (finished) {
                finished();
            }
            // Break the retain cycle
            notification.tapHandler = nil;
        }
    }];
}

#pragma mark - View helpers

- (JCNotificationBannerWindow*) newWindow {
  JCNotificationBannerWindow* window = [super newWindow];
  window.windowLevel = UIWindowLevelStatusBar;
  return window;
}

- (UIView*) newContainerViewForNotification:(JCNotificationBanner*)notification {
  UIView* view = [super newContainerViewForNotification:notification];
  view.autoresizesSubviews = YES;
  return view;
}

- (JCNotificationBannerView*) newBannerViewForNotification:(JCNotificationBanner*)notification {
  JCNotificationBannerViewStyle* view = [[JCNotificationBannerViewStyle alloc] initWithNotification:notification];
  view.userInteractionEnabled = YES;
  view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
  | UIViewAutoresizingFlexibleLeftMargin
  | UIViewAutoresizingFlexibleRightMargin
  | UIViewAutoresizingFlexibleWidth;
  return view;
}

@end
