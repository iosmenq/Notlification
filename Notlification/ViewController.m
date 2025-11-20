/*
* ViewController.m
*
* codded by iosmen (c) 2025
*
* send notifications via all user applications (jailbreak required!!!)
*/



#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    [self scanUserApps];
}


- (void)scanUserApps {
    NSMutableArray *results = [NSMutableArray array];

    NSArray *appsDirs = @[@"/var/containers/Bundle/Application"];
    NSFileManager *fm = [NSFileManager defaultManager];

    for (NSString *dir in appsDirs) {
        NSArray *uuidDirs = [fm contentsOfDirectoryAtPath:dir error:nil];
        for (NSString *uuidDir in uuidDirs) {
            NSString *appPath = [dir stringByAppendingPathComponent:uuidDir];
            NSArray *contents = [fm contentsOfDirectoryAtPath:appPath error:nil];
            for (NSString *file in contents) {
                if ([file hasSuffix:@".app"]) {
                    NSString *fullPath = [appPath stringByAppendingPathComponent:file];
                    
                    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[fullPath stringByAppendingPathComponent:@"Info.plist"]];
                    NSString *appName = plist[@"CFBundleDisplayName"] ?: plist[@"CFBundleName"];
                    if (appName) {
                        [results addObject:@{@"name": appName, @"path": fullPath}];
                    }
                }
            }
        }
    }

    self.apps = results;
    [self.tableView reloadData];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.apps[indexPath.row][@"name"];
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *appInfo = self.apps[indexPath.row];
    NSString *appName = appInfo[@"name"];
    NSString *appPath = appInfo[@"path"];

    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mesaj Gönder"
                                                                   message:[NSString stringWithFormat:@"'%@' için mesaj yaz", appName]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Mesajınızı buraya yazın";
    }];

    UIAlertAction *sendAction = [UIAlertAction actionWithTitle:@"Gönder"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        NSString *customMessage = alert.textFields.firstObject.text;
        if (customMessage.length == 0) customMessage = @"(Boş mesaj)";

        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = appName;
        content.body = customMessage;
        content.sound = [UNNotificationSound defaultSound];

        
        NSString *iconName = nil;
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[appPath stringByAppendingPathComponent:@"Info.plist"]];
        NSDictionary *icons = plist[@"CFBundleIcons"];
        NSDictionary *primaryIcon = icons[@"CFBundlePrimaryIcon"];
        NSArray *iconFiles = primaryIcon[@"CFBundleIconFiles"];
        if (iconFiles.count > 0) {
            iconName = iconFiles.lastObject;
        }

        if (iconName) {
            NSString *iconPath = [appPath stringByAppendingPathComponent:iconName];
            content.launchImageName = iconPath; 
        }

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"localnotif"
                                                                              content:content
                                                                              trigger:trigger];

        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                               withCompletionHandler:^(NSError * _Nullable error) {
            if (error) NSLog(@"Bildirim hatası: %@", error);
        }];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"İptal" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:sendAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

