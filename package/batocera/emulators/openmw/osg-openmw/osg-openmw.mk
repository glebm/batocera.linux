################################################################################
#
# osg-openmw
#
################################################################################

OSG_OPENMW_VERSION = ddbed2353
OSG_OPENMW_SITE = $(call github,openscenegraph,OpenSceneGraph,$(OSG_OPENMW_VERSION))
OSG_OPENMW_LICENSE = OpenSceneGraph Public License
OSG_OPENMW_DEPENDENCIES = freetype giflib jpeg libpng openal sdl2 tiff zlib

# Linked statically
OSG_OPENMW_INSTALL_STAGING = YES
OSG_OPENMW_INSTALL_TARGET = NO

# Note: OSG_CPP_EXCEPTIONS_AVAILABLE is needed for BUILD_OSG_PLUGIN_PNG
OSG_OPENMW_CONF_OPTS = \
	-DCMAKE_INSTALL_PREFIX="/build/openmw/usr" \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE=ON \
	-DBUILD_OSG_APPLICATIONS=OFF \
	-DBUILD_OSG_DEPRECATED_SERIALIZERS=OFF \
	-DDYNAMIC_OPENTHREADS=OFF \
	-DDYNAMIC_OPENSCENEGRAPH=OFF \
	-DOSG_GL_LIBRARY_STATIC=OFF \
	-DBUILD_OSG_PLUGINS_BY_DEFAULT=OFF \
	-DBUILD_OSG_PLUGIN_OSG=ON \
	-DBUILD_OSG_PLUGIN_DDS=ON \
	-DBUILD_OSG_PLUGIN_TGA=ON \
	-DBUILD_OSG_PLUGIN_BMP=ON \
	-DBUILD_OSG_PLUGIN_JPEG=ON \
	-DBUILD_OSG_PLUGIN_PNG=ON \
	-DBUILD_OSG_PLUGIN_FREETYPE=ON \
	-DOSG_CPP_EXCEPTIONS_AVAILABLE=ON \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS=1

# Disable common warning types to avoid polluting the build log.
OSG_OPENMW_CONF_OPTS += -DCMAKE_CXX_FLAGS="-Wno-deprecated-copy -Wno-shadow -Wno-psabi"

ifeq ($(BR2_PACKAGE_XORG7),y)
OSG_OPENMW_DEPENDENCIES += xlib_libX11 xlib_libXrandr fltk
OSG_OPENMW_CONF_OPTS += -DOSG_WINDOWING_SYSTEM=X11
else
OSG_OPENMW_CONF_OPTS += -DOSG_WINDOWING_SYSTEM=None
endif

ifeq ($(BR2_PACKAGE_HAS_LIBGL),y)
OSG_OPENMW_DEPENDENCIES += libgl libfreeglut libgtk2
OSG_OPENMW_CONF_OPTS += -DOPENGL_PROFILE=GL2
else
OSG_OPENMW_DEPENDENCIES += gl4es-openmw
OSG_OPENMW_CONF_OPTS += \
	-DOPENGL_PROFILE=GL2 \
	-DOPENGL_gl_LIBRARY=$(TARGET_DIR)/usr/lib/openmw/gl4es/libGL.so.1 \
	-DOPENGL_glx_LIBRARY=$(TARGET_DIR)/usr/lib/openmw/gl4es/libGL.so.1 \
	-DOPENGL_INCLUDE_DIR=$(STAGING_DIR)/usr/include/openmw/gl4es
endif

define OSG_OPENMW_INSTALL_PKGCONFIG
	$(INSTALL) -D -m 0644 $(STAGING_DIR)/build/openmw/usr/lib/pkgconfig/open*.pc -t $(STAGING_DIR)/usr/lib/pkgconfig
endef

OSG_OPENMW_POST_INSTALL_STAGING_HOOKS += OSG_OPENMW_INSTALL_PKGCONFIG

$(eval $(cmake-package))
