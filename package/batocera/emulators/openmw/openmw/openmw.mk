################################################################################
#
# openmw
#
################################################################################

# NOTE: When bumping the version of this package, make sure that
# `OPENMW_EXTRA_DOWNLOADS` are in sync with openmw's `extern/CMakeLists.txt`.

# https://gitlab.com/OpenMW/openmw/-/merge_requests/547
OPENMW_VERSION = 8cb654509979469ea89f08908b67bc33eab11078
OPENMW_SOURCE = openmw-$(OPENMW_VERSION).tar.gz
OPENMW_SITE = https://gitlab.com/glebm/openmw/-/archive/$(OPENMW_VERSION)
OPENMW_LICENSE = GPL-3.0+
OPENMW_DEPENDENCIES = sdl2 freetype fontconfig libpng jpeg boost ffmpeg lz4 openal

# OpenMW's static build uses `FetchInclude`, which by default will download
# dependencies from remote locations.
#
# We want to keep all downloads in the Buildroot's DL directory, so we download
# them via buildroot and pass them explictly.
OPENMW_BULLET_VERSION = ed5256454f4f84bd2c1728c88ddb0405d614e7d2
OPENMW_MYGUI_VERSION = MyGUI3.4.0
OPENMW_OSG_VERSION = b0259766eaee3cfc6bb523095a7e0bd395c2a4c7
OPENMW_BULLET_SOURCE = $(OPENMW_BULLET_VERSION).tar.gz
OPENMW_MYGUI_SOURCE = $(OPENMW_MYGUI_VERSION).tar.gz
OPENMW_OSG_SOURCE = $(OPENMW_OSG_VERSION).tar.gz
OPENMW_EXTRA_DOWNLOADS = \
	$(call github,glebm,bullet3,$(OPENMW_BULLET_SOURCE)) \
	$(call github,MyGUI,mygui,$(OPENMW_MYGUI_SOURCE)) \
	$(call github,glebm,OpenSceneGraph,$(OPENMW_OSG_SOURCE))

define OPENMW_EXTRACT_EXTRA_DOWNLOADS
	mkdir -p $(@D)/br-fetched/bullet-$(OPENMW_BULLET_VERSION)
	$(call suitable-extractor,$(OPENMW_BULLET_SOURCE)) $(OPENMW_DL_DIR)/$(OPENMW_BULLET_SOURCE) | \
		$(TAR) --strip-components=1 -C $(@D)/br-fetched/bullet-$(OPENMW_BULLET_VERSION) $(TAR_OPTIONS) -
	mkdir -p $(@D)/br-fetched/mygui-$(OPENMW_MYGUI_VERSION)
	$(call suitable-extractor,$(OPENMW_MYGUI_SOURCE)) $(OPENMW_DL_DIR)/$(OPENMW_MYGUI_SOURCE) | \
		$(TAR) --strip-components=1 -C $(@D)/br-fetched/mygui-$(OPENMW_MYGUI_VERSION) $(TAR_OPTIONS) -
	mkdir -p $(@D)/br-fetched/osg-$(OPENMW_OSG_VERSION)
	$(call suitable-extractor,$(OPENMW_OSG_SOURCE)) $(OPENMW_DL_DIR)/$(OPENMW_OSG_SOURCE) | \
		$(TAR) --strip-components=1 -C $(@D)/br-fetched/osg-$(OPENMW_OSG_VERSION) $(TAR_OPTIONS) -
endef
OPENMW_POST_EXTRACT_HOOKS += OPENMW_EXTRACT_EXTRA_DOWNLOADS

OPENMW_CONF_OPTS += \
	-DFETCHCONTENT_FULLY_DISCONNECTED=ON \
	-DFETCHCONTENT_SOURCE_DIR_BULLET=$(OPENMW_BUILDDIR)br-fetched/bullet-$(OPENMW_BULLET_VERSION) \
	-DFETCHCONTENT_SOURCE_DIR_MYGUI=$(OPENMW_BUILDDIR)br-fetched/mygui-$(OPENMW_MYGUI_VERSION) \
	-DFETCHCONTENT_SOURCE_DIR_OSG=$(OPENMW_BUILDDIR)br-fetched/osg-$(OPENMW_OSG_VERSION) \
	-DOPENMW_USE_SYSTEM_BULLET=OFF \
	-DOPENMW_USE_SYSTEM_MYGUI=OFF \
	-DOPENMW_USE_SYSTEM_OSG=OFF

OPENMW_CONF_OPTS += \
	-DBUILD_SHARED_LIBS=OFF \
	-OPENMW_VERSION_COMMITHASH=$(OPENMW_VERSION) \
	-DBUILD_LAUNCHER=OFF \
	-DBUILD_WIZARD=OFF \
	-DBUILD_MWINIIMPORTER=OFF \
	-DBUILD_OPENCS=OFF \
	-DBUILD_ESSIMPORTER=OFF \
	-DBUILD_BSATOOL=OFF \
	-DBUILD_ESMTOOL=OFF \
	-DBUILD_NIFTEST=OFF

# Enable link-time optimization.
# Known to significantly improve OpenMW's performance.
OPENMW_CONF_OPTS += \
	-DOPENMW_LTO_BUILD=ON \
	-DCMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE=ON \
	-DCMAKE_POLICY_DEFAULT_CMP0069=NEW

# MyGUI config options
OPENMW_CONF_OPTS += \
	-DMYGUI_RENDERSYSTEM=1

# OpenSceneGraph config options
OPENMW_CONF_OPTS += \
	-DOSG_CPP_EXCEPTIONS_AVAILABLE=ON \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS=1
ifeq ($(BR2_PACKAGE_XORG7),y)
OPENMW_DEPENDENCIES += xlib_libX11 xlib_libXrandr fltk
OPENMW_CONF_OPTS += -DOSG_WINDOWING_SYSTEM=X11
else
OPENMW_CONF_OPTS += -DOSG_WINDOWING_SYSTEM=None
endif

# Disable common warning types to avoid polluting the build log.
OPENMW_CONF_OPTS += -DCMAKE_CXX_FLAGS="-Wno-psabi"

ifeq ($(BR2_PACKAGE_HAS_LIBGL),y)
OPENMW_DEPENDENCIES += libgl

# OpenSceneGraph:
OPENMW_DEPENDENCIES += libfreeglut libgtk2 # libgl already added
OPENMW_CONF_OPTS += -DOPENGL_PROFILE=GL2
else
# Needed by OpenMW itself and OpenSceneGraph:
OPENMW_DEPENDENCIES += gl4es-openmw
OPENMW_CONF_OPTS += \
	-DOPENGL_gl_LIBRARY=$(TARGET_DIR)/usr/lib/openmw/gl4es/libGL.so.1 \
	-DOPENGL_glx_LIBRARY=$(TARGET_DIR)/usr/lib/openmw/gl4es/libGL.so.1 \
	-DOPENGL_INCLUDE_DIR=$(STAGING_DIR)/usr/include/openmw/gl4es

# OpenSceneGraph:
OPENMW_CONF_OPTS += -DOPENGL_PROFILE=GL2
endif

$(eval $(cmake-package))
