# C++ Devstack CMake Starter

# Project Brief

This project is a CMake template that can be used to set up a devstack consisting of mostly open-source libraries.

# Releases

For binary releases, the licenses of the libraries used must be checked. GMP, for example, requires that the GMP source code and a relink-gmp.txt file be included when statically linking in binary releases. Additionally, all libraries used should be listed in the `README` and provided via a `Thirdparty-Licenses.md` file or a folder containing the corresponding licenses.

# Used Libraries

The CMake project sets up the open-source libraries on its own; the Steam SDK must be downloaded as a pre-built version directly from Valve.
The complete license texts, as well as the GMP source code and GMP relink instructions, can be found in [thirdPartyLicenses](thirdPartyLicenses/)

| Library | License | Link |
|---------|--------|--------|
| SDL3 | zlib | [libsdl-org/SDL](https://github.com/libsdl-org/SDL) |
| raylib | zlib | [raysan5/raylib](https://github.com/raysan5/raylib) |
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

# Used Assets

| Asset | License | Link |
|---------|--------|--------|
| Stag GLTF | [CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt) | [quaternius/Stag.gltf](https://quaternius.com/packs/ultimateanimatedanimals.html) |

# Used Tools

| Tool | License | Link |
|---------|---------|---------|
| doxygen | GPL-2.0 | [doxygen/doxygen](https://github.com/doxygen/doxygen)|
