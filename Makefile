TARGET := iphone:clang:14.5:14.0
INSTALL_TARGET_PROCESSES = YouTube
GO_EASY_ON_ME = 1

MODULES ?=
TWEAK_NAME = YouTubeReborn
$(TWEAK_NAME)_FILES = $(wildcard ./**/*.xm) $(wildcard ./**/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AVKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote
ARCHS = arm64 arm64e
THEOS_PLATFORM_DEB_COMPRESSION_TYPE = lzma
THEOS_PLATFORM_DEB_COMPRESSION_LEVEL = 9

ifneq (,$(findstring jailed,$(MODULES)))
	$(TWEAK_NAME)_IPA ?= /path/to/ipa
	RESOURCES_DIR := .resources
	DISPLAY_NAME ?= YouTubeReborn
	BUNDLE_ID ?= com.google.ios.youtube
	CODESIGN_IPA ?= 0
endif

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/package.mk
# Switch to dpkg-deb if it exists in PATH and we're not doing lzma
ifeq ($(shell type dpkg-deb >/dev/null 2>&1 && echo 1),1)
ifneq ($(THEOS_PLATFORM_DEB_COMPRESSION_TYPE),lzma)
	_THEOS_PLATFORM_DPKG_DEB = dpkg-deb
endif
endif

# Git-based versioning
# If not a git repo (downloaded tarball etc.), use version from control file
# If git repo:
# - If on tag, use version from control file
# - If not on tag, use version from tag/control file with added git manfest
#	- Release version is $(PACKAGE_VERSION)+git$(GIT_DATE).$(GIT_COMMIT_HASH)
#	- Debug version is $(PACKAGE_VERSION)-debug.$(_DEBUG_NUMBER)+git$(GIT_DATE).$(GIT_COMMIT_HASH)
# $(_DEBUG_NUMBER) is incremental.
ifeq ($(shell git rev-parse --is-inside-work-tree),true)
ifeq ($(shell git name-rev --name-only --tags HEAD),undefined)  
	_PACKAGE_NAME := $(shell grep '^Package:' control | cut -d' ' -f2-)
	_PACKAGE_VERSION := $(or $(shell git describe --tags --match 'v[0-9]*' --abbrev=0 | sed -r 's/^(v|V)//g'),$(shell grep '^Version:' control | cut -d' ' -f2-))
	_GIT_DATE := $(shell git show -s --format=%cs | tr -d "-")
	_GIT_COMMIT_HASH := $(shell git rev-parse --short HEAD)
	THEOS_PACKAGE_BASE_VERSION := $(_PACKAGE_VERSION)+git$(_GIT_DATE).$(_GIT_COMMIT_HASH)
ifeq ($(call __theos_bool,$(or $(debug),$(DEBUG))),$(_THEOS_TRUE))
	_DEBUG_NUMBER := $(shell THEOS_PROJECT_DIR=$(THEOS_PROJECT_DIR) $(THEOS_BIN_PATH)/package_version.sh -N "$(_PACKAGE_NAME)" -V $(THEOS_PACKAGE_BASE_VERSION))
	_THEOS_INTERNAL_PACKAGE_VERSION := $(_PACKAGE_VERSION)-debug.$(_DEBUG_NUMBER)+git$(_GIT_DATE).$(_GIT_COMMIT_HASH)
else
	_THEOS_INTERNAL_PACKAGE_VERSION := $(THEOS_PACKAGE_BASE_VERSION)
endif
ifneq (,$(findstring jailed,$(MODULES)))
	OUTPUT_NAME := $(TWEAK_NAME)$(_THEOS_INTERNAL_PACKAGE_VERSION).ipa
endif
endif
endif

before-all::
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
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
