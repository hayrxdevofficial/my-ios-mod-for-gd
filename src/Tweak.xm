// src/Tweak.xm
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// ============================================================
// 1. NOCLIP (Собственная реализация)
// ============================================================
// Переменная для хранения состояния noclip
static BOOL noclipEnabled = NO;

// Хукаем класс PlayLayer (или аналогичный в GD)
%hook PlayLayer

// Перехватываем метод, который убивает игрока при столкновении
- (void)destroyPlayer:(id)player withObject:(id)object {
    // Если noclip включён — просто выходим, не вызывая оригинальный метод
    if (noclipEnabled) {
        return;
    }
    // Если выключен — вызываем оригинальную реализацию (игрок умирает)
    %orig;
}

%end

// ============================================================
// 2. HACK ICONS (Разблокировка иконок)
// ============================================================
// Функция для разблокировки всех иконок
void unlockAllIcons() {
    // Получаем доступ к менеджеру статистики игры
    // В Geometry Dash это обычно GameStatsManager
    Class statsManagerClass = NSClassFromString(@"GameStatsManager");
    if (!statsManagerClass) return;
    
    id statsManager = [statsManagerClass sharedState];
    if (!statsManager) return;
    
    // Проходимся по всем возможным ID иконок (примерный диапазон)
    // В реальном моде нужно уточнить точные поля в зависимости от версии GD
    for (int i = 1; i <= 100; i++) {
        // Устанавливаем флаг разблокировки для каждой иконки
        // Имена полей могут отличаться: m_bIconUnlocked, iconUnlocked и т.д.
        // Это концептуальный пример — вам нужно будет найти точные имена в заголовках игры
        @try {
            [statsManager setValue:@YES forKey:[NSString stringWithFormat:@"iconUnlocked_%d", i]];
        } @catch (NSException *e) {
            // Игнорируем ошибки для несуществующих ключей
        }
    }
    
    // Сохраняем изменения
    if ([statsManager respondsToSelector:@selector(save)]) {
        [statsManager performSelector:@selector(save)];
    }
    
    // Показываем уведомление об успехе
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController 
            alertControllerWithTitle:@"Success" 
            message:@"All icons unlocked!" 
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

// ============================================================
// 3. МЕНЮ (Кнопка в главном меню)
// ============================================================
// Хукаем класс MenuLayer (главное меню игры)
%hook MenuLayer

- (BOOL)init {
    if (!%orig) return NO;
    
    // Создаём кнопку для открытия нашего меню
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [myButton setTitle:@"My Menu" forState:UIControlStateNormal];
    [myButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [myButton setBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:0.8]];
    myButton.layer.cornerRadius = 8.0;
    myButton.frame = CGRectMake(20, 80, 100, 40); // Позиция на экране
    
    [myButton addTarget:self action:@selector(onMyMenuButton) forControlEvents:UIControlEventTouchUpInside];
    
    // Добавляем кнопку на view игры
    [self addSubview:myButton];
    
    return YES;
}

// Обработчик нажатия на кнопку
- (void)onMyMenuButton {
    // Создаём простое меню с переключателями
    UIAlertController *menu = [UIAlertController 
        alertControllerWithTitle:@"My Mod Menu" 
        message:@"Select an option:" 
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Переключатель Noclip
    NSString *noclipTitle = noclipEnabled ? @"Disable Noclip" : @"Enable Noclip";
    [menu addAction:[UIAlertAction actionWithTitle:noclipTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        noclipEnabled = !noclipEnabled;
        // Показываем подтверждение
        UIAlertController *confirm = [UIAlertController 
            alertControllerWithTitle:@"Noclip" 
            message:noclipEnabled ? @"Noclip enabled" : @"Noclip disabled" 
            preferredStyle:UIAlertControllerStyleAlert];
        [confirm addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:confirm animated:YES completion:nil];
    }]];
    
    // Кнопка Hack Icons
    [menu addAction:[UIAlertAction actionWithTitle:@"Unlock All Icons" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        unlockAllIcons();
    }]];
    
    // Кнопка отмены
    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    // Показываем меню
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:menu animated:YES completion:nil];
}

%end
