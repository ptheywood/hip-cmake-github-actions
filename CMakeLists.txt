# Set the minimum cmake version to that which supports HIP natively.
cmake_minimum_required(VERSION VERSION 3.21 FATAL_ERROR)


# Name the project and set languages
project(main HIP CXX)


# Set a default build type if not passed
set(default_build_type "Release")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release")
endif()

# Define which source files are required for the target executable
set(SRC_INCLUDE
    include/test.hiph
)

set(SRC
    src/main.hip
)

set(ALL_SRC
    ${SRC_INCLUDE}
    ${SRC}
)

# Create the binary target
add_executable(main ${ALL_SRC})
# Add the include dir
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Force hip to be on the path. Ideally it should be on the user to ensure that /opt/rocm or equivalent is on the CMAKE_PREFIX_PATH by default
# Todo: remove this
if(CMAKE_HIP_COMPILER)
    list(APPEND CMAKE_PREFIX_PATH "/opt/rocm")
endif()

# Find and link against hip device
find_package(hip REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE hip::host)
target_link_libraries(${PROJECT_NAME} PRIVATE hip::device)