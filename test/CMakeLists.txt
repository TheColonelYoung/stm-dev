
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-arcs -ftest-coverage")
set(CMAKE_CXX_FLAGS " ${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage")

# Set up Catch2 and FakeIt libraries
include(FetchContent)

FetchContent_Declare(
  catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG        v3.3.2
)

FetchContent_Declare(
  fakeit
  GIT_REPOSITORY https://github.com/eranpeer/FakeIt.git
  GIT_TAG        2.0.7
  )

FetchContent_MakeAvailable(catch2)
FetchContent_MakeAvailable(fakeit)

# Glob source files
file(GLOB TEST_SOURCES CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
)

set(SOURCES_UNDER_TEST)
foreach(file ${TEST_SOURCES})
    string(REPLACE "test/test_" "source/App/" new_file "${file}")
    message("Filename without prefix: ${new_file}")

    # Add the modified filename to the new list
    list(APPEND SOURCES_UNDER_TEST ${new_file})
endforeach()

message("New list of files: ${MY_NEW_FILES}")

#add_compile_definitions(test PUBLIC private=public)

# Add the executable for the unit tests
add_executable(test ${TEST_SOURCES} ${SOURCES_UNDER_TEST})

target_include_directories(test PRIVATE ${CMAKE_SOURCE_DIR}/source/App)

# Link the unit tests with the necessary libraries
target_link_libraries(test PRIVATE Catch2::Catch2WithMain)
target_include_directories(test PRIVATE "${fakeit_SOURCE_DIR}/single_header/catch")

# Set up Catch2 to discover and run the tests
list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)
include(CTest)
include(Catch)
catch_discover_tests(test)

# Fix reference to header that was renamed in Catch2 v3.x
add_custom_target(
    fix_fakeit_catch_header
    COMMAND sed -i 's,catch2/catch\.hpp,catch2/catch_all.hpp,' "${fakeit_SOURCE_DIR}/single_header/catch/fakeit.hpp"
)
add_dependencies(test fix_fakeit_catch_header)
