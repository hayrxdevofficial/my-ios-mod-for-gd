# Указываем архитектуру процессора (arm64 подходит для iPhone X и всех современных устройств)
ARCHS = arm64

# Указываем целевую платформу. 
# 14.0 — минимальная поддерживаемая версия iOS (ваша 16.7.16 отлично подойдет)
TARGET = iphone:clang:latest:14.0

# Подключаем базовые настройки сборки Theos
include $(THEOS)/makefiles/common.mk

# Имя нашего твика (оно должно совпадать с именем dylib-файла, который мы внедряем)
TWEAK_NAME = MyHack

# Список исходных файлов (нашего кода)
MyHack_FILES = Tweak.xm

# Фреймворки, которые использует наш код
MyHack_FRAMEWORKS = UIKit Foundation

# Флаги компилятора:
# -fobjc-arc включает автоматическое управление памятью (ARC)
# -Wno-error... отключает превращение предупреждений об устаревших методах (keyWindow) в ошибки, 
# из-за которых у нас падала сборка
MyHack_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations -Wno-error=unguarded-availability-new

# Подключаем стандартные правила сборки твиков
include $(THEOS_MAKE_PATH)/tweak.mk
