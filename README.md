# C++ Devstack CMake Starter

# Project Brief

This project is a CMake template that can be used to set up a DevStack consisting primarily of open-source libraries.
The project also sets up a test environment that can be used for CI integration. In addition, the project implements Doxygen automation.

# Usage
The project is primarily designed for use with the MSYS Mingw64 subsystem. It can also be used with MSVC. However, the Mingw subsystem offers a higher degree of automation. Processes such as Doxygen automation, automated icon conversion, release-ready packaging, and GMP provision may need to be performed manually for MSVC or automated independently via a `utils.win.mk` file. The project should also be easily portable to other platforms and compilers. 

## Automated Compilation
The packaging of CMake calls within this project is handled via several compiler- and shell-specific Make targets. Depending on whether `make` is called in a Windows shell or a Mingw shell, different shell- and compiler-specific targets are loaded and made available. Compilation can be performed using the `build` (Debug) and `rbuild` (Release) targets. Compilation followed by execution of a configured target is initiated via `launch` (Debug) and `rlaunch` (Release). Using `build-angle` (specify via Make flags), you can also generate builds with Angle as the rendering backend for Raylib.

## Project Structure

The project allows you to build multiple executables simultaneously. Shared source code can be declared in `src` and is automatically linked during the build into a static library, which is then linked for each executable. The `.cpp` files intended to run as native Windows programs (no console in the release) are placed in `Procs/native`, and console programs in `Procs/console`. Tests for CI integration can be written in `Tests`. All declared tests are called during compilation in the test-executing executable `execTests`. This can also be called via the executable `launchWrapTests`, which simply keeps the console open until user input is received.

## Dependencies

Msys Mingw64 (install via `pacman`):
- GCC, CMake, Make
- GMP, (Angle)
- imagemagick

MSVC (systemwide installation + prebuild binaries in `thirdParty`):
- VS Build Tools
- CMake, Make
- (Angle)

## Mingw Automation

The `utils.mingw64.mk` file also automates several processes within the MSYS Mingw64 subsystem

| Make Target | Function |
|---------|--------|
| `icon` | Converts Recc/Compilation/icon.png to Recc/Compilation/icon.ico |
| `configDocs` | Generates a Doxyfile and substitutes project defaults |
| `clearDocs` | deletes Doxyfile |
| `buildDocs` | builds Doxygen documentation (HTML and LaTeX) |
| `displayDocs` | displays the page stored under `/docs` (displays Doxygen HTML documentation by default) |
| `package` | sorts the relevant binary files into the `__build` directory and compresses them |
| `exportPackage` | Builds the debug and release versions and packages them using the `package` target |

You can also view the available targets at any time by typing `make` followed by `Space`, `Tab`, and `Tab`.

# Releases

For binary releases, the licenses of the libraries used must be checked. GMP, for example, requires that the GMP source code and a relink-gmp.txt file be included when statically linking in binary releases. Additionally, all libraries used should be listed in the `README` and provided via a `Thirdparty-Licenses.md` file or a folder containing the corresponding licenses.

# Used Libraries

The CMake project sets up the open-source libraries on its own; the Steam SDK must be downloaded as a pre-built version directly from Valve.
The complete license texts, as well as the GMP source code and GMP relink instructions, can be found in [thirdPartyLicenses](thirdPartyLicenses/)

| Library | License | Link |
|---------|--------|--------|
| SDL3 | zlib | [libsdl-org/SDL](https://github.com/libsdl-org/SDL) |
| raylib | zlib | [raysan5/raylib](https://github.com/raysan5/raylib) |
| r3d | ZLib license | [bigfoot71/r3d](https://github.com/Bigfoot71/r3d) |
| Dear ImGui | MIT | [ocornut/imgui](https://github.com/ocornut/imgui) |
| ImPlot | MIT | [epezent/implot](https://github.com/epezent/implot) |
| imgui-filebrowser | MIT | [AirGuanZ/imgui-filebrowser](https://github.com/AirGuanZ/imgui-filebrowser) |
| rlImGui | zlib | [raylib-extras/rlImGui](https://github.com/raylib-extras/rlImGui) |
| FastNoise2 | MIT | [Auburn/FastNoise2](https://github.com/Auburn/FastNoise2) |
| delaunator-cpp | ISC | [delfrrr/delaunator-cpp](https://github.com/delfrrr/delaunator-cpp) |
| fast-wfc | MIT | [math-fehr/fast-wfc](https://github.com/math-fehr/fast-wfc) |
| Alberich | MIT | [tr3dh/Alberich](https://github.com/tr3dh/Alberich) |
| pybind11 | BSD-2 | [pybind/pybind11](https://github.com/pybind/pybind11) |
| nlohmann/json | MIT | [nlohmann/json](https://github.com/nlohmann/json) |
| magic_enum | MIT | [magic_enum](https://github.com/Neargye/magic_enum) |
| pfr / magic_get | Boost Software License 1.0 | [Boost.PFR](https://github.com/boostorg/pfr) | 
| ByteSequence | MIT | [tr3dh/ByteSequence](https://github.com/tr3dh/ByteSequence) |
| lsp-framework | MIT                            | [lsp-framework](https://github.com/leon-bckl/lsp-framework) |
| entt | MIT | [skypjack/entt](https://github.com/skypjack/entt) |
| spdlog | MIT | [gabime/spdlog](https://github.com/gabime/spdlog) |
| enet | MIT | [lsalzman/enet](https://github.com/lsalzman/enet) |
| JoltPhysics | MIT | [jrouwe/JoltPhysics](https://github.com/jrouwe/JoltPhysics) |
| GMP | LGPLv3 | [gmplib/gmp](https://gmplib.org/) |
| SymEngine | MIT | [symengine/symengine](https://github.com/symengine/symengine) |
| Eigen3 | MPL2 | [PX4/eigen](https://github.com/PX4/eigen) |
| kompute | Apache-2.0 | [KomputeProject/kompute](https://github.com/KomputeProject/kompute) |
| ANGLE | BSD-3 | [mmozeiko/build-angle](https://github.com/mmozeiko/build-angle) |
| Steam SDK | Steam Subscriber Agreement | [ValveSoftware/steamworks-api](https://github.com/ValveSoftware/steamworks-api) |
| SQLiteCpp | MIT | [SRombauts/SQLiteCpp](https://github.com/SRombauts/SQLiteCpp) |
| googletest | BSD-3-Clause | [google/googletest](https://github.com/google/googletest) |
| cs_libguarded | BSD-2-Clause | [copperspice/cs_libguarded](https://github.com/copperspice/cs_libguarded) |
| LLVM | Apache-2.0 | [llvm/llvm-project](https://github.com/llvm/llvm-project.git) |
| rbfx | MIT | [rbfx/rbfx](https://github.com/rbfx/rbfx) |
| Julia | MIT | [JuliaLang/julia](https://github.com/JuliaLang/julia) |

# Used Assets

| Asset | License | Link |
|---------|--------|--------|
| Stag GLTF | [CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt) | [quaternius/Stag.gltf](https://quaternius.com/packs/ultimateanimatedanimals.html) |

# Used Tools

| Tool | License | Link |
|---------|---------|---------|
| doxygen | GPL-2.0 | [doxygen/doxygen](https://github.com/doxygen/doxygen)|
