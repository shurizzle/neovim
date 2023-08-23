set(LUA_ZLIB_CFLAGS
  -O3
  -Wall
  -pedantic
  -I${DEPS_INSTALL_DIR}/include)

if(USE_BUNDLED_LUAJIT)
  list(APPEND LUA_ZLIB_CFLAGS -I${DEPS_INSTALL_DIR}/include/luajit-2.1)
else()
  find_package(Luajit)
  if(LUAJIT_FOUND)
    foreach(d ${LUAJIT_INCLUDE_DIRS})
      list(APPEND LUA_ZLIB_CFLAGS "-I${d}")
    endforeach()
  else()
    find_package(PkgConfig REQUIRED)
    pkg_search_module(LUA REQUIRED lua)
    foreach(d ${LUA_INCLUDE_DIR})
      list(APPEND LUA_ZLIB_CFLAGS "-I${d}")
    endforeach()
  endif()
endif()

if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
  list(APPEND LUA_ZLIB_CFLAGS -fno-common)
endif()

set(LUA_ZLIB_ENV)
if(LUA_ZLIB_ENV)
  set(LUA_ZLIB_ENV env MACOSX_DEPLOYMENT_TARGET=10.4)
endif()

set(LUA_ZLIB_COMPILE
  ${LUA_ZLIB_ENV}
  ${CMAKE_C_COMPILER}
  ${LUA_ZLIB_CFLAGS}
  -c -o luazlib.o
  lua_zlib.c)
set(LUA_ZLIB_MKLIB ${CMAKE_AR} rcs libluazlib.a luazlib.o)
set(LUA_ZLIB_MKDIRP mkdir -p "${DEPS_INSTALL_DIR}/lib")
set(LUA_ZLIB_INSTALL cp libluazlib.a "${DEPS_INSTALL_DIR}/lib/")

ExternalProject_Add(lua-zlib-static
  URL                  ${LUA_ZLIB_URL}
  URL_HASH             SHA256=${LUA_ZLIB_SHA256}
  DOWNLOAD_NO_PROGRESS TRUE
  BUILD_IN_SOURCE      1
  DOWNLOAD_DIR         ${DEPS_DOWNLOAD_DIR}/lua-zlib
  CMAKE_ARGS           ${DEPS_CMAKE_ARGS} ${LUA_ZLIB_CMAKE_ARGS}
  CMAKE_CACHE_ARGS     ${DEPS_CMAKE_CACHE_ARGS}
  CONFIGURE_COMMAND    ""
  BUILD_COMMAND        ${LUA_ZLIB_COMPILE}
    COMMAND            ${LUA_ZLIB_MKLIB}
  INSTALL_COMMAND      ${LUA_ZLIB_MKDIRP}
    COMMAND            ${LUA_ZLIB_INSTALL}
  TEST_COMMAND         "")

if(USE_BUNDLED_LUAJIT)
  add_dependencies(lua-zlib-static luajit)
elseif(USE_BUNDLED_LUA)
  add_dependencies(lua-zlib-static lua)
endif()
if(USE_BUNDLED_ZLIB)
  add_dependencies(lua-zlib-static zlib-static)
endif()
