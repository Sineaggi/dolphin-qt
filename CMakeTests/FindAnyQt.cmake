# Find any valid version of Qt (4 or 5)

find_package(Qt5Core QUIET)
if(Qt5Core_FOUND)
	cmake_minimum_required(VERSION 2.8.11 FATAL_ERROR)

    find_package(Qt5Gui REQUIRED)
    find_package(Qt5Widgets REQUIRED)
    set(QT_FOUND_OK TRUE)
    set(QT5 TRUE)
    set(QT4 FALSE)
	set(QT_LIBRARIES ${Qt5Widgets_LIBRARIES} ${Qt5Gui_LIBRARIES} ${Qt5Core_LIBRARIES} qtmain)
	message("Qt5 found, enabling Qt GUI.")

    macro(qt_res)
        qt5_add_resources(${ARGN})
    endmacro()

    macro(qt_moc)
        qt5_wrap_cpp(${ARGN})
    endmacro()

    macro(qt_ui)
        qt5_wrap_ui(${ARGN})
    endmacro()
else()
    find_package(Qt4 4.8.0 COMPONENTS QtCore QtGui REQUIRED)
    if(QT4_FOUND AND QT_QTCORE_FOUND AND QT_QTGUI_FOUND)
      set(QT_FOUND_OK TRUE)
      set(QT5 FALSE)
      set(QT4 TRUE)
    endif()
	include(${QT_USE_FILE})

    set(QT_USE_QTNETWORK FALSE)
    set(QT_USE_QTOPENGL FALSE)
    set(QT_USE_QTSQL FALSE)
    set(QT_USE_QTXML FALSE)
    set(QT_USE_QTSVG FALSE)
    set(QT_USE_QTTEST FALSE)
    set(QT_USE_QTDBUS FALSE)
    set(QT_USE_QTSCRIPT FALSE)
    set(QT_USE_QTWEBKIT FALSE)
    set(QT_USE_QTXMLPATTERNS FALSE)
    set(QT_USE_PHONON FALSE)

    macro(qt_res)
        qt4_add_resources(${ARGN})
    endmacro()

    macro(qt_moc)
        qt4_wrap_cpp(${ARGN})
    endmacro()

    macro(qt_ui)
        qt4_wrap_ui(${ARGN})
    endmacro()
endif()