TARGET := iphone:clang:14.5:14.0
INSTALL_TARGET_PROCESSES = YouTube
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/package.mk

before-all::
	@if [ -f "Controllers/RootOptionsController.m.bak" ]; then \
		mv Controllers/RootOptionsController.m.bak Controllers/RootOptionsController.m; \
	fi; \
	sed -i.bak -e 's|@YOUTUBE_REBORN_VERSION@|$(_THEOS_INTERNAL_PACKAGE_VERSION)|g' Controllers/RootOptionsController.m;

before-clean::
	@if [ -f "Controllers/RootOptionsController.m.bak" ]; then \
		mv Controllers/RootOptionsController.m.bak Controllers/RootOptionsController.m; \
	fi

TWEAK_NAME = YouTubeReborn
YouTubeReborn_FILES = $(shell find . -maxdepth 1 -name '*.xm') $(shell find Controllers -name '*.m') $(shell find AFNetworking -name '*.m') $(shell find XCDYouTubeKit -name '*.m') $(shell find DTTJailbreakDetection -name '*.m')
YouTubeReborn_CFLAGS = -fobjc-arc
YouTubeReborn_FRAMEWORKS = UIKit Foundation AVFoundation AVKit
YouTubeReborn_PRIVATE_FRAMEWORKS = MediaRemote
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
