find_library(ZLIB_LIBRARY NAMES z_a z libz_a libz.so)
find_package_handle_standard_args(LuaZlib DEFAULT_MSG ZLIB_LIBRARY)
mark_as_advanced(ZLIB_LIBRARY)
