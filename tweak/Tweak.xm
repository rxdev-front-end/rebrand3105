#import <UIKit/UIKit.h>

%hook NSBundle
- (NSString *)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return @"MinhaApp";
    return %orig;
}
%end

%hook UIWindow
- (void)makeKeyAndVisible {
    %orig;
    self.tintColor = [UIColor colorWithRed:0.10 green:0.55 blue:0.90 alpha:1.0];
}
%end
