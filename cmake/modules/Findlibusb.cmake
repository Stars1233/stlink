# Findlibusb.cmake
# Modern Find module for libusb-1.0
# Defines:
#   - Variables: LIBUSB_FOUND, LIBUSB_INCLUDE_DIR, LIBUSB_LIBRARY
#   - Imported Target: libusb::libusb (recommended)

include(FetchContent)
include(FindPackageHandleStandardArgs)

# Helper function to create imported target
function(create_libusb_target)
    if(NOT TARGET libusb::libusb)
        add_library(libusb::libusb UNKNOWN IMPORTED)
        set_target_properties(libusb::libusb PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${LIBUSB_INCLUDE_DIR}"
        )
        if(WIN32 OR MSVC OR (MINGW AND EXISTS "/etc/debian_version"))
            set_target_properties(libusb::libusb PROPERTIES
                IMPORTED_LOCATION "${LIBUSB_LIBRARY}"
            )
        else()
            set_target_properties(libusb::libusb PROPERTIES
                IMPORTED_LOCATION "${LIBUSB_LIBRARY}"
            )
        endif()
    endif()
endfunction()

# FreeBSD: libusb is integrated into the system
if(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    find_path(LIBUSB_INCLUDE_DIR
        NAMES libusb.h
        HINTS /usr/include
    )

    find_library(LIBUSB_LIBRARY
        NAMES usb
        HINTS /usr /usr/local /opt
    )

# OpenBSD: libusb is available from ports
elseif(CMAKE_SYSTEM_NAME STREQUAL "OpenBSD")
    find_path(LIBUSB_INCLUDE_DIR
        NAMES libusb.h
        HINTS /usr/local/include
        PATH_SUFFIXES libusb-1.0
    )

    find_library(LIBUSB_LIBRARY
        NAMES usb-1.0
        HINTS /usr/local
    )

# Windows, MSVC, or MinGW (including Cross-Compiling from Linux/macOS)
elseif(WIN32 OR MSVC OR MINGW)
    # Fix for ssize_t on Windows
    add_compile_definitions(_SSIZE_T_DEFINED ssize_t=int64_t)

    # 1. Try to find an already installed local Windows version of libusb
    find_path(LIBUSB_INCLUDE_DIR
        NAMES libusb.h
        HINTS "C:/Program Files/libusb-1.0/include" "C:/Program Files (x86)/libusb-1.0/include"
        PATH_SUFFIXES libusb-1.0
    )

    find_library(LIBUSB_LIBRARY
        NAMES usb-1.0 libusb-1.0
        HINTS "C:/Program Files/libusb-1.0" "C:/Program Files (x86)/libusb-1.0"
    )

    # 2. If found locally, set status variables
    if(LIBUSB_INCLUDE_DIR AND LIBUSB_LIBRARY)
        set(LIBUSB_FOUND TRUE)
        set(LIBUSB_INCLUDE_DIRS ${LIBUSB_INCLUDE_DIR})
        set(LIBUSB_LIBRARIES ${LIBUSB_LIBRARY})
    endif()

    # 3. If NOT found (Cross-Compiling host), fetch source and build inline
    if(NOT LIBUSB_FOUND)
        message(STATUS "libusb-1.0 not found locally. Downloading and building from source via FetchContent...")

        include(FetchContent)

        FetchContent_Declare(
            libusb
            GIT_REPOSITORY "https://github.com/libusb/libusb-cmake.git"
            GIT_TAG "v1.0.30-0"
        )
        FetchContent_MakeAvailable(libusb)

        # Fix: FetchContent clones the official libusb repo layout.
        # The main header "libusb.h" resides directly inside the "libusb" subfolder of the source directory.
        set(LIBUSB_INCLUDE_DIR "${libusb_SOURCE_DIR}/libusb")
        set(LIBUSB_INCLUDE_DIRS "${libusb_SOURCE_DIR}/libusb")

        # Fix: Route the linker path to the freshly generated library target
        set(LIBUSB_LIBRARY "libusb-1.0")
        set(LIBUSB_LIBRARIES "libusb-1.0")
        
        set(LIBUSB_FOUND TRUE)
    endif()

# All other Unix-based systems (Linux, macOS, etc.)
else()
    find_package(PkgConfig QUIET)
    if(PKG_CONFIG_FOUND)
        pkg_search_module(PC_LIBUSB QUIET libusb-1.0)
    endif()

    find_path(LIBUSB_INCLUDE_DIR
        NAMES libusb.h
        HINTS ${PC_LIBUSB_INCLUDE_DIRS}
        PATH_SUFFIXES libusb-1.0
    )

    find_library(LIBUSB_LIBRARY
        NAMES usb-1.0
        HINTS ${PC_LIBUSB_LIBRARY_DIRS}
    )
endif()

# Standard argument handling
find_package_handle_standard_args(libusb
    REQUIRED_VARS LIBUSB_INCLUDE_DIR LIBUSB_LIBRARY
)

# Create imported target if found
if(LIBUSB_FOUND)
    create_libusb_target()
    mark_as_advanced(LIBUSB_INCLUDE_DIR LIBUSB_LIBRARY)
endif()
