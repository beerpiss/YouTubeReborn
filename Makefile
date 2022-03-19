TARGET := iphone:clang:14.5:14.0
INSTALL_TARGET_PROCESSES = YouTube
GO_EASY_ON_ME = 1

_GIT_IS_INSIDE_WORK_TREE := $(shell git rev-parse --is-inside-work-tree)
_GIT_TAG_NAME := $(shell git name-rev --name-only --tags HEAD)

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/package.mk
before-all::
# Git-based versioning
# If not a git repo (downloaded tarball etc.), use version from control file
# If git repo:
# - If on tag, use version from control file
# - If not on tag, use version from control file with added git manfest
#	- Release version is $(PACKAGE_VERSION)+git$(GIT_DATE).$(GIT_COMMIT_HASH)
#	- Debug version is $(PACKAGE_VERSION)-debug.$(_DEBUG_NUMBER)+git$(GIT_DATE).$(GIT_COMMIT_HASH)
# $(_DEBUG_NUMBER) is incremental.
ifeq ($(_GIT_IS_INSIDE_WORK_TREE),true)
ifeq ($(_GIT_TAG_NAME),undefined)
	$(eval _PACKAGE_NAME := $(shell grep '^Package:' $(_THEOS_DEB_PACKAGE_CONTROL_PATH) | cut -d' ' -f2-))
	$(eval _PACKAGE_VERSION := $(shell grep '^Version:' $(_THEOS_DEB_PACKAGE_CONTROL_PATH) | cut -d' ' -f2-))
	$(eval _GIT_DATE := $(shell git show -s --format=%cs | tr -d "-"))
	$(eval _GIT_COMMIT_HASH := $(shell git rev-parse --short HEAD))
	$(eval THEOS_PACKAGE_BASE_VERSION := $(_PACKAGE_VERSION)+git$(_GIT_DATE).$(_GIT_COMMIT_HASH))
ifeq ($(call __theos_bool,$(or $(debug),$(DEBUG))),$(_THEOS_TRUE))
	$(eval _DEBUG_NUMBER := $(shell THEOS_PROJECT_DIR=$(THEOS_PROJECT_DIR) $(THEOS_BIN_PATH)/package_version.sh -N "$(_PACKAGE_NAME)" -V $(THEOS_PACKAGE_BASE_VERSION)))
	$(eval _THEOS_INTERNAL_PACKAGE_VERSION := $(_PACKAGE_VERSION)-debug.$(_DEBUG_NUMBER)+git$(_GIT_DATE).$(_GIT_COMMIT_HASH))
else
	$(eval _THEOS_INTERNAL_PACKAGE_VERSION := $(THEOS_PACKAGE_BASE_VERSION))
endif
endif
endif
	@if [ -f "Controllers/RootOptionsController.m.bak" ]; then \
		mv Controllers/RootOptionsController.m.bak Controllers/RootOptionsController.m; \
	fi; \
	sed -i.bak -e 's|@YOUTUBE_REBORN_VERSION@|$(_THEOS_INTERNAL_PACKAGE_VERSION)|g' Controllers/RootOptionsController.m;

after-all::
	@if [ -f "Controllers/RootOptionsController.m.bak" ]; then \
		mv Controllers/RootOptionsController.m.bak Controllers/RootOptionsController.m; \
	fi

before-clean::
	@if [ -f "Controllers/RootOptionsController.m.bak" ]; then \
		mv Controllers/RootOptionsController.m.bak Controllers/RootOptionsController.m; \
	fi

TWEAK_NAME = YouTubeReborn
YouTubeReborn_FILES = $(shell find YouTubeReborn -name '*.xm') $(shell find Controllers -name '*.m') $(shell find AFNetworking -name '*.m') $(shell find XCDYouTubeKit -name '*.m') $(shell find DTTJailbreakDetection -name '*.m')
YouTubeReborn_CFLAGS = -fobjc-arc
YouTubeReborn_FRAMEWORKS = UIKit Foundation AVFoundation AVKit
YouTubeReborn_PRIVATE_FRAMEWORKS = MediaRemote
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
