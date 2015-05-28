#import "JCNotificationBanner.h"

@implementation JCNotificationBanner

- (JCNotificationBanner*) initWithTitle:(NSString*)title
                                message:(NSString*)message
                            andURLImage:(NSString*)URLImage
                             tapHandler:(JCNotificationBannerTapHandlingBlock)tapHandler {
  
    return [self initWithTitle:title message:message andURLImage:URLImage timeout:5.0 tapHandler:tapHandler];
}

- (JCNotificationBanner*) initWithTitle:(NSString*)title
                                message:(NSString*)message
                            andURLImage:(NSString*)URLImage
                                timeout:(NSTimeInterval)timeout
                             tapHandler:(JCNotificationBannerTapHandlingBlock)tapHandler {
  
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.URLImage = URLImage;
        self.timeout = timeout;
        self.tapHandler = tapHandler;
    }
    return self;
}

@end
