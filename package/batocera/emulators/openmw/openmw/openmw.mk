################################################################################
#
# openmw
#
################################################################################

OPENMW_VERSION = 7455dfb3a18ef57128f3f96d1d41bd5899e33aa0
OPENMW_SOURCE = openmw-$(OPENMW_VERSION).tar.gz
OPENMW_SITE = https://gitlab.com/OpenMW/openmw/-/archive/$(OPENMW_VERSION)

OPENMW_LICENSE = GPL-3.0+
OPENMW_DEPENDENCIES = sdl2 bullet freetype fontconfig libpng jpeg boost ffmpeg lz4 osg-openmw mygui-openmw openal

OPENMW_CONF_OPTS = \
	-DBUILD_SHARED_LIBS=OFF \
	-OPENMW_VERSION_COMMITHASH=$(OPENMW_VERSION) \
	-DOPENMW_UNITY_BUILD=ON \
	-DBUILD_LAUNCHER=OFF \
	-DBUILD_WIZARD=OFF \
	-DBUILD_MWINIIMPORTER=OFF \
	-DBUILD_OPENCS=OFF \
	-DBUILD_ESSIMPORTER=OFF \
	-DBUILD_BSATOOL=OFF \
	-DBUILD_ESMTOOL=OFF \
	-DBUILD_NIFTEST=OFF \
	-DMYGUI_STATIC=ON \
	-DOSG_STATIC=ON \
	-DBULLET_USE_DOUBLES=OFF

# Disable common warning types to avoid polluting the build log.
OPENMW_CONF_OPTS += -DCMAKE_CXX_FLAGS="-Wno-psabi"

# Do not enable LTO (-DOPENMW_LTO_BUILD=ON) because it causes an internal compiler error with GCC 9.3.0 and 10.2.0:
# lto1: internal compiler error: in add_symbol_to_partition_1, at lto/lto-partition.c:153
# TODO: Try again after upgrading GCC.

OPENMW_CONF_ENV += PKG_CONFIG_PATH="$(STAGING_DIR)/build/openmw/usr/lib/pkgconfig"

# OpenMW does not use pkg-config to find OSG, so we need to point to it manually because it is in an unusual location.
OPENMW_CONF_OPTS += -DOSG_DIR=$(STAGING_DIR)/build/openmw/usr

ifeq ($(BR2_PACKAGE_HAS_LIBGL),y)
OPENMW_DEPENDENCIES += libgl
else
OPENMW_DEPENDENCIES += gl4es-openmw
OPENMW_CONF_OPTS += \
	-DOPENGL_gl_LIBRARY=$(TARGET_DIR)/usr/lib/openmw/gl4es/libGL.so.1 \
	-DOPENGL_glx_LIBRARY=$(TARGET_DIR)/usr/lib/openmw/gl4es/libGL.so.1 \
	-DOPENGL_INCLUDE_DIR=$(STAGING_DIR)/usr/include/openmw/gl4es
endif

$(eval $(cmake-package))
