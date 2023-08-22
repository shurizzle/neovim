# if(USE_BUNDLED_LUAJIT)
#   list(APPEND LUA_OPENSSL_MAKE_ARGS -D WITH_LUA_ENGINE=LuaJit)
# elseif(USE_BUNDLED_LUA)
#   list(APPEND LUA_OPENSSL_MAKE_ARGS -D WITH_LUA_ENGINE=Lua)
# else()
#   find_package(Luajit)
#   if(LUAJIT_FOUND)
#     list(APPEND LUA_OPENSSL_MAKE_ARGS -D WITH_LUA_ENGINE=LuaJit)
#   else()
#     list(APPEND LUA_OPENSSL_MAKE_ARGS -D WITH_LUA_ENGINE=Lua)
#   endif()
# endif()

# list(APPEND LUA_OPENSSL_CMAKE_ARGS
#   "-DCMAKE_C_FLAGS:STRING=${LUV_INCLUDE_FLAGS}")
# if(CMAKE_GENERATOR MATCHES "Unix Makefiles" AND
#     (CMAKE_SYSTEM_NAME MATCHES ".*BSD" OR CMAKE_SYSTEM_NAME MATCHES "DragonFly"))
#     list(APPEND LUA_OPENSSL_CMAKE_ARGS -D CMAKE_MAKE_PROGRAM=gmake)
# endif()

if(CMAKE_SYSTEM_NAME MATCHES ".*BSD" OR CMAKE_SYSTEM_NAME MATCHES "DragonFly")
  set(LUA_OPENSSL_MAKE_CMD "gmake")
else()
  set(LUA_OPENSSL_MAKE_CMD "make")
endif()

set(LUA_OPENSSL_MAKE_ARGS
  -E "CFLAGS=-O3 -I${DEPS_INSTALL_DIR}/include"
  -E LDFLAGS=
  CC=${CMAKE_C_COMPILER}
  LD=${TOOLCHAIN_LD}
  PREFIX=${DEPS_INSTALL_DIR}
  LUA_LIBDIR=${DEPS_INSTALL_DIR}/lib/lua)

if(USE_BUNDLED_OPENSSL)
  list(APPEND LUA_OPENSSL_MAKE_ARGS
    OPENSSL_LIBDIR="${DEPS_INSTALL_DIR}/lib"
    OPENSSL_STATIC=true)
endif()

ExternalProject_Add(lua-openssl-static
  URL                  ${LUA_OPENSSL_URL}
  URL_HASH             SHA256=${LUA_OPENSSL_SHA256}
  DOWNLOAD_NO_PROGRESS TRUE
  BUILD_IN_SOURCE      1
  DOWNLOAD_DIR         ${DEPS_DOWNLOAD_DIR}/lua-openssl
  CMAKE_ARGS           ${DEPS_CMAKE_ARGS}
  CMAKE_CACHE_ARGS     ${DEPS_CMAKE_CACHE_ARGS}
  CONFIGURE_COMMAND    ""
  BUILD_COMMAND        ${LUA_OPENSSL_MAKE_CMD} ${LUA_OPENSSL_MAKE_ARGS}
  INSTALL_COMMAND      mkdir -p "${DEPS_INSTALL_DIR}/lib"
    COMMAND            cp libopenssl.a "${DEPS_INSTALL_DIR}/lib/libluaopenssl.a"
  TEST_COMMAND         "")

if(USE_BUNDLED_LUAJIT)
  add_dependencies(lua-openssl-static luajit)
elseif(USE_BUNDLED_LUA)
  add_dependencies(lua-openssl-static lua)
endif()
if(USE_BUNDLED_OPENSSL)
  add_dependencies(lua-openssl-static openssl-static)
endif()
