#import <Foundation/Foundation.h>
#import <Intents/Intents.h>
#import <objc/runtime.h>

@implementation INPreferences (FixSiriCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(siriAuthorizationStatus),
            @selector(requestSiriAuthorization:),
            @selector(siriLanguageCode)
        };
        SEL replacements[] = {
            @selector(fix_siriAuthorizationStatus),
            @selector(fix_requestSiriAuthorization:),
            @selector(fix_siriLanguageCode)
        };

        for (int i = 0; i < 3; i++) {
            Method orig = class_getClassMethod(self, selectors[i]);
            Method swizzled = class_getClassMethod(self, replacements[i]);
            if (orig && swizzled) {
                method_exchangeImplementations(orig, swizzled);
            }
        }
    });
}

+ (INSiriAuthorizationStatus)fix_siriAuthorizationStatus {
    return INSiriAuthorizationStatusDenied;
}

+ (void)fix_requestSiriAuthorization:(void (^)(INSiriAuthorizationStatus))handler {
    if (handler) {
        handler(INSiriAuthorizationStatusDenied);
    }
}

+ (NSString *)fix_siriLanguageCode {
    return @"en-US";
}

@end
