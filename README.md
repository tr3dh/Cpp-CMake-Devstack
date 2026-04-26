# Open-Source Engine Stack CMake Starter

Dieses Projekt ist ein CMake-Template, dass verwendet werden kann um einen aus Open-Source-Bibliothek bestehenden Engine-Stack auszusetzen.

# Releases

Für binäre Releases müssen die Lizenzen der verwendeten Libs gecheckt werden. GMP zum Beispiel verlangt bei statischem Linking in binären Releases die Mitauslieferung des GMP-Source-Codes und einer relink-gmp.txt. Zusätzlich sollten alle verwendeten Bibliotheken in der `README` genannt werden und über eine `Thridparty-Licenses.md` oder einen Ordner, der die entsprechenden Lizenzen enthält mitgeliefert werden.  

# Verwendete Bibliotheken

| Library | Lizenz | GitHub |
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

Die vollständigen Lizenttexte, sowie der GMP-Source-Code und die GMP-Relink-Anweisungen befinden sich in [thirdPartyLicenses](thirdPartyLicenses/)