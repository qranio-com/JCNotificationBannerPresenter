#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "JCNotificationBanner.h"

typedef void(^CloseBannerBlock)(void);

@interface JCNotificationBannerView : UIView

@property (nonatomic, strong) JCNotificationBanner* notificationBanner;
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* messageLabel;

- (id) initWithNotification:(JCNotificationBanner*)notification;
- (BOOL) getCurrentPresentingStateAndAtomicallySetPresentingState:(BOOL)state;

- (void)setCloseBanner:(CloseBannerBlock)completion;

@end
