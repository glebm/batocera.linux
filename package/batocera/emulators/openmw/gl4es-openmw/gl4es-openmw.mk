################################################################################
#
# gl4es-openmw
#
################################################################################

GL4ES_OPENMW_VERSION = v1.1.4
GL4ES_OPENMW_SITE = $(call github,ptitSeb,gl4es,$(GL4ES_OPENMW_VERSION))
GL4ES_OPENMW_LICENSE = GPL-3.0+
GL4ES_OPENMW_DEPENDENCIES = libgles

ifeq ($(BR2_PACKAGE_XORG7),y)
GL4ES_OPENMW_DEPENDENCIES += xlib_libX11
GL4ES_OPENMW_CONF_OPTS += -DNOX11=OFF
else
GL4ES_OPENMW_CONF_OPTS += -DNOX11=ON
endif

define GL4ES_OPENMW_COPY_HEADERS
$(INSTALL) -D -m 0644 $(@D)/include/GL/*.h -t $(STAGING_DIR)/usr/include/openmw/gl4es/GL
endef

#### DEBUG HACKS
BR2_STRIP_EXCLUDE_FILES += libGL1.so.1
GL4ES_OPENMW_CONF_OPTS += -DCMAKE_BUILD_TYPE=RelWithDebInfo
GL4ES_OPENMW_CMAKE_CXX_FLAGS += -g1 -fsanitize=undefined -fsanitize-recover=undefined -fsanitize=address -fsanitize-recover=address
GL4ES_OPENMW_CONF_OPTS += -DCMAKE_CXX_FLAGS="$(GL4ES_OPENMW_CMAKE_CXX_FLAGS)"
####

GL4ES_OPENMW_POST_INSTALL_TARGET_HOOKS += GL4ES_OPENMW_COPY_HEADERS

$(eval $(cmake-package))
