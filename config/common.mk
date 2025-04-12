# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

# Allow vendor prebuilt repos to exclude themselves from bp scanning
-include $(sort $(wildcard vendor/*/*/exclude-bp.mk))

PRODUCT_BRAND ?= HertzifyOS

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_EXT_PROPERTIES += ro.adb.secure=0
else
ifdef WITH_ADB_INSECURE
# Forcebly disable ADB authentication
PRODUCT_SYSTEM_EXT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_EXT_PROPERTIES += ro.adb.secure=1

# Set ro.debuggable=0 for userdebug
PRODUCT_NOT_DEBUGGABLE_IN_USERDEBUG := true
endif

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_PRODUCT_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/hertzify/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/hertzify/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions
#    vendor/hertzify/prebuilt/common/bin/50-hertzify.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-hertzify.sh

#PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
#    system/addon.d/50-hertzify.sh

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/hertzify/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/hertzify/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/hertzify/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/backuptool_ab.sh \
    system/bin/backuptool_ab.functions \
    system/bin/backuptool_postinstall.sh

PRODUCT_PRODUCT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif

# Hertzify-specific init rc file
PRODUCT_COPY_FILES += \
    vendor/hertzify/prebuilt/common/etc/init/init.hertzify-system_ext.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.hertzify-system_ext.rc

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Credential storage
PRODUCT_PACKAGES += \
    android.software.credentials.prebuilt.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# Enforce privapp-permissions whitelist
PRODUCT_PRODUCT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

ART_BUILD_TARGET_NDEBUG := false
ART_BUILD_TARGET_DEBUG := false
ART_BUILD_HOST_NDEBUG := false
ART_BUILD_HOST_DEBUG := false

# Flags
ifeq ($(TARGET_BUILD_VARIANT), user)
    # Strip the local variable table and the local variable type table to reduce
    # the size of the system image. This has no bearing on stack traces, but will
    # leave less information available via JDWP.
    PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
    # Disable dexpreopt debug info
    WITH_DEXPREOPT_DEBUG_INFO := false
    # Reduce system server verbosity
    PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
    # Don't include art debug targets
    PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
    # Always preopt extracted APKs to prevent extracting out of the APK for gms
    # modules.
    PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true
endif

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true

# Disable dex2oat debug
USE_DEX2OAT_DEBUG := false

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

ifneq ($(TARGET_DISABLE_EPPE),true)
# Require all requested packages to exist
$(call enforce-product-packages-exist-internal,$(lastword $(_include_stack)),product_manifest.xml rild Calendar android.hidl.memory@1.0-impl.vendor vndk_apex_snapshot_package)
endif

# APEX
DISABLE_DEXPREOPT_CHECK := true

PRODUCT_PACKAGES += \
    com.google.android.permission

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/apex/com.google.android.permission.apex

# Bootanimation
$(call inherit-product, vendor/hertzify/config/bootanimation.mk)

# Blur
TARGET_ENABLE_BLUR ?= true
ifeq ($(TARGET_ENABLE_BLUR), true)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.surface_flinger.supports_background_blur=1
endif

# Charger
PRODUCT_PACKAGES += \
    charger_res_images \
    product_charger_res_images \
    product_charger_res_images_vendor

# Custom Overlays
PRODUCT_PACKAGES += \
    PixelLauncherOverlayCustom \
    PixelLauncherNoGestureHintOverlay
    
# Disable async MTE on a few processes
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.arm64.memtag.app.com.android.se=off \
    persist.arm64.memtag.app.com.google.android.bluetooth=off \
    persist.arm64.memtag.app.com.android.nfc=off \
    persist.arm64.memtag.process.system_server=off

# Disable default frame rate limit for games
PRODUCT_PRODUCT_PROPERTIES += \
    debug.graphics.game_default_frame_rate.disabled=true

# Disable RescueParty due to high risk of data loss
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.disable_rescue=true
    
# Disable touch video heatmap to reduce latency, motion jitter, and CPU usage
# on supported devices with Deep Press input classifier HALs and models
PRODUCT_PRODUCT_PROPERTIES += \
    ro.input.video_enabled=false
    
# Enable Material Design 3 Expressive
PRODUCT_PRODUCT_PROPERTIES += is_expressive_design_enabled=true

# Lineage interfaces
PRODUCT_PACKAGES += \
    framework_compatibility_matrix.lineage.xml

PRODUCT_PACKAGES += \
    Updater

PRODUCT_COPY_FILES += \
    vendor/hertzify/prebuilt/common/etc/init/init.hertzify-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.hertzify-updater.rc

# Extra tools in Hertzify
PRODUCT_PACKAGES += \
    bash \
    curl \
    getcap \
    htop \
    nano \
    setcap \
    vim

PRODUCT_PACKAGES += \
    nano_recovery

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/curl \
    system/bin/getcap \
    system/bin/setcap \
    system/%/libzstd.so

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.ntfs \
    mkfs.ntfs \
    mount.ntfs

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/fsck.ntfs \
    system/bin/mkfs.ntfs \
    system/bin/mount.ntfs \
    system/%/libfuse-lite.so \
    system/%/libntfs-3g.so

# Default wifi country code
PRODUCT_SYSTEM_PROPERTIES += \
    ro.boot.wificountrycode?=00

# FaceUnlock
ifneq ($(TARGET_FACE_UNLOCK_SUPPORTED),false)
PRODUCT_PACKAGES += \
    FaceUnlock

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/android.hardware.biometrics.face.xml
endif

# FRP
PRODUCT_COPY_FILES += \
    vendor/hertzify/prebuilt/common/bin/wipe-frp.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/wipe-frp

# Packages
PRODUCT_PACKAGES += \
    GameSpace

# Gboard side padding
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.ime.kb_pad_port_l=4 \
    ro.com.google.ime.kb_pad_port_r=4 \
    ro.com.google.ime.kb_pad_land_l=64 \
    ro.com.google.ime.kb_pad_land_r=64

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

PRODUCT_COPY_FILES += \
    vendor/hertzify/prebuilt/common/etc/init/init.openssh.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.openssh.rc

# Permissions
PRODUCT_COPY_FILES += \
    vendor/hertzify/config/permissions/privapp-permissions-hertzify.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-hertzify.xml

# rsync
PRODUCT_PACKAGES += \
    rsync

# Storage manager
PRODUCT_PRODUCT_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

ifneq ($(TARGET_BUILD_VARIANT),user)
ifeq ($(WITH_SU),true)
# Root
PRODUCT_PACKAGES += \
    adb_root

PRODUCT_PACKAGES += \
    su

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/xbin/su
endif
endif

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI

PRODUCT_PRODUCT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed

ifeq ($(TARGET_BUILD_VARIANT),userdebug)
PRODUCT_PRODUCT_PROPERTIES += \
    debug.sf.enable_transaction_tracing=false
endif

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/hertzify/overlay/no-rro
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/hertzify/overlay/common \
    vendor/hertzify/overlay/no-rro

PRODUCT_PACKAGES += \
    DocumentsUIOverlay \
    NetworkStackOverlay \
    NfcOverlay \
    PermissionControllerOverlay

# Translations
CUSTOM_LOCALES += \
    ast_ES \
    gd_GB \
    cy_GB \
    fur_IT

# Use a generic profile based boot image by default
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_COPY_FILES += \
    art/build/boot/preloaded-classes:$(TARGET_COPY_OUT_SYSTEM)/etc/preloaded-classes

PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := \
    art/build/boot/boot-image-profile.txt

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/etc/preloaded-classes

# GMS
include vendor/hertzify/config/gms.mk

include vendor/hertzify/config/version.mk

-include vendor/hertzify-priv/keys/keys.mk
-include $(WORKSPACE)/build_env/image-auto-bits.mk
