LOCAL_PATH:= $(call my-dir)
#----------------------------------------------------------------
# iptables

include $(CLEAR_VARS)

IPLINKS := iptables-restore
IP6LINKS := ip6tables-restore

ifeq ($(TARGET_BUILD_VARIANT),userdebug)
  # Only need iptables-save if we are doing development
  IPLINKS += iptables-save
  IP6LINKS += ip6tables-save
endif

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/../include/

LOCAL_CFLAGS:=-DNO_SHARED_LIBS=1
LOCAL_CFLAGS+=-DALL_INCLUSIVE
LOCAL_CFLAGS+=-DXTABLES_INTERNAL
LOCAL_CFLAGS+=-D_LARGEFILE_SOURCE=1 -D_LARGE_FILES -D_FILE_OFFSET_BITS=64 -D_REENTRANT -DENABLE_IPV4
# Accommodate arm-eabi-4.4.3 tools that don't set __ANDROID__
LOCAL_CFLAGS+=-D__ANDROID__
LOCAL_CFLAGS += -Wno-sign-compare -Wno-pointer-arith

LOCAL_SRC_FILES:= \
	xtables-multi.c iptables-xml.c xshared.c \
	iptables-save.c iptables-restore.c \
	iptables-standalone.c iptables.c

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE:=iptables

LOCAL_STATIC_LIBRARIES := \
	libext \
	libext4 \
	libip4tc \
	libxtables

include $(BUILD_EXECUTABLE)

# Make symlinks for iptables
#
SYMLINKS := $(addprefix $(TARGET_OUT)/bin/,$(IPLINKS))
$(SYMLINKS): IPTABLES_BINARY := $(LOCAL_MODULE)
$(SYMLINKS): $(LOCAL_INSTALLED_MODULE) $(LOCAL_PATH)/Android.mk
	@echo "Symlink: $@ -> $(IPTABLES_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(IPTABLES_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(SYMLINKS)

# We need this so that the installed files could be picked up based on the
# local module name
ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(SYMLINKS)

#----------------------------------------------------------------
# ip6tables
include $(CLEAR_VARS)

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/../include/

LOCAL_CFLAGS:=-DNO_SHARED_LIBS=1
LOCAL_CFLAGS+=-DALL_INCLUSIVE
LOCAL_CFLAGS+=-DXTABLES_INTERNAL
LOCAL_CFLAGS+=-D_LARGEFILE_SOURCE=1 -D_LARGE_FILES -D_FILE_OFFSET_BITS=64 -D_REENTRANT -DENABLE_IPV6
# Accommodate arm-eabi-4.4.3 tools that don't set __ANDROID__
LOCAL_CFLAGS+=-D__ANDROID__
LOCAL_CFLAGS += -Wno-sign-compare -Wno-pointer-arith

LOCAL_SRC_FILES:= \
	xtables-multi.c iptables-xml.c xshared.c \
	ip6tables-save.c ip6tables-restore.c \
	ip6tables-standalone.c ip6tables.c

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE:=ip6tables

LOCAL_STATIC_LIBRARIES := \
	libext \
	libext6 \
	libip6tc \
	libxtables

include $(BUILD_EXECUTABLE)

# Make symlinks for ip6tables
#
SYMLINKS := $(addprefix $(TARGET_OUT)/bin/,$(IP6LINKS))
$(SYMLINKS): IP6TABLES_BINARY := $(LOCAL_MODULE)
$(SYMLINKS): $(LOCAL_INSTALLED_MODULE) $(LOCAL_PATH)/Android.mk
	@echo "Symlink: $@ -> $(IP6TABLES_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(IP6TABLES_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(SYMLINKS)

#----------------------------------------------------------------

all_modules: $(SYMLINKS)

print-% : ;@echo $* = $($*)
