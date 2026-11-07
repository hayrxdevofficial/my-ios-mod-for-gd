#include <Geode/Geode.hpp>
#include <Geode/modify/MenuLayer.hpp>
#include <Geode/modify/PlayLayer.hpp>

using namespace geode::prelude;

// ============================================================
// 1. КАРКАС МЕНЮ (Кнопка в главном меню)
// ============================================================
class $modify(MyMenuLayer, MenuLayer) {
    bool init() {
        if (!MenuLayer::init()) return false;

        // Создаём кнопку. Можно использовать любую иконку из игры.
        auto myButton = CCMenuItemSpriteExtra::create(
            CCSprite::createWithSpriteFrameName("GJ_likeBtn_001.png"),
            this,
            menu_selector(MyMenuLayer::onMyMenuButton)
        );

        // Добавляем кнопку в нижнее меню игры (стандартное место для кнопок модов)
        if (auto menu = this->getChildByID("bottom-menu")) {
            menu->addChild(myButton);
        }

        return true;
    }

    void onMyMenuButton(CCObject* sender) {
        // Здесь будет открываться ваше кастомное меню.
        // Пока для теста просто показываем всплывающее окно.
        FLAlertLayer::create(
            "My Mod Menu",
            "Noclip & Icon Hack are ready!\nBot integration coming soon...",
            "OK"
        )->show();
    }
};

// ============================================================
// 2. NOCLIP (Собственная реализация)
// ============================================================
// Хукаем функцию, которая убивает игрока. Если noclip включён в настройках мода,
// мы просто не вызываем оригинальную функцию, и игрок остаётся жив.
class $modify(MyPlayLayer, PlayLayer) {
    void destroyPlayer(PlayerObject* player, GameObject* object) {
        // Проверяем настройку мода. Если она включена (true), выходим из функции.
        if (Mod::get()->getSettingValue<bool>("noclip-enabled")) {
            return;
        }
        // Если noclip выключен, вызываем оригинальную функцию игры (игрок умирает).
        PlayLayer::destroyPlayer(player, object);
    }
};

// ============================================================
// 3. HACK ICONS (Разблокировка иконок)
// ============================================================
// Это отдельная функция, которую вы можете вызывать из своего меню.
// Она напрямую обращается к менеджеру статистики игры и устанавливает
// все флаги иконок в значение "разблокировано".
void unlockAllIcons() {
    auto statsManager = GameStatsManager::sharedState();
    
    // Проходимся по всем иконкам, цветам и следам.
    // В Geode SDK есть перечисления для типов иконок.
    // Этот код — концептуальный пример. В реальном моде нужно будет
    // уточнить точные ID или перечисления в зависимости от версии GD.
    for (int iconID = 1; iconID <= 100; iconID++) { // Примерный диапазон
        statsManager->m_bIconUnlocked[iconID] = true; // Упрощённо
    }
    
    // После изменения данных нужно сохранить их.
    statsManager->save();
    
    FLAlertLayer::create("Success", "All icons unlocked!", "OK")->show();
}

// ============================================================
// 4. ИНТЕГРАЦИЯ БОТА (xdBot)
// ============================================================
// xdBot — это отдельный мод. Вы не можете "встроить" его код напрямую,
// но можете взаимодействовать с ним, если он предоставляет API.
// В большинстве случаев вам нужно будет либо:
// 1. Попросить пользователя установить xdBot отдельно.
// 2. Найти в коде xdBot публичные функции для запуска/остановки макроса
//    и вызывать их из своего мода (если такие функции экспортированы).
//
// Примерная заготовка для вызова (псевдокод, зависит от API xdBot):
/*
void startXDBotMacro() {
    // Здесь должен быть вызов API xdBot, например:
    // xdBotAPI::startPlayback("my_macro.gdr");
    FLAlertLayer::create("Bot", "Please install xdBot to use bot features.", "OK")->show();
}
*/
