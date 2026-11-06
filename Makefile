# Архитектура для iPhone X
ARCHS = arm64

# Указываем, что это твик для iOS
TARGET = iphone:clang:latest:14.0

# Включаем стандартные настройки Theos
include $(THEOS)/makefiles/common.mk

# Имя нашего твика
TWEAK_NAME = MyHack

# Файлы, которые нужно скомпилировать
MyHack_FILES = Tweak.xm

# Фреймворки, которые использует твик (UIKit нужен для меню)
MyHack_FRAMEWORKS = UIKit Foundation

# Включаем ARC (автоматическое управление памятью)
MyHack_CFLAGS = -fobjc-arc

# Подключаем стандартные правила сборки для твиков
include $(THEOS_MAKE_PATH)/tweak.mk
