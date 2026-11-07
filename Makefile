# Имя вашего твика (без пробелов). Именно так будет называться .dylib
TWEAK_NAME = MyMenuMod

# Файлы с исходным кодом
$(TWEAK_NAME)_FILES = src/Tweak.xm

# Флаги компилятора: включаем ARC и указываем архитектуру для iOS
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

# Архитектура для iOS (arm64 — стандарт для современных устройств)
ARCHS = arm64

# Указываем Theos, что это твик для iOS
TARGET = iphone:clang:latest:15.0

# Подключаем стандартные правила сборки твиков Theos
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
