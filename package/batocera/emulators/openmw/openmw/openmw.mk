################################################################################
#
# openmw
#
################################################################################

# NOTE: When bumping the version of this package, make sure that
# `OPENMW_EXTRA_DOWNLOADS` are in sync with openmw's `extern/CMakeLists.txt`.

# https://gitlab.com/glebm/openmw/-/tree/hack1
OPENMW_VERSION = eb0b6abf2f483acabadbe78b4223e323e8db2add
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
OPENMW_MYGUI_VERSION = f93d4fb614f843390cfe3492586466dc8d06c4b3
OPENMW_OSG_VERSION = e65f47c4ab3a0b53cc19f517961671e5f840a08d
OPENMW_RECASTNAVIGATION_VERSION = 70df86fd72063cdf7693ce1baa3c88f7c1f2885d
OPENMW_BULLET_SOURCE = $(OPENMW_BULLET_VERSION).tar.gz
OPENMW_MYGUI_SOURCE = $(OPENMW_MYGUI_VERSION).tar.gz
OPENMW_OSG_SOURCE = $(OPENMW_OSG_VERSION).tar.gz
OPENMW_RECASTNAVIGATION_SOURCE = $(OPENMW_RECASTNAVIGATION_VERSION).tar.gz
OPENMW_EXTRA_DOWNLOADS = \
	$(call github,glebm,bullet3,$(OPENMW_BULLET_SOURCE)) \
	$(call github,MyGUI,mygui,$(OPENMW_MYGUI_SOURCE)) \
	$(call github,OpenMW,osg,$(OPENMW_OSG_SOURCE)) \
	$(call github,glebm,recastnavigation,$(OPENMW_RECASTNAVIGATION_SOURCE))

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
	mkdir -p $(@D)/br-fetched/recastnavigation-$(OPENMW_RECASTNAVIGATION_VERSION)
	$(call suitable-extractor,$(OPENMW_RECASTNAVIGATION_SOURCE)) $(OPENMW_DL_DIR)/$(OPENMW_RECASTNAVIGATION_SOURCE) | \
		$(TAR) --strip-components=1 -C $(@D)/br-fetched/recastnavigation-$(OPENMW_RECASTNAVIGATION_VERSION) $(TAR_OPTIONS) -
endef
OPENMW_POST_EXTRACT_HOOKS += OPENMW_EXTRACT_EXTRA_DOWNLOADS

OPENMW_CONF_OPTS += \
	-DFETCHCONTENT_FULLY_DISCONNECTED=ON \
	-DFETCHCONTENT_SOURCE_DIR_BULLET=$(OPENMW_BUILDDIR)br-fetched/bullet-$(OPENMW_BULLET_VERSION) \
	-DFETCHCONTENT_SOURCE_DIR_MYGUI=$(OPENMW_BUILDDIR)br-fetched/mygui-$(OPENMW_MYGUI_VERSION) \
	-DFETCHCONTENT_SOURCE_DIR_OSG=$(OPENMW_BUILDDIR)br-fetched/osg-$(OPENMW_OSG_VERSION) \
	-DFETCHCONTENT_SOURCE_DIR_RECASTNAVIGATION=$(OPENMW_BUILDDIR)br-fetched/recastnavigation-$(OPENMW_RECASTNAVIGATION_VERSION) \
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
OPENMW_CMAKE_CXX_FLAGS += -Wno-psabi

#### DEBUG HACKS
BR2_STRIP_EXCLUDE_FILES += openmw
OPENMW_CONF_OPTS += -DCMAKE_BUILD_TYPE=RelWithDebInfo
OPENMW_CMAKE_CXX_FLAGS += -g1 -fsanitize=undefined -fsanitize-recover=undefined -fsanitize=address -fsanitize-recover=address
####

OPENMW_CONF_OPTS += -DCMAKE_CXX_FLAGS="$(OPENMW_CMAKE_CXX_FLAGS)"

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
