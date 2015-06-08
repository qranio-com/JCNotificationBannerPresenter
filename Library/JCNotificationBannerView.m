#import "JCNotificationBannerView.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

const CGFloat kJCNotificationBannerViewOutlineWidth = 2.0;
const CGFloat kJCNotificationBannerViewMarginX = 14.0;
const CGFloat kJCNotificationBannerViewMarginY = 5.0;
const CGFloat kJCNotificationBannerViewHorizontalSpace = 8.0;

@interface JCNotificationBannerView () {
    BOOL isPresented;
    NSObject* isPresentedMutex;
}

@property (nonatomic, copy) CloseBannerBlock closeBanner;

- (void) handleSingleTap:(UIGestureRecognizer*)gestureRecognizer;

@end

@implementation JCNotificationBannerView

- (id) initWithNotification:(JCNotificationBanner*)notification {
    self = [super init];
    if (self) {
        isPresentedMutex = [NSObject new];
        self.backgroundColor = [UIColor clearColor];
        
        // Image
        self.iconImageView = [UIImageView new];
        [self addSubview:self.iconImageView];
        
        // Title
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.titleLabel.textColor = [UIColor lightTextColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        // Message
        self.messageLabel = [UILabel new];
        self.messageLabel.font = [UIFont systemFontOfSize:14];
        self.messageLabel.textColor = [UIColor lightTextColor];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.numberOfLines = 0;
        [self addSubview:self.messageLabel];

        UITapGestureRecognizer* tapRecognizer;
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:tapRecognizer];
        
        UIPanGestureRecognizer *panRecognizer;
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestures:)];

        [self addGestureRecognizer:panRecognizer];

        self.notificationBanner = notification;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [panGestureRecognizer velocityInView:self];
        CGPoint translateInView = [panGestureRecognizer translationInView:self];
        BOOL v = fabs(velocity.y) > fabs(velocity.x);
        BOOL t = translateInView.y < 0;
        return v && t;
    }
    return  [super gestureRecognizerShouldBegin:panGestureRecognizer];
}

- (void) layoutSubviews {
    if (!(self.frame.size.width > 0)) { return; }

    BOOL hasTitle = self.notificationBanner ? (self.notificationBanner.title.length > 0) : NO;
    BOOL hasImage = self.notificationBanner ? (self.notificationBanner.URLImage != nil) : NO;

    CGFloat borderY = kJCNotificationBannerViewOutlineWidth + kJCNotificationBannerViewMarginY;
    CGFloat borderX = kJCNotificationBannerViewOutlineWidth + kJCNotificationBannerViewMarginX;
    CGFloat currentX = borderX;
    CGFloat currentY = borderY;
    CGFloat contentWidth = self.frame.size.width - (borderX * 2.0);
    CGFloat contentHeight = self.frame.size.height;

    currentY += 2.0;
    
    if (hasImage) {
        self.iconImageView.frame = CGRectMake(currentX, ((contentHeight/2)-20), 40, 40);
        [self.iconImageView.layer setCornerRadius:20];
        [self.iconImageView.layer setMasksToBounds:YES];
    }
    
    if (hasTitle) {
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + kJCNotificationBannerViewHorizontalSpace, currentY, (contentWidth - CGRectGetMaxX(self.iconImageView.frame)), 22.0);
        currentY += 22.0;
    }
    self.messageLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), currentY, self.titleLabel.frame.size.width, (self.frame.size.height - borderY) - currentY);
    [self.messageLabel sizeToFit];
    CGRect messageFrame = self.messageLabel.frame;
    CGFloat spillY = (currentY + messageFrame.size.height + kJCNotificationBannerViewMarginY) - self.frame.size.height;
    if (spillY > 0.0) {
        messageFrame.size.height -= spillY;
        self.messageLabel.frame = messageFrame;
    }
}

- (void) setNotificationBanner:(JCNotificationBanner*)notification {
    _notificationBanner = notification;
    self.titleLabel.text = notification.title;
    self.messageLabel.text = notification.message;
    [self.iconImageView setImageWithURL:[NSURL URLWithString:notification.URLImage] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}

- (void) handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.notificationBanner && self.notificationBanner.tapHandler) {
        self.notificationBanner.tapHandler();
    }
}

- (void) handlePanGestures:(UIGestureRecognizer *)gestureRecognizer {
    if (self.closeBanner) {
        self.closeBanner();
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