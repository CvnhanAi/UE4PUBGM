DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
GO_EASY_ON_ME = 1
THEOS_DEVICE_IP = 10.42.0.206

ARCHS = arm64

# export THEOS=~/theos

FRAMEWORKS = Foundation

TARGET = iphone:clang:latest:7.0

#THEOS_DEVICE_SDK = iphoneos16.0

THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = UE4

UE4_FRAMEWORKS =  UIKit Foundation Security QuartzCore CoreGraphics CoreText  AVFoundation Accelerate GLKit SystemConfiguration GameController CydiaSubstrate

# UE4_LDFLAGS += API/libAPIClient.a
UE4_CCFLAGS = -std=c++17 -fno-rtti -fno-exceptions -DNDEBUG -fvisibility=hidden -Wc++11-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -fvisibility=hidden -fpermissive -fexceptions -w -s -Wno-error=format-security -fvisibility=hidden -Werror -fpermissive -Wall -fexceptions
UE4_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -fvisibility=hidden -Wc++11-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -fvisibility=hidden -fpermissive -fexceptions -w -s -Wno-error=format-security -fvisibility=hidden -Werror -fpermissive -Wall -fexceptions 


 
UE4_FILES = $(wildcard Menu/*.mm) $(wildcard Menu/*.cpp) $(wildcard Menu/*.m) 
#$(TWEAK_NAME)_LIBRARIES += substrate

include $(THEOS_MAKE_PATH)/tweak.mk


