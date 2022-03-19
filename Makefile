TARGET := iphone:clang:14.5:14.0
INSTALL_TARGET_PROCESSES = YouTube
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/package.mk
before-all::
ifeq ($(call __theos_bool,$(or $(FOR_RELEASE),$(FINALPACKAGE))),$(_THEOS_FALSE))
	$(eval _PACKAGE_NAME := $(shell grep '^Package:' control | cut -d' ' -f2-))
	$(eval _PACKAGE_VERSION := $(shell grep '^Version:' control | cut -d' ' -f2-))
	$(eval _GIT_DATE := $(shell git show -s --format=%cs | tr -d "-"))
	$(eval _GIT_COMMIT := $(shell git rev-parse --short HEAD))
	$(eval THEOS_PACKAGE_BASE_VERSION := $(_PACKAGE_VERSION)+git$(_GIT_DATE).$(_GIT_COMMIT))
	$(eval _DEBUG_NUMBER := $(shell THEOS_PROJECT_DIR=$(THEOS_PROJECT_DIR) $(THEOS_BIN_PATH)/package_version.sh -N "$(PACKAGE_NAME)" -V $(THEOS_PACKAGE_BASE_VERSION)))
	$(eval _THEOS_INTERNAL_PACKAGE_VERSION := $(_PACKAGE_VERSION)-debug.$(_DEBUG_NUMBER)+git$(_GIT_DATE).$(_GIT_COMMIT))
endif
	@if [ -f "Controllers/RootOptionsController.m.bak" ]; then \
		mv Controllers/RootOptionsController.m.bak Controllers/RootOptionsController.m; \
	fi; \
	sed -i.bak -e 's|@YOUTUBE_REBORN_VERSION@|$(_THEOS_INTERNAL_PACKAGE_VERSION)|g' Controllers/RootOptionsController.m;

before-clean::
	@if [ -f "Controllers/RootOptionsController.m.bak" ]; then \
		mv Controllers/RootOptionsController.m.bak Controllers/RootOptionsController.m; \
	fi; \
	if [ -f "control.bak" ]; then \
		mv control.bak control; \
	fi; 

TWEAK_NAME = YouTubeReborn
YouTubeReborn_FILES = $(shell find . -maxdepth 1 -name '*.xm') $(shell find Controllers -name '*.m') $(shell find AFNetworking -name '*.m') $(shell find XCDYouTubeKit -name '*.m') $(shell find DTTJailbreakDetection -name '*.m')
YouTubeReborn_CFLAGS = -fobjc-arc
YouTubeReborn_FRAMEWORKS = UIKit Foundation AVFoundation AVKit
YouTubeReborn_PRIVATE_FRAMEWORKS = MediaRemote
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
