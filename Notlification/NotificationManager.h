#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject
+ (instancetype)shared;
- (void)sendLocalNotification:(NSString *)text;
@end
