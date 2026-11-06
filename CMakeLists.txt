cmake_minimum_required(VERSION 3.21)
project(MyCustomClient)

if ("${CMAKE_SYSTEM_NAME}" STREQUAL "iOS" OR IOS)
    set(CMAKE_OSX_ARCHITECTURES "arm64")
endif()

# Добавляем исходные файлы
add_library(${PROJECT_NAME} SHARED
    src/main.cpp
    src/Noclip.cpp
    src/AutoBot.cpp
)
