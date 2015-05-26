#import "JCNotificationBannerView.h"

const CGFloat kJCNotificationBannerViewOutlineWidth = 2.0;
const CGFloat kJCNotificationBannerViewMarginX = 14.0;
const CGFloat kJCNotificationBannerViewMarginY = 5.0;
const CGFloat kJCNotificationBannerViewHorizontalSpace = 8.0;

@interface JCNotificationBannerView () {
  BOOL isPresented;
  NSObject* isPresentedMutex;
}

- (void) handleSingleTap:(UIGestureRecognizer*)gestureRecognizer;

@end

@implementation JCNotificationBannerView

@synthesize notificationBanner;
@synthesize iconImageView;
@synthesize titleLabel;
@synthesize messageLabel;

- (id) initWithNotification:(JCNotificationBanner*)notification {
  self = [super init];
  if (self) {
    isPresentedMutex = [NSObject new];

    self.backgroundColor = [UIColor clearColor];
    self.iconImageView = [UIImageView new];
    [self addSubview:self.iconImageView];
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor lightTextColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];
    self.messageLabel = [UILabel new];
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textColor = [UIColor lightTextColor];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.numberOfLines = 0;
    [self addSubview:self.messageLabel];

    UITapGestureRecognizer* tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:tapRecognizer];

    self.notificationBanner = notification;
  }
  return self;
}

- (void) layoutSubviews {
    if (!(self.frame.size.width > 0)) { return; }

    BOOL hasTitle = notificationBanner ? (notificationBanner.title.length > 0) : NO;
    BOOL hasImage = notificationBanner ? (notificationBanner.image != nil) : NO;

    CGFloat borderY = kJCNotificationBannerViewOutlineWidth + kJCNotificationBannerViewMarginY;
    CGFloat borderX = kJCNotificationBannerViewOutlineWidth + kJCNotificationBannerViewMarginX;
    CGFloat currentX = borderX;
    CGFloat currentY = borderY;
    CGFloat contentWidth = self.frame.size.width - (borderX * 2.0);
    CGFloat contentHeight = self.frame.size.height;

    currentY += 2.0;
    
    if (hasImage) {
        self.iconImageView.frame = CGRectMake(currentX, ((contentHeight/2)-self.notificationBanner.image.size.height/2), self.notificationBanner.image.size.width, self.notificationBanner.image.size.height);
    }
    
    if (hasTitle) {
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + kJCNotificationBannerViewHorizontalSpace, currentY, contentWidth, 22.0);
        currentY += 22.0;
    }
    self.messageLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), currentY, contentWidth, (self.frame.size.height - borderY) - currentY);
    [self.messageLabel sizeToFit];
    CGRect messageFrame = self.messageLabel.frame;
    CGFloat spillY = (currentY + messageFrame.size.height + kJCNotificationBannerViewMarginY) - self.frame.size.height;
    if (spillY > 0.0) {
        messageFrame.size.height -= spillY;
        self.messageLabel.frame = messageFrame;
    }
}

- (void) setNotificationBanner:(JCNotificationBanner*)notification {
    notificationBanner = notification;

    self.titleLabel.text = notification.title;
    self.messageLabel.text = notification.message;
    self.iconImageView.image = notificationBanner.image;
}

- (void) handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (notificationBanner && notificationBanner.tapHandler) {
        notificationBanner.tapHandler();
    }
}

- (BOOL) getCurrentPresentingStateAndAtomicallySetPresentingState:(BOOL)state {
    @synchronized(isPresentedMutex) {
        BOOL originalState = isPresented;
        isPresented = state;
        return originalState;
    }
}

@end
