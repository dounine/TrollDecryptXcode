TARGET := iphone:clang:latest:14.5
INSTALL_TARGET_PROCESSES = TrollDecrypt

GO_EASY_ON_ME = 1
PACKAGE_FORMAT = ipa

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = TrollDecrypt

${APPLICATION_NAME}_FILES = SSZipArchive/minizip/unzip.c SSZipArchive/minizip/crypt.c SSZipArchive/minizip/ioapi_buf.c SSZipArchive/minizip/ioapi_mem.c SSZipArchive/minizip/ioapi.c SSZipArchive/minizip/minishared.c SSZipArchive/minizip/zip.c SSZipArchive/minizip/aes/aes_ni.c SSZipArchive/minizip/aes/aescrypt.c SSZipArchive/minizip/aes/aeskey.c SSZipArchive/minizip/aes/aestab.c SSZipArchive/minizip/aes/fileenc.c SSZipArchive/minizip/aes/hmac.c SSZipArchive/minizip/aes/prng.c SSZipArchive/minizip/aes/pwd2key.c SSZipArchive/minizip/aes/sha1.c SSZipArchive/SSZipArchive.m

${APPLICATION_NAME}_FILES += hook/fishhook.c

${APPLICATION_NAME}_FILES += $(shell find ./server -name '*.m' -print)

# 后台运行
${APPLICATION_NAME}_FILES += $(shell find ./audio -name '*.m' -print)

${APPLICATION_NAME}_FILES += $(shell find ./http -name '*.m' -print)

${APPLICATION_NAME}_FILES += main.m TDAppDelegate.m TDRootViewController.m TDDumpDecrypted.m TDUtils.m TDFileManagerViewController.m LSApplicationProxy+AltList.m
${APPLICATION_NAME}_FRAMEWORKS = UIKit CoreGraphics MobileCoreServices
${APPLICATION_NAME}_CFLAGS = -fobjc-arc
${APPLICATION_NAME}_PRIVATE_FRAMEWORKS = IOKit IOSurface
${APPLICATION_NAME}_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk

after-stage::
	rm -rf Payload
	mkdir -p $(THEOS_STAGING_DIR)/Payload
	ldid -Sentitlements.plist $(THEOS_STAGING_DIR)/Applications/$(APPLICATION_NAME).app/$(APPLICATION_NAME)
	cp -a $(THEOS_STAGING_DIR)/Applications/* $(THEOS_STAGING_DIR)/Payload
	mv $(THEOS_STAGING_DIR)/Payload .
	zip -q -r $(APPLICATION_NAME).tipa Payload
