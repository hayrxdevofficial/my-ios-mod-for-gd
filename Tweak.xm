#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// --- Вспомогательная функция для получения активного окна (фикс ошибки) ---
UIViewController *getRootViewController() {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                // Перебираем окна, чтобы найти главное (для совместимости с iOS 14)
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }
    } else {
        // Для старых iOS (ниже 13)
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        keyWindow = [UIApplication sharedApplication].keyWindow;
        #pragma clang diagnostic pop
    }
    return keyWindow.rootViewController;
}

// --- 1. Логика для Auto-Bot ---
void performAutoBot(id self, SEL _cmd) {
    // Здесь будет логика бота (пока пусто)
}

// --- 2. Плавающее меню ---
@interface FloatingMenu : NSObject
+ (void)show;
@end

@implementation FloatingMenu

+ (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            keyWindow = window;
                            break;
                        }
                    }
                }
            }
        } else {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            keyWindow = [UIApplication sharedApplication].keyWindow;
            #pragma clang diagnostic pop
        }
        
        if (!keyWindow) return;
        
        CGFloat buttonSize = 50.0;
        UIButton *floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingButton.frame = CGRectMake(keyWindow.bounds.size.width - buttonSize - 20,
                                          keyWindow.bounds.size.height - buttonSize - 80,
                                          buttonSize, buttonSize);
        floatingButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:0.9];
        floatingButton.layer.cornerRadius = buttonSize / 2;
        floatingButton.layer.shadowColor = [UIColor blackColor].CGColor;
        floatingButton.layer.shadowOpacity = 0.5;
        floatingButton.layer.shadowOffset = CGSizeMake(0, 2);
        [floatingButton setTitle:@"⚙️" forState:UIControlStateNormal];
        floatingButton.titleLabel.font = [UIFont systemFontOfSize:24];
        
        [floatingButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        [keyWindow addSubview:floatingButton];
    });
}

+ (void)openMenu:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Меню чита"
                                                                   message:@"Управление функциями"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Вкл/Выкл Auto-Bot" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"[Чит] Auto-Bot переключен");
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Вкл/Выкл Noclip" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"[Чит] Noclip переключен");
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *rootVC = getRootViewController();
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

@end


// --- 3. Внедрение (хуки) ---
%hook PlayLayer

- (void)postUpdate:(float)dt {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FloatingMenu show];
    });
}

%end

%hook PlayerObject

- (void)playerDestroyed {
    // Если Noclip включен, не вызываем оригинальную функцию
    // if (noclipEnabled) return;
    %orig;
}

%end
