cmake_minimum_required(VERSION 3.4.1)

add_library(bbhelper SHARED c++/directBufferAndroid.cpp)

target_compile_options(bbhelper PRIVATE -DBUILD_FOR_ANDROID)

# Support for 16KB page sizes - add linker flag for max page size
target_link_options(bbhelper PRIVATE "-Wl,-z,max-page-size=16384")
