#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

// ============================================================
// ГЛОБАЛЬНОЕ СОСТОЯНИЕ
// ============================================================
static BOOL gNoclipEnabled = NO;

// ============================================================
// БЕЗОПАСНОЕ ПОЛУЧЕНИЕ TOP VIEW CONTROLLER (без deprecation)
// ============================================================
static UIViewController *GDTopViewController(void) {
    UIWindow *keyWin = nil;
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow) { keyWin = w; break; }
    }
    if (!keyWin) keyWin = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *vc = keyWin.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

// ============================================================
// HELPER: логика меню
// ============================================================
@interface GDModHelper : NSObject
+ (instancetype)shared;
- (void)showMenu;
- (void)unlockAllIcons;
@end

@implementation GDModHelper

+ (instancetype)shared {
    static GDModHelper *s;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [GDModHelper new]; });
    return s;
}

- (void)showMenu {
    UIViewController *vc = GDTopViewController();
    if (!vc) return;

    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"My Mod Menu"
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *nTitle = gNoclipEnabled ? @"Disable Noclip" : @"Enable Noclip";
    [menu addAction:[UIAlertAction actionWithTitle:nTitle
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *a) {
        gNoclipEnabled = !gNoclipEnabled;
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Unlock All Icons"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *a) {
        [[GDModHelper shared] unlockAllIcons];
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];

    // Поддержка iPad (popover)
    menu.popoverPresentationController.sourceView = vc.view;
    menu.popoverPresentationController.sourceRect =
        CGRectMake(vc.view.bounds.size.width / 2, vc.view.bounds.size.height / 2, 1, 1);
    menu.popoverPresentationController.permittedArrowDirections = 0;

    [vc presentViewController:menu animated:YES completion:nil];
}

- (void)unlockAllIcons {
    Class cls = NSClassFromString(@"GameStatsManager");
    if (!cls) return;

    // Вызываем sharedState через objc_msgSend (компилятор не знает этот класс)
    SEL sharedSel = NSSelectorFromString(@"sharedState");
    if (![cls respondsToSelector:sharedSel]) return;
    id mgr = ((id (*)(id, SEL))objc_msgSend)(cls, sharedSel);
    if (!mgr) return;

    // Пробуем известные названия методов — какое-то сработает
    NSArray *methodNames = @[@"unlockAllIcons", @"unlockAll", @"unlockAllIconsAndColors"];
    BOOL called = NO;
    for (NSString *m in methodNames) {
        SEL s = NSSelectorFromString(m);
        if ([mgr respondsToSelector:s]) {
            ((void (*)(id, SEL))objc_msgSend)(mgr, s);
            called = YES;
            break;
        }
    }

    // Сохраняем прогресс
    SEL saveSel = NSSelectorFromString(@"save");
    if ([mgr respondsToSelector:saveSel]) {
        ((void (*)(id, SEL))objc_msgSend)(mgr, saveSel);
    }

    // Уведомление пользователю
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *vc = GDTopViewController();
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Icons"
                                                                    message:(called ? @"All icons unlocked!" : @"Метод не найден. Проверьте версию GD.")
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [a addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
        [vc presentViewController:a animated:YES completion:nil];
    });
}

@end

// ============================================================
// HOOK: NOCLIP
// ============================================================
%hook PlayLayer

- (void)destroyPlayer:(id)player withObject:(id)object {
    if (gNoclipEnabled) return;
    %orig;
}

%end

// ============================================================
// HOOK: КНОПКА "My Menu" поверх главного меню
// ============================================================
%hook MenuLayer

- (BOOL)init {
    BOOL ret = %orig;
    if (ret) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *vc = GDTopViewController();
            if (!vc) return;
            if ([vc.view viewWithTag:99887766]) return; // защита от дублей

            UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
            b.tag = 99887766;
            [b setTitle:@"My Menu" forState:UIControlStateNormal];
            [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            b.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.85];
            b.layer.cornerRadius = 8.0;
            b.frame = CGRectMake(20, 80, 120, 44);
            [b addTarget:[GDModHelper shared]
                  action:@selector(showMenu)
        forControlEvents:UIControlEventTouchUpInside];
            [vc.view addSubview:b];
        });
    }
    return ret;
}

%end
