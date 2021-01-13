################################################################################
#
# mygui-openmw
#
################################################################################

MYGUI_OPENMW_VERSION = MyGUI3.4.0
MYGUI_OPENMW_SITE = $(call github,MyGUI,mygui,$(MYGUI_OPENMW_VERSION))
MYGUI_OPENMW_LICENSE = OpenSceneGraph Public License
MYGUI_OPENMW_DEPENDENCIES = sdl2

# Linked statically
MYGUI_OPENMW_INSTALL_STAGING = YES
MYGUI_OPENMW_INSTALL_TARGET = NO

MYGUI_OPENMW_CONF_OPTS = \
	-DCMAKE_INSTALL_PREFIX="/build/openmw/usr" \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE=ON \
	-DMYGUI_STATIC=ON \
	-DMYGUI_RENDERSYSTEM=1 \
	-DMYGUI_BUILD_DEMOS=OFF \
	-DMYGUI_BUILD_TOOLS=OFF \
	-DMYGUI_BUILD_PLUGINS=OFF \
	-DMYGUI_BUILD_DOCS=OFF

$(eval $(cmake-package))
