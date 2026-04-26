cmake_minimum_required(VERSION 3.15)
project(Proj LANGUAGES C CXX)

set(CMAKE_POLICY_VERSION_MINIMUM 3.5)

set(BUILD_SHARED_LIBS OFF)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fexceptions")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fexceptions")

include(${CMAKE_SOURCE_DIR}/cmake/AggressiveOptimizations.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/provideLibrarys.cmake)

# Set C++ standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Globale Listen initialisieren
set(INCLUDES "")
set(CPPOBJS "")
set(LINKLIBS "")

# Erstellt Ordner wenn nicht vorhanden
file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty")

set(LIB_OUT "${CMAKE_CURRENT_BINARY_DIR}/libs")
set(THIRD_PARTY "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty")

# -------------------------------------------------------
# Rendering Includes
# -------------------------------------------------------

option(USE_ANGLE "Link gegen ANGLE statt nativen OpenGL-Treiber" OFF)

provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/SDL" "https://github.com/libsdl-org/SDL" "" "" "SDL3-static" "SDL_SHARED=OFF;SDL_STATIC=ON;SDL_TEST=OFF" "")

# Angle downloads über pacman package (msys mingw) oder unter https://github.com/mmozeiko/build-angle/releases/latest (msvc builds)
if(NOT USE_ANGLE)

    provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/raylib" "https://github.com/raysan5/raylib" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/raylib/src" "" "raylib" "OPENGL_VERSION=4.3;BUILD_EXAMPLES=OFF" "tags/6.0") # tags/5.5
else()

    if(NOT DEFINED ANGLE_ROOT)
        message(FATAL_ERROR "USE_ANGLE=ON erfordert -DANGLE_ROOT=<Pfad>")
    endif()
    if(NOT DEFINED ANGLE_INC)
        set(ANGLE_INC "${ANGLE_ROOT}/Include")
    endif()
    if(NOT DEFINED ANGLE_LIB_DIR)
        message(FATAL_ERROR "USE_ANGLE=ON erfordert -DANGLE_LIB_DIR=<Pfad zu .lib-Dateien>")
    endif()
    if(NOT DEFINED ANGLE_DLLS)
        message(FATAL_ERROR "USE_ANGLE=ON erfordert -DANGLE_DLLS=<dll1;dll2;...>")
    endif()

    include_directories("${ANGLE_INC}")

    provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/raylib" "https://github.com/raysan5/raylib" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/raylib/src" "" "raylib" "OPENGL_VERSION=ES 2.0;BUILD_EXAMPLES=OFF" "tags/6.0") # tags/5.5

    find_library(ANGLE_EGL   NAMES EGL   libEGL   HINTS "${ANGLE_LIB_DIR}" REQUIRED)
    find_library(ANGLE_GLES2 NAMES GLESv2 libGLESv2 HINTS "${ANGLE_LIB_DIR}" REQUIRED)

    list(APPEND LINKLIBS ${ANGLE_EGL} ${ANGLE_GLES2})

endif()

# Imgui + verwendete Extensions
getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/imgui" "https://github.com/ocornut/imgui" "")
getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/implot" "https://github.com/epezent/implot" "")
getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/imgui-filebrowser" "https://github.com/AirGuanZ/imgui-filebrowser" "")

buildStaticLib(imgui "${THIRD_PARTY}/imgui" "${THIRD_PARTY}/imgui" "imgui.cpp;imgui_draw.cpp;imgui_tables.cpp;imgui_widgets.cpp;imgui_demo.cpp" "" "${LIB_OUT}")
buildStaticLib(implot "${THIRD_PARTY}/implot" "${THIRD_PARTY}/implot" "implot.cpp;implot_items.cpp" "imgui" "${LIB_OUT}")
# imgui-filebrowser ist header only

list(APPEND LINKLIBS imgui implot)
list(APPEND INCLUDES "${THIRD_PARTY}/imgui;${THIRD_PARTY}/implot;${THIRD_PARTY}/imgui-filebrowser")

# Imgui Integration Includes (Integration in Raylib)
getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/rlImGui" "https://github.com/raylib-extras/rlImGui" "")
buildStaticLib(rlImGui "${THIRD_PARTY}/rlImGui" "${THIRD_PARTY}/rlImGui" "rlImGui.cpp" "imgui;raylib" "${LIB_OUT}")

list(APPEND LINKLIBS rlImGui)
# rlImgui Includes liegen direkt unter thirdParty/rlImgui/rlImgui.h

# -------------------------------------------------------
# Procedural Generation Includes
# -------------------------------------------------------

# fastNoise2 für PerlinNoise, ...
provideLib("${THIRD_PARTY}/FastNoise2" "https://github.com/Auburn/FastNoise2" "${THIRD_PARTY}/FastNoise2/include" "" "FastNoise2" "" "")

# Delaunator für Delauny Triangulation
getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/delaunator-cpp" "https://github.com/delfrrr/delaunator-cpp" "")
list(APPEND INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/delaunator-cpp/include")

# fast-wcf für Wavefunctioncollapse
provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/fast-wcf" "https://github.com/math-fehr/fast-wfc" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/raylib/src" "" "fastwfc_static" "" "")

# -------------------------------------------------------
# Recchandling / Modding Includes
# -------------------------------------------------------

# Alberich Inlude inklusive ByteSequence, magic_enum und boost::pfr (magit_get)

# provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/ByteSequence" "https://github.com/tr3dh/ByteSequence.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/ByteSequence/src" "" "ByteSequence" "" "")
provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/Alberich" "https://github.com/tr3dh/Alberich.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/Alberich/src" "" "alberich" "" "")
provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/pybind11" "https://github.com/pybind/pybind11" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/pybind11/include" "" "pybind11::embed" "" "")

# nlohmann::json
provideHeaderOnlyLib("thirdParty/json" "https://github.com/nlohmann/json.git" "thirdParty/json/include" "" "")

# entt (ECS)
provideHeaderOnlyLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/entt" "https://github.com/skypjack/entt" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/entt/src" "" "")

# spdlog für verbessertes Logging
provideLib("thirdParty/spdlog" "https://github.com/gabime/spdlog" "thirdParty/spdlog/src" "" "spdlog" "" "")

# -------------------------------------------------------
# Networking Includes
# -------------------------------------------------------

#  Enet (für reliable UDP)
provideLib("thirdParty/enet" "https://github.com/lsalzman/enet.git" "thirdParty/enet/include" "" "enet" "" "")

# -------------------------------------------------------
# Physics Includes
# -------------------------------------------------------

# Jolt Physics für Physics Sims, Raycasting, Collisions, etc.
getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/JoltPhysics" "https://github.com/jrouwe/JoltPhysics.git" "")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/JoltPhysics/Build")

list(APPEND INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/JoltPhysics")
list(APPEND LINKLIBS "Jolt")

# -------------------------------------------------------
# Maths Includes
# -------------------------------------------------------

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

    # Funktioniert nur für Msys Mingw
    # für msvc müssten gmp prebuild binaries heruntergeladen und eingebunden werden
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(GMP REQUIRED gmp gmpxx)

    list(APPEND LINKLIBS GMP)

    # SymEngine (GMP Backend)
    provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/symengine" "https://github.com/symengine/symengine" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/symengine" "" "symengine"
        "WITH_GMP=ON;WITH_MPFR=ON;WITH_SYMENGINE_THREAD_SAFE=ON;BUILD_TESTING=OFF;SymEngine_INSTALL=OFF"
        "")
    
endif()

provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/eigen" "https://github.com/PX4/eigen.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/eigen" "" "eigen"
    "BUILD_TESTING=OFF;EIGEN_BUILD_DOC=OFF;EIGEN_BUILD_PKGCONFIG=OFF" "")

provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/kompute" "https://github.com/KomputeProject/kompute.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/kompute/src/include" 
    "" "kompute" "BUILD_TESTING=OFF;KP_BUILD_PYTHON=OFF;KP_BUILD_BENCHMARKS=OFF;KP_BUILD_EXAMPLES=OFF" "")

# -------------------------------------------------------
# Embedding Includes
# -------------------------------------------------------

if(WIN32)

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(STEAM_PLATFORM "win64")
    else()
        set(STEAM_PLATFORM "win32")
    endif()

    set(STEAM_LIB_NAME "steam_api64.lib")
    set(STEAM_DLL_NAME "steam_api64.dll")

endif()

# Steam über name als prebuildLib einginden
includePrebuildLib(steamSkd "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/sdk/public" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/sdk/redistributable_bin/${STEAM_PLATFORM}/${STEAM_LIB_NAME}")

# -------------------------------------------------------
# Source Code
# -------------------------------------------------------

# SRC berücksichtigen
file(GLOB_RECURSE SRC_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h" "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp")
file(GLOB_RECURSE SRC_CPPS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
list(APPEND INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/src")

#
foreach(cpp ${SRC_CPPS})
    list(APPEND CPPOBJS ${cpp})
endforeach()

message(STATUS "Added ${CMAKE_LIST_LENGTH} header files from src/ to INCLUDES")
message(STATUS "Added ${CMAKE_LIST_LENGTH} cpp files from src/ to CPPOBJS")

# Debug-Ausgabe
message(STATUS "CPPOBJS contains: ${CPPOBJS}")
message(STATUS "INCLUDES contains: ${INCLUDES}")
message(STATUS "LINKLIBS contains: ${LINKLIBS}")

# Create your executable
add_executable(proj ${CPPOBJS} Recc/Compilation/recc.rc)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Building in DEBUG mode")

elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message(STATUS "Building in RELEASE mode")

    set_target_properties(proj PROPERTIES
        WIN32_EXECUTABLE TRUE
    )

    # Nur für MSVC
    if(MSVC OR CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set_target_properties(proj PROPERTIES
            LINK_FLAGS "/SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup"
        )
    # Nur für GCC / Clang
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_link_options(proj PRIVATE -mwindows)
    endif()

    apply_aggressive_optimizations(proj)

elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    message(STATUS "Building in RELEASE WITH DEBUG INFO mode")

elseif(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    message(STATUS "Building in MINIMUM SIZE RELEASE mode")

endif()

target_compile_options(proj PRIVATE
    $<$<CXX_COMPILER_ID:MSVC>:/GR- /EHs- /EHc->
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-fno-rtti -fno-exceptions>
    -fexceptions 
)

#
target_link_libraries(proj

    PRIVATE
    -static
    ${LINKLIBS}
)

#
target_include_directories(proj

    PRIVATE
    ${INCLUDES}
)

# Kopiert Steam DLL
add_custom_command(TARGET proj POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/thirdParty/sdk/redistributable_bin/${STEAM_PLATFORM}/${STEAM_DLL_NAME}"
        $<TARGET_FILE_DIR:proj>
    COMMENT "Copying DLLS"
)

# Legt steam_appid file an damit Steam API default ID findet und Start nicht terminiert
add_custom_command(TARGET proj POST_BUILD

    COMMAND ${CMAKE_COMMAND} -E echo "480" > $<TARGET_FILE_DIR:proj>/steam_appid.txt
    COMMENT "Generating SteamAppId.txt"
)

if(USE_ANGLE)

    # Kopiere DLLS postbuild
    foreach(_dll IN LISTS ANGLE_DLLS)

        # if(NOT IS_ABSOLUTE "${_dll}")

        #     set(_dll "${ANGLE_LIB_DIR}/${_dll}")
        # endif()
        
        add_custom_command(TARGET proj POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${_dll}"
                "$<TARGET_FILE_DIR:proj>"
            COMMENT "Kopiere ANGLE DLL: ${_dll}")
    endforeach()
endif()