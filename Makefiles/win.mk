# ENV
VSVERSION ?= "18"
VSRELEASE ?= "2026"
VSVARS = "C:\Program Files (x86)\Microsoft Visual Studio\$(VSVERSION)\BuildTools\VC\Auxiliary\Build\vcvars64.bat"

BUILD_PREFIX = _MSVCx64

BUILDDIR_RELEASE = __build/__buildNDBUG$(BUILD_PREFIX)
BUILDDIR_DEBUG = __build//__buildDBUG$(BUILD_PREFIX)

BUILDDIR ?= $(BUILDDIR_DEBUG)
BUILDMODE ?= Debug
SKIPFLSAMPLES ?= OFF

# BUILDDIR ?= DBUGx64

# Build mit Ninja Gen für MSVC
build:
	@echo Building with MSVC Ninja
	cmd /C "call $(VSVARS) && \
	cmake -S . -B $(BUILDDIR) -G Ninja \
		-DCMAKE_MAKE_PROGRAM=ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=$(BUILDMODE) && \
	cmake --build $(BUILDDIR)"
	@copy $(subst /,\,$(BUILDDIR))\compile_commands.json .vscode\compile_commands.json

PROJ_ROOT := $(realpath $(CURDIR))

VCREDIST_1444 := C:/Program Files (x86)/Microsoft Visual Studio/18/BuildTools/VC/Redist/MSVC/14.44.35112/x64/Microsoft.VC143.CRT

ANGLE_ROOT    ?= thirdParty/angle/angle-x64
ANGLE_INC     ?= thirdParty/angle/angle-x64/include
ANGLE_LIB_DIR ?= thirdParty/angle/angle-x64/lib
ANGLE_DLLS    ?= $(PROJ_ROOT)/thirdParty/angle/angle-x64/bin/libEGL.dll;$(PROJ_ROOT)/thirdParty/angle/angle-x64/bin/libGLESv2.dll

build-angle:
	@echo Building with MSVC Ninja + ANGLE
	cmd /C "call $(VSVARS) && \
	cmake -S . -B $(BUILDDIR) -G Ninja \
		-DCMAKE_MAKE_PROGRAM=ninja \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DCMAKE_BUILD_TYPE=$(BUILDMODE) \
		-DUSE_ANGLE=ON \
		-DANGLE_ROOT=$(ANGLE_ROOT) \
		-DANGLE_INC=$(ANGLE_INC) \
		-DANGLE_LIB_DIR=$(ANGLE_LIB_DIR) \
		-DANGLE_DLLS=$(ANGLE_DLLS) && \
	cmake --build $(BUILDDIR)"
	@copy $(subst /,\,$(BUILDDIR))\compile_commands.json .vscode\compile_commands.json

exec:
	@echo ==================================================
	@cd $(BUILDDIR) && .\proj && echo ================================================== && echo Success || echo Failed with code %ERRORLEVEL%
	
clear:
	del /Q "$(BUILDDIR)\CMakeCache.txt"
	rmdir /S /Q "$(BUILDDIR)\CMakeFiles"

launch:
	$(MAKE) build BUILDDIR=$(BUILDDIR) BUILDMODE=$(BUILDMODE)
	$(MAKE) exec BUILDDIR=$(BUILDDIR)

rbuild:
	$(MAKE) build BUILDDIR=$(BUILDDIR_RELEASE) BUILDMODE=Release

rexec:
	$(MAKE) exec BUILDDIR=$(BUILDDIR_RELEASE) BUILDMODE=Release

rlaunch: rbuild rexec

# rlaunch :
# 	make launch BUILDDIR=$(BUILDDIR_RELEASE) BUILDMODE=Release SKIPFLSAMPLES=OFF

dlaunch : launch