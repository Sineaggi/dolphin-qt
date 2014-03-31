include_directories(${QT_INCLUDE})
include_directories(${CMAKE_CURRENT_BINARY_DIR}) # because of generated UI files

set(SRCS Src/Config/ConfigAudio.cpp
        Src/Config/ConfigGeneral.cpp
        Src/Config/ConfigGfx.cpp
        Src/Config/ConfigMain.cpp
        Src/Config/ConfigPad.cpp
        Src/Config/ConfigWiimote.cpp
        Src/GameList/GameTracker.cpp
        Src/GameList/GameTree.cpp
        Src/GameList/GameGrid.cpp
        Src/GameObject.cpp
        Src/Util/Util.cpp
        Src/Util/Resources.cpp
        Src/LogWidgets.cpp
        Src/main.cpp
        Src/MainWindow.cpp
        Src/RenderWidget.cpp
        Src/SystemInfo.cpp)

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	set(SRCS ${SRCS} Src/GLInterface/AGL.cpp)
endif()

set(LIBS    core
            ${LZO}
            discio
            bdisasm
            inputcommon
            common
            audiocommon
            z
            sfml-network
            ${OPENGL_LIBRARIES})

if(NOT ANDROID)
	link_directories(${CMAKE_PREFIX_PATH}/lib)
endif()

if(WIN32)
	set(SRCS ${SRCS} stdafx.cpp)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	# Link against OS X system frameworks.
	list(APPEND LIBS
		${APPKIT_LIBRARY}
		${AU_LIBRARY}
		${COREAUDIO_LIBRARY}
		${COREFUND_LIBRARY}
		${CORESERV_LIBRARY}
		${IOB_LIBRARY}
		${IOK_LIBRARY}
		${FORCEFEEDBACK}
		)
	if(wxWidgets_FOUND)
		list(APPEND LIBS
			${APPSERV_LIBRARY}
			${COCOA_LIBRARY}
			)
	endif()
	# Add resource files to application bundle.
	set(RESOURCES resources/Dolphin.icns)
	list(APPEND SRCS ${RESOURCES})
	set_source_files_properties(${RESOURCES} PROPERTIES
		MACOSX_PACKAGE_LOCATION Resources)
elseif(USE_X11)
	set(SRCS ${SRCS} X11Utils.cpp)
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD" OR
        ${CMAKE_SYSTEM_NAME} MATCHES "NetBSD")
	set(LIBS ${LIBS} usbhid)
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	set(DOLPHIN_EXE_BASE Dolphin)
else()
	set(DOLPHIN_EXE_BASE dolphin-emu)
endif()
if(wxWidgets_FOUND)
	set(DOLPHIN_EXE ${DOLPHIN_EXE_BASE})
else()
	set(DOLPHIN_EXE ${DOLPHIN_EXE_BASE}-nogui)
endif()

if(USE_UPNP)
  set(LIBS  ${LIBS} miniupnpc)
endif()

include(FindGettext)
if(GETTEXT_MSGMERGE_EXECUTABLE AND GETTEXT_MSGFMT_EXECUTABLE AND wxWidgets_FOUND)
	file(GLOB LINGUAS ${CMAKE_SOURCE_DIR}/Languages/po/*.po)
	add_custom_target(translations ALL)
	GETTEXT_CREATE_TRANSLATIONS(${CMAKE_SOURCE_DIR}/Languages/po/dolphin-emu.pot ${LINGUAS})
endif()

if(USE_EGL)
	set(SRCS ${SRCS} ../DolphinWX/GLInterface/Platform.cpp
		../DolphinWX/GLInterface/EGL.cpp)
	if(USE_WAYLAND)
		set(SRCS ${SRCS} ../DolphinWX/GLInterface/Wayland_Util.cpp)
	endif()
	if(USE_X11)
		set(SRCS ${SRCS} ../DolphinWX/GLInterface/X11_Util.cpp)
	endif()
else()
	if(WIN32)
		set(SRCS ${SRCS} ../DolphinWX/GLInterface/WGL.cpp)
	elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
		#set(SRCS ${SRCS} ../DolphinWX/GLInterface/AGL.cpp)
	else()
		set(SRCS ${SRCS} ../DolphinWX/GLInterface/GLX.cpp
			../DolphinWX/GLInterface/X11_Util.cpp)
		set(LIBS ${LIBS} rt ${X11_LIBRARIES}
				${XINPUT2_LIBRARIES}
				${XRANDR_LIBRARIES})
	endif()
endif()

if(NOT ANDROID)
	if(USE_X11)
	  set(LIBS  ${LIBS} ${X11_LIBRARIES}
              ${XINPUT2_LIBRARIES}
	      ${XRANDR_LIBRARIES})
	endif()
	if(USE_WAYLAND)
	  set(LIBS  ${LIBS} ${WAYLAND_LIBRARIES}
		${XKBCOMMON_LIBRARIES})
	endif()

	link_directories(${CMAKE_PREFIX_PATH}/lib)

	if(SDL2_FOUND)
		# Using shared SDL2
		set(LIBS	${LIBS} ${SDL2_LIBRARY})
	else(SDL2_FOUND)
		if(SDL_FOUND)
			# Using shared SDL
			set(LIBS	${LIBS} ${SDL_LIBRARY})
		else(SDL_FOUND)
			# Using static SDL from Externals
			set(LIBS	${LIBS} SDL)
		endif()
	endif()
else()
	set(LIBS ${LIBS} png iconv)
endif()

set(EXEGUI dolphin-emu-qt)

if(LIBAV_FOUND)
	set(LIBS	${LIBS} ${LIBAV_LIBRARIES})
endif()

qt_moc(MOC_SRCS Src/Config/ConfigAudio.h
                Src/Config/ConfigGeneral.h
                Src/Config/ConfigGfx.h
                Src/Config/ConfigMain.h
                Src/Config/ConfigPad.h
                Src/Config/ConfigWiimote.h
                Src/GameList/GameTracker.h
                Src/GameList/GameTree.h
                Src/GameList/GameGrid.h
                Src/Util/Util.h
                Src/LogWidgets.h
                Src/MainWindow.h
                Src/RenderWidget.h
                Src/SystemInfo.h)
qt_ui(UIC_SRCS Src/MainWindow.ui
               Src/LogWindow.ui
               Src/LogSettings.ui
               Src/GameList/GameTree.ui
                Src/GameList/GameGrid.ui
               Src/SystemInfo.ui)
qt_res(QRC_SRCS Resources/Resources.qrc)

add_executable(${EXEGUI} ${SRCS} ${MOC_SRCS} ${UIC_SRCS} ${QRC_SRCS})
target_link_libraries(${EXEGUI} ${LIBS} ${QT_LIBS})
#install(TARGETS ${EXEGUI} RUNTIME DESTINATION ${bindir})
