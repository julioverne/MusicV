include theos/makefiles/common.mk

TWEAK_NAME = MusicV

MusicV_FILES = MusicV.xm
MusicV_FRAMEWORKS = CydiaSubstrate UIKit CoreMedia CoreImage CoreGraphics AVFoundation QuartzCore
MusicV_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
MusicV_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
	@echo "[+] Copying Files..."
	@cp -rf ./obj/obj/debug/MusicV.dylib //Library/MobileSubstrate/DynamicLibraries/MusicV.dylib
	@/usr/bin/ldid -S //Library/MobileSubstrate/DynamicLibraries/MusicV.dylib
	@echo "DONE"
	@killall Music
	