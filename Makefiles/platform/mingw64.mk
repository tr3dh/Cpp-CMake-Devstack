BUILD_PREFIX = _MINGW_GCCx64

BUILDDIR_RELEASE = __build/__buildNDBUG$(BUILD_PREFIX)
BUILDDIR_DEBUG = __build//__buildDBUG$(BUILD_PREFIX)

BUILDDIR  ?= $(BUILDDIR_DEBUG)
BUILDMODE ?= Debug

build:
	@echo Building with MinGW Ninja
	cmake -S . -B $(BUILDDIR) -G Ninja \
		-DCMAKE_MAKE_PROGRAM=ninja \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DCMAKE_BUILD_TYPE=$(BUILDMODE) \
		-DCMAKE_C_COMPILER=gcc \
		-DCMAKE_CXX_COMPILER=g++
	cmake --build $(BUILDDIR)
	@cp $(BUILDDIR)/compile_commands.json .vscode/compile_commands.json

ANGLE_ROOT    ?= /mingw64/lib
ANGLE_INC     ?= /mingw64/include
ANGLE_LIB_DIR ?= /mingw64/lib
ANGLE_DLLS ?= C:/msys64/mingw64/bin/libEGL.dll;C:/msys64/mingw64/bin/libGLESv2.dll;C:/msys64/mingw64/bin/libstdc++-6.dll;C:/msys64/mingw64/bin/libgcc_s_seh-1.dll;C:/msys64/mingw64/bin/libwinpthread-1.dll;C:/msys64/mingw64/bin/zlib1.dll

build-angle:
	@echo Building with MinGW Ninja + ANGLE
	cmake -S . -B $(BUILDDIR) -G Ninja \
		-DCMAKE_MAKE_PROGRAM=ninja \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DCMAKE_BUILD_TYPE=$(BUILDMODE) \
		-DCMAKE_C_COMPILER=gcc \
		-DCMAKE_CXX_COMPILER=g++ \
		-DUSE_ANGLE=ON \
		-DANGLE_ROOT="$(ANGLE_ROOT)" \
		-DANGLE_INC=$(ANGLE_INC) \
		-DANGLE_LIB_DIR="$(ANGLE_LIB_DIR)" \
		"-DANGLE_DLLS=$(ANGLE_DLLS)"
	cmake --build $(BUILDDIR)
	@cp $(BUILDDIR)/compile_commands.json .vscode/compile_commands.json

exec:
	@echo ==================================================
	@cd $(BUILDDIR) && ./proj && echo Success || echo Failed

clear:
	rm -f $(BUILDDIR)/CMakeCache.txt
	rm -rf $(BUILDDIR)/CMakeFiles

launch: build exec

rlaunch:
	$(MAKE) launch BUILDDIR=$(BUILDDIR_RELEASE) BUILDMODE=Release

ICON ?= Recc/Compilation/icon
icon:
	magick "$(ICON).png" -define icon:auto-resize=16,32,48,64,128,256 "$(ICON).ico";

dlaunch: launch