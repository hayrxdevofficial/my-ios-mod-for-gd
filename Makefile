TWEAK_NAME = MyMenuMod

$(TWEAK_NAME)_FILES = src/Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-error
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation

ARCHS = arm64
TARGET = iphone:clang:latest:16.5:16.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
