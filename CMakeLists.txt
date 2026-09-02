cmake_minimum_required(VERSION 3.15)

project(Proj LANGUAGES C CXX)

set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
set(CMAKE_SKIP_INSTALL_RULES TRUE)

set(BUILD_SHARED_LIBS OFF)

if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

if(NOT MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fexceptions")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fexceptions")
endif()

include(${CMAKE_SOURCE_DIR}/cmake/AggressiveOptimizations.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/provideLibrarys.cmake)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Globale Listen initialisieren
set(INCLUDES "")
set(CPPOBJS "")
set(LINKLIBS "")
set(DLLS "")

# Erstellt Ordner wenn nicht vorhanden
file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty")

set(LIB_OUT "${CMAKE_CURRENT_BINARY_DIR}/libs")
set(THIRD_PARTY "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty")

# -------------------------------------------------------
# Vorgezogenen Includes gegen Target Mehrfachdefinitionen
# -------------------------------------------------------

# Sowohl eigen als auch rebelfork versuchen ein 'uninstall' Target zu erstellen
# Eigen führt dabei keinen check aus ob das target schon existiert,
# Die rebelfork abhängigkeit schon. Deshalb wird zuerst Eigen hinzugefügt, um Konflikte zu vermeiden 

# provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/eigen" "https://github.com/PX4/eigen.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/eigen" "" "eigen"
#     "BUILD_TESTING=OFF;EIGEN_BUILD_DOC=OFF;EIGEN_BUILD_PKGCONFIG=OFF" "")

# -------------------------------------------------------
# Rendering Includes
# -------------------------------------------------------

option(USE_ANGLE "Link gegen ANGLE statt nativen OpenGL-Treiber" OFF)

# Angle downloads über pacman package (msys mingw) oder unter https://github.com/mmozeiko/build-angle/releases/latest (msvc builds)
if(NOT USE_ANGLE)

    provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/raylib" "https://github.com/raysan5/raylib" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/raylib/src" "" "raylib" "OPENGL_VERSION=4.3;BUILD_EXAMPLES=OFF" "tags/6.0") # tags/5.5
    # provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/r3d" "https://github.com/Bigfoot71/r3d" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/r3d/include" "" "r3d" "" "") # tags/5.5
    
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
    # provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/r3d" "https://github.com/Bigfoot71/r3d" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/r3d/include" "" "r3d" "" "") # tags/5.5

    find_library(ANGLE_EGL   NAMES EGL   libEGL   HINTS "${ANGLE_LIB_DIR}" REQUIRED)
    find_library(ANGLE_GLES2 NAMES GLESv2 libGLESv2 HINTS "${ANGLE_LIB_DIR}" REQUIRED)

    list(APPEND LINKLIBS ${ANGLE_EGL} ${ANGLE_GLES2})

endif()

# Einkommentieren für rbfx
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# #
# provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/rbfx" "https://github.com/rbfx/rbfx"
#             "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/rbfx/Source"
#             "" "Urho3D" "URHO3D_VULKAN=1;RBFX_SKIP_INSTALL=ON;URHO3D_SAMPLES=ON" "")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/SDL" "https://github.com/libsdl-org/SDL" "" "" "SDL3-static" "SDL_SHARED=OFF;SDL_STATIC=ON;SDL_TEST=OFF" "")

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

# Die Einbettung von Julia erfordert das Hinterlegen einer Julia-Runtime unter 'thirdParty/julia'

# Julia
set(JULIA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/julia")

if(EXISTS "${JULIA_ROOT}")

    add_library(julia SHARED IMPORTED)
    set_target_properties(julia PROPERTIES IMPORTED_IMPLIB "${JULIA_ROOT}/lib/libjulia.dll.a" IMPORTED_LOCATION "${JULIA_ROOT}/bin/libjulia.dll")
    target_include_directories(julia INTERFACE "${JULIA_ROOT}/include" "${JULIA_ROOT}/include/julia")
    set_property(TARGET julia APPEND PROPERTY INTERFACE_VS_DEBUGGER_ENVIRONMENT "PATH=${JULIA_ROOT}/bin;%PATH%")

    list(APPEND LINKLIBS julia)

    # Julia-Installation in den Build-Ordner kopieren
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/julia/lib/julia" DESTINATION "${CMAKE_BINARY_DIR}")

    # Julia-Installation in den Build-Ordner kopieren
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/julia/bin/" DESTINATION "${CMAKE_BINARY_DIR}")

endif()

# nlohmann::json
provideHeaderOnlyLib("thirdParty/json" "https://github.com/nlohmann/json.git" "thirdParty/json/include" "" "")

# entt (ECS)
provideHeaderOnlyLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/entt" "https://github.com/skypjack/entt" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/entt/single_include/" "" "")

# flecs (ECS)
provideLib(
    "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/flecs" "https://github.com/SanderMertens/flecs.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/flecs/include" "" "flecs::flecs_static"
    "FLECS_STATIC=ON;FLECS_SHARED=OFF;FLECS_TESTS=OFF;FLECS_BENCHMARK=OFF;FLECS_DOCS=OFF" "v4.0.3"
)

# # spdlog für verbessertes Logging
# provideLib("thirdParty/spdlog" "https://github.com/gabime/spdlog" "thirdParty/spdlog/src" "" "spdlog" "" "")

# sql lite cpp
provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/SQLiteCpp" "https://github.com/SRombauts/SQLiteCpp" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/SQLiteCpp/include" "" "SQLiteCpp" "" "")

# cs_libguarded
getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/cs_libguarded" "https://github.com/copperspice/cs_libguarded.git" "")
list(APPEND INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/cs_libguarded/src")

# -------------------------------------------------------
# Networking Includes
# -------------------------------------------------------

#  Enet (für reliable UDP)
provideLib("thirdParty/enet" "https://github.com/lsalzman/enet.git" "thirdParty/enet/include" "" "enet" "" "")

# -------------------------------------------------------
# Physics Includes
# -------------------------------------------------------

# # Jolt Physics für Physics Sims, Raycasting, Collisions, etc.
# getLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/JoltPhysics" "https://github.com/jrouwe/JoltPhysics.git" "")
# add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/JoltPhysics/Build")

# list(APPEND INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/JoltPhysics")
# list(APPEND LINKLIBS "Jolt")

# -------------------------------------------------------
# Maths Includes
# -------------------------------------------------------

# GMP kann für MSVC als fertiger prebuild beschafft unter 'thirdParty' abgelegt und per 'includePrebuildLib' eingebunden werden
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

provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/kompute" "https://github.com/KomputeProject/kompute.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/kompute/src/include" 
    "" "kompute" "BUILD_TESTING=OFF;KP_BUILD_PYTHON=OFF;KP_BUILD_BENCHMARKS=OFF;KP_BUILD_EXAMPLES=OFF" "")

# -------------------------------------------------------
# Numerische Includes
# -------------------------------------------------------

# Petsc

set(PETSC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/petsc" CACHE STRING "" FORCE)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")

    list(APPEND INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/petsc/arch-mswin-c-debug/include")
    set(PETSC_ARCH "arch-mswin-c-debug" CACHE STRING "" FORCE)
else()

    list(APPEND INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/petsc/arch-mswin-c-opt/include")
    set(PETSC_ARCH "arch-mswin-c-opt" CACHE STRING "" FORCE)
endif()

list(APPEND CMAKE_PREFIX_PATH
    "${PETSC_DIR}/${PETSC_ARCH}"
)

# MFEM

provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/mfem" "https://github.com/mfem/mfem"
            "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty;${mfem_BINARY_DIR}/config" "" "mfem"
            "MFEM_USE_MPI=ON;MFEM_USE_METIS=ON;MFEM_USE_METIS_5=ON;MFEM_USE_PETSC=ON;\
HYPRE_DIR=${PETSC_DIR}/${PETSC_ARCH};\
METIS_DIR=${PETSC_DIR}/${PETSC_ARCH};\
PETSC_DIR=${PETSC_DIR};\
PETSC_ARCH=${PETSC_ARCH}"
            "tags/v4.9")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Diesen Eigen Include aufgrund kollidierender Targets rausnehmen
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/eigen" "https://github.com/PX4/eigen.git" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/eigen" "" "eigen"
#     "BUILD_TESTING=OFF;EIGEN_BUILD_DOC=OFF;EIGEN_BUILD_PKGCONFIG=OFF" "")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

# # -------------------------------------------------------
# # LLVM
# # -------------------------------------------------------

# find_package(LLVM REQUIRED CONFIG)

# list(APPEND INCLUDES "${LLVM_INCLUDE_DIRS}")

# separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
# add_definitions(${LLVM_DEFINITIONS_LIST})

# llvm_map_components_to_libnames(LLVM_LIBS
#     core
#     orcjit
#     native
#     passes
#     irreader
# )

# list(APPEND LINKLIBS "${LLVM_LIBS}")

# -------------------------------------------------------
# Testing
# -------------------------------------------------------

provideLib("${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/googletest" "https://github.com/google/googletest" "${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/googletest/include" "" ""
    "" "")

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

add_library(srclib STATIC ${CPPOBJS})

target_compile_options(srclib PUBLIC
    $<$<CXX_COMPILER_ID:MSVC>:/EHsc /GR>
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-fexceptions>
)

# target_link_options(srclib PUBLIC -Wl,--allow-multiple-definition)

target_link_libraries(srclib PUBLIC ${LINKLIBS})
target_include_directories(srclib PUBLIC ${INCLUDES})

get_filename_component(MINGW_BIN "${CMAKE_C_COMPILER}" DIRECTORY)

list(APPEND DLLS
    "${MINGW_BIN}/libgcc_s_seh-1.dll"
    "${MINGW_BIN}/libstdc++-6.dll"
    "${MINGW_BIN}/libwinpthread-1.dll"
    "${MINGW_BIN}/libmetis.dll"
    "${MINGW_BIN}/libparmetis.dll"
    "${MINGW_BIN}/libHYPRE.dll"
    "${MINGW_BIN}/libopenblas.dll"
    "${MINGW_BIN}/libgfortran-5.dll"
    "${MINGW_BIN}/libgomp-1.dll"
    "${MINGW_BIN}/libsuperlu_dist.dll"
    "${MINGW_BIN}/libquadmath-0.dll"
    # "${MINGW_BIN}/libgmp-10.dll"
    # "${MINGW_BIN}/libmpfr-6.dll"
    # "${MINGW_BIN}/glfw3.dll"
    # "${MINGW_BIN}/libfreetype-6.dll"
    # "${MINGW_BIN}/libbrotlidec.dll"
    # "${MINGW_BIN}/libbrotlicommon.dll"
    # "${MINGW_BIN}/libbz2-1.dll"
    # "${MINGW_BIN}/libharfbuzz-0.dll"
    # "${MINGW_BIN}/libpng16-16.dll"
    # "${MINGW_BIN}/zlib1.dll"
    # "${MINGW_BIN}/libglib-2.0-0.dll"
    # "${MINGW_BIN}/libgraphite2.dll"
    # "${MINGW_BIN}/libintl-8.dll"
    # "${MINGW_BIN}/libiconv-2.dll"
    # "${MINGW_BIN}/libpcre2-8-0.dll"
    # "${MINGW_BIN}/libLLVM-20.dll"
    # "${MINGW_BIN}/libxml2-16.dll"
    # "${MINGW_BIN}/libGLESv2.dll"
    # "${MINGW_BIN}/libEGL.dll"
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")

    apply_aggressive_optimizations(srclib)
endif()

file(GLOB PROC_SOURCES "Procs/native/*.cpp")

foreach(procSrc IN LISTS PROC_SOURCES)

    get_filename_component(proc ${procSrc} NAME_WE)

endforeach()

file(GLOB_RECURSE PROC_SOURCES "Procs/*.cpp")

foreach(proc_src IN LISTS PROC_SOURCES)

    get_filename_component(proc_name ${proc_src} NAME_WE)

    add_executable(${proc_name} ${proc_src} Recc/Compilation/recc.rc)

    # if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Building in DEBUG mode")

    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        message(STATUS "Building in Debug mode")

    elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
        message(STATUS "Building in RELEASE mode")

        if(NOT proc_src MATCHES ".*/native/.*")

        else()

            set_target_properties(${proc_name} PROPERTIES
                WIN32_EXECUTABLE TRUE
            )

        endif()

        if(NOT proc_src MATCHES ".*/native/.*")

        # Nur für MSVC
        elseif(MSVC OR CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            set_target_properties(${proc_name} PROPERTIES
                LINK_FLAGS "/SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup"
            )
        # Nur für GCC / Clang
        elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            target_link_options(${proc_name} PRIVATE -mwindows)
        endif()

        apply_aggressive_optimizations(${proc_name})

    elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
        message(STATUS "Building in RELEASE WITH DEBUG INFO mode")

    elseif(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
        message(STATUS "Building in MINIMUM SIZE RELEASE mode")

    endif()

    #
    target_link_libraries(${proc_name} PUBLIC srclib)

    # Kopiert Steam DLL
    add_custom_command(TARGET ${proc_name} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_SOURCE_DIR}/thirdParty/sdk/redistributable_bin/${STEAM_PLATFORM}/${STEAM_DLL_NAME}"
            $<TARGET_FILE_DIR:${proc_name}>
        COMMENT "Copying DLLS"
    )

    # Legt steam_appid file an damit Steam API default ID findet und Start nicht terminiert
    add_custom_command(TARGET ${proc_name} POST_BUILD

        COMMAND ${CMAKE_COMMAND} -E echo "480" > $<TARGET_FILE_DIR:${proc_name}>/steam_appid.txt
        COMMENT "Generating SteamAppId.txt"
    )

    # Einkommentieren für rbfx
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # # Nach add_subdirectory(rbfx)
    # add_custom_command(TARGET ${proc_name} POST_BUILD
    #     COMMAND ${CMAKE_COMMAND} -E copy_directory
    #         ${CMAKE_SOURCE_DIR}/thirdParty/rbfx/bin/CoreData
    #         $<TARGET_FILE_DIR:${proc_name}>/CoreData
    #     COMMAND ${CMAKE_COMMAND} -E copy_directory
    #         ${CMAKE_SOURCE_DIR}/thirdParty/rbfx/bin/Data
    #         $<TARGET_FILE_DIR:${proc_name}>/Data
    # )

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if(USE_ANGLE)

        # Kopiere DLLS postbuild
        foreach(_dll IN LISTS ANGLE_DLLS)

            # if(NOT IS_ABSOLUTE "${_dll}")

            #     set(_dll "${ANGLE_LIB_DIR}/${_dll}")
            # endif()
            
            add_custom_command(TARGET ${proc_name} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "${_dll}"
                    "$<TARGET_FILE_DIR:${proc_name}>"
                COMMENT "Kopiere ANGLE DLL: ${_dll}")
        endforeach()
    endif()

    # Kopiere DLLS postbuild
    foreach(_dll IN LISTS DLLS)

        # if(NOT IS_ABSOLUTE "${_dll}")

        #     set(_dll "${ANGLE_LIB_DIR}/${_dll}")
        # endif()
        
        add_custom_command(TARGET ${proc_name} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${_dll}"
                "$<TARGET_FILE_DIR:${proc_name}>"
            COMMENT "Kopiere ANGLE DLL: ${_dll}")
    endforeach()

endforeach()

enable_testing()

file(GLOB_RECURSE TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp")

if(TEST_SOURCES)

    add_executable(execTests ${TEST_SOURCES} Recc/Compilation/recc.rc)

    #
    target_link_libraries(execTests PRIVATE srclib GTest::gtest_main)

    include(GoogleTest)
    gtest_discover_tests(execTests)
endif()

#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/launchWrapTests.cpp" "
#include <cstdlib>
int main() {
    std::system(\"execTests.exe\");
    std::system(\"pause\");
    return 0;
}
")

#
add_executable(launchWrapTests "${CMAKE_CURRENT_BINARY_DIR}/launchWrapTests.cpp" Recc/Compilation/recc.rc)
set_target_properties(launchWrapTests PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")