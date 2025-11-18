#import "NotificationManager.h"
#import <UserNotifications/UserNotifications.h>

@implementation NotificationManager

+ (instancetype)shared {
    static NotificationManager *m;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ m = [NotificationManager new]; });
    return m;
}

- (void)sendLocalNotification:(NSString *)text {

    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Bildirim";
    content.body  = text;
    content.sound = [UNNotificationSound defaultSound];

    UNTimeIntervalNotificationTrigger *trigger =
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

    UNNotificationRequest *req =
        [UNNotificationRequest requestWithIdentifier:@"locnotif" content:content trigger:trigger];

    [[UNUserNotificationCenter currentNotificationCenter]
     addNotificationRequest:req withCompletionHandler:nil];
}

@end
