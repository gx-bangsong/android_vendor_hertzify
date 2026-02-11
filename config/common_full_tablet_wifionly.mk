# Inherit mobile full common Hertzify stuff
$(call inherit-product, vendor/hertzify/config/common_mobile_full.mk)

# Inherit tablet common Hertzify stuff
$(call inherit-product, vendor/hertzify/config/tablet.mk)
$(call inherit-product, vendor/hertzify/config/wifionly.mk)