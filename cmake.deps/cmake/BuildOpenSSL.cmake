set(OPENSSL_CONFIG_OPTIONS no-unit-test no-shared no-stdio no-idea no-mdc2 no-rc5 --prefix=${DEPS_INSTALL_DIR} --libdir=lib)

if(WIN32)
  if("${CMAKE_GENERATOR_PLATFORM}" MATCHES "x64")
    set(OPENSSL_CONFIGURE_COMMAND perl ./Configure VC-WIN64A ${OPENSSL_CONFIG_OPTIONS})
  else()
    set(OPENSSL_CONFIGURE_COMMAND perl ./Configure VC-WIN32 ${OPENSSL_CONFIG_OPTIONS})
  endif()
  set(OPENSSL_BUILD_COMMAND nmake)
  set(OPENSSL_INSTALL_COMMAND nmake install_dev)
else()
  set(OPENSSL_CONFIGURE_COMMAND ./config ${OPENSSL_CONFIG_OPTIONS})
  if(DEFINED $ENV{$MAKEFLAGS})
    set(OPENSSL_BUILD_COMMAND make $ENV{MAKEFLAGS})
  else()
    set(OPENSSL_BUILD_COMMAND make)
  endif()
  set(OPENSSL_INSTALL_COMMAND make install_dev)
endif()

ExternalProject_Add(openssl-static
  URL                  ${OPENSSL_URL}
  URL_HASH             SHA256=${OPENSSL_SHA256}
  DOWNLOAD_NO_PROGRESS TRUE
  LOG_BUILD            ON
  BUILD_IN_SOURCE      1
  DOWNLOAD_DIR         ${DEPS_DOWNLOAD_DIR}/openssl
  CMAKE_ARGS           ${DEPS_CMAKE_ARGS}
  CMAKE_CACHE_ARGS     ${DEPS_CMAKE_CACHE_ARGS}
  CONFIGURE_COMMAND    ${OPENSSL_CONFIGURE_COMMAND}
  BUILD_COMMAND        ${OPENSSL_BUILD_COMMAND}
  INSTALL_COMMAND      ${OPENSSL_INSTALL_COMMAND}
  TEST_COMMAND         "")

if(USE_BUNDLED_ZLIB)
  add_dependencies(openssl-static zlib-static)
endif()
