#!/bin/bash

# winget install --id=Microsoft.msmpisdk -e
# winget install --id=Microsoft.msmpi -e

# pacman -S mingw-w64-x86_64-gcc \
#           mingw-w64-x86_64-cmake \
#           mingw-w64-x86_64-ninja \
#           mingw-w64-x86_64-boost \
#           mingw-w64-x86_64-lapack \
#           mingw-w64-x86_64-openblas \
#           mingw-w64-x86_64-tbb \
#           mingw-w64-x86_64-muparser \
#           mingw-w64-x86_64-zlib \
#           mingw-w64-x86_64-msmpi \
#           mingw-w64-x86_64-hypre \
#           mingw-w64-x86_64-metis \
#           mingw-w64-x86_64-parmetis \
#           mingw64/mingw-w64-x86_64-msmpi \
            # mingw-w64-x86_64-pkgconf
            # mingw-w64-x86_64-git
            # mingw-w64-x86_64-make
#           --needed

ROOT=$(pwd)
export CMAKE_POLICY_VERSION_MINIMUM=3.5

PETSC_VERSION=v3.21.0
PETSC_DIR=$ROOT/thirdParty/petsc

if [ ! -d "$PETSC_DIR" ]; then
  git clone -b $PETSC_VERSION https://gitlab.com/petsc/petsc.git $PETSC_DIR
fi

cd $PETSC_DIR

rm -rf arch-mswin-c-debug

# ============================================================
# Für Debug
# ============================================================

/usr/bin/python ./configure \
  --with-mpi-dir=/mingw64 \
  --with-blaslapack-dir=/mingw64 \
  --with-shared-libraries=0 \
  --with-fc=0 \
  --with-hypre-include=/mingw64/include \
  --with-hypre-lib=/mingw64/lib/libHYPRE.dll.a \
  --with-metis-include=/mingw64/include \
  --with-metis-lib=/mingw64/lib/libmetis.dll.a \
  --with-parmetis-include=/mingw64/include \
  --with-parmetis-lib=/mingw64/lib/libparmetis.dll.a \
  COPTFLAGS="-O0 -g" \
  CXXOPTFLAGS="-O0 -g" \
  PETSC_ARCH=arch-mswin-c-debug

make PETSC_DIR=$PETSC_DIR PETSC_ARCH=arch-mswin-c-debug all

# ============================================================
# Für Release
# ============================================================

rm -rf arch-mswin-c-opt

/usr/bin/python ./configure \
  --with-mpi-dir=/mingw64 \
  --with-blaslapack-dir=/mingw64 \
  --with-shared-libraries=0 \
  --with-fc=0 \
  --with-debugging=0 \
  --with-hypre-include=/mingw64/include \
  --with-hypre-lib=/mingw64/lib/libHYPRE.dll.a \
  --with-metis-include=/mingw64/include \
  --with-metis-lib=/mingw64/lib/libmetis.dll.a \
  --with-parmetis-include=/mingw64/include \
  --with-parmetis-lib=/mingw64/lib/libparmetis.dll.a \
  COPTFLAGS="-O3 -march=native -funroll-loops" \
  CXXOPTFLAGS="-O3 -march=native -funroll-loops" \
  PETSC_ARCH=arch-mswin-c-opt

make PETSC_DIR=$PETSC_DIR PETSC_ARCH=arch-mswin-c-opt all

cd $ROOT