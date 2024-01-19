include(ExternalProject)
include(GNUInstallDirs)

set(SC_HAVE_ZLIB 1 CACHE BOOL "using SC-built Zlib")

# default zlib source archive
if (NOT DEFINED SC_BUILD_ZLIB_ARCHIVE_FILE)
  if (NOT DEFINED SC_BUILD_ZLIB_VERSION)
    set(SC_BUILD_ZLIB_VERSION 2.1.6)
  endif()
  set(SC_BUILD_ZLIB_ARCHIVE_FILE https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${SC_BUILD_ZLIB_VERSION}.tar.gz CACHE STRING "zlib source archive (URL or local filepath).")
endif()

set(ZLIB_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include)

if(BUILD_SHARED_LIBS)
  if(WIN32)
    set(ZLIB_LIBRARIES ${CMAKE_INSTALL_FULL_BINDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}zlib1${CMAKE_SHARED_LIBRARY_SUFFIX})
  else()
    set(ZLIB_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}z${CMAKE_SHARED_LIBRARY_SUFFIX})
  endif()
else()
  if(MSVC)
    set(ZLIB_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic${CMAKE_STATIC_LIBRARY_SUFFIX})
  else()
    set(ZLIB_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}z${CMAKE_STATIC_LIBRARY_SUFFIX})
  endif()
endif()

set(zlib_cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=Release
-DZLIB_COMPAT:BOOL=on
-DZLIB_ENABLE_TESTS:BOOL=off
-DZLIBNG_ENABLE_TESTS:BOOL=off
-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
)

ExternalProject_Add(ZLIB
URL ${SC_BUILD_ZLIB_ARCHIVE_FILE}
CMAKE_ARGS ${zlib_cmake_args}
BUILD_BYPRODUCTS ${ZLIB_LIBRARIES}
CONFIGURE_HANDLED_BY_BUILD ON
INACTIVITY_TIMEOUT 60
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
USES_TERMINAL_TEST true
)


# --- imported target

file(MAKE_DIRECTORY ${ZLIB_INCLUDE_DIRS})
# avoid race condition

add_library(ZLIB::ZLIB INTERFACE IMPORTED GLOBAL)
add_dependencies(ZLIB::ZLIB ZLIB)  # to avoid include directory race condition
target_link_libraries(ZLIB::ZLIB INTERFACE ${ZLIB_LIBRARIES})
target_include_directories(ZLIB::ZLIB INTERFACE ${ZLIB_INCLUDE_DIRS})
