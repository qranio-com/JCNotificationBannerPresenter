#import <Foundation/Foundation.h>

typedef void (^JCNotificationBannerTapHandlingBlock)();

@interface JCNotificationBanner : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* URLImage;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, copy) JCNotificationBannerTapHandlingBlock tapHandler;

- (JCNotificationBanner*) initWithTitle:(NSString*)title
                                message:(NSString*)message
                            andURLImage:(NSString*)URLImage
                             tapHandler:(JCNotificationBannerTapHandlingBlock)tapHandler;

- (JCNotificationBanner*) initWithTitle:(NSString*)title
                                message:(NSString*)message
                            andURLImage:(NSString*)URLImage
                                timeout:(NSTimeInterval)timeout
                             tapHandler:(JCNotificationBannerTapHandlingBlock)tapHandler;
@end
