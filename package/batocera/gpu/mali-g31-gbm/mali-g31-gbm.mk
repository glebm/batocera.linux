################################################################################
#
# mali-g31-gbm
#
################################################################################
# Version.: Commits on Jan 27, 2021
MALI_G31_GBM_VERSION = 6141ad6e6f2d3eb38e7e0962f61b78510b2e2d2c
MALI_G31_GBM_SITE = $(call github,rockchip-linux,libmali,$(MALI_G31_GBM_VERSION))
MALI_G31_GBM_INSTALL_STAGING = YES
MALI_G31_GBM_PROVIDES = libegl libgles libmali

MALI_G31_GBM_CONF_OPTS = \
	-Dplatform=gbm \
	-Dgpu=bifrost-g31 \
	-Dversion=rxp0

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ODROIDGOA),y)
# See https://wiki.odroid.com/odroid_go_advance/application_note/vulkan_on_rk3326
MALI_G31_GBM_EXTRA_DOWNLOADS=https://dn.odroid.com/RK3326/ODROID-GO-Advance/rk3326_r13p0_gbm_with_vulkan_and_cl.zip

ifeq ($(BR2_aarch64),y)
MALIG_G31_GBM_RK3326_BLOB = libmali.so_rk3326_gbm_arm64_r13p0_with_vulkan_and_cl
else
MALIG_G31_GBM_RK3326_BLOB = libmali.so_rk3326_gbm_arm32_r13p0_with_vulkan_and_cl
endif

define MALI_G31_GBM_RK3326_INSTALL
	cd $(@D) && unzip $(MALI_G31_GBM_DL_DIR)/rk3326_r13p0_gbm_with_vulkan_and_cl.zip
	$(INSTALL) -D -m 0755 $(@D)/$(MALIG_G31_GBM_RK3326_BLOB) $(TARGET_DIR)/usr/lib/libmali-bifrost-g31-rxp0-gbm.so
	rm -f $(TARGET_DIR)/usr/lib/libmali-bifrost-g31-rxp0-gbm.so $(TARGET_DIR)/usr/lib/libmali.so.1.9.0
	ln -sf libmali-bifrost-g31-rxp0-gbm.so $(TARGET_DIR)/usr/lib/libmali.so.1.9.0
	ln -sf libvulkan.so.1 $(TARGET_DIR)/usr/lib/libvulkan.so
	ln -sf libmali-bifrost-g31-rxp0-gbm.so $(TARGET_DIR)/usr/lib/libvulkan.so.1
endef

MALI_G31_GBM_POST_INSTALL_TARGET_HOOKS += MALI_G31_GBM_RK3326_INSTALL
endif

$(eval $(meson-package))
