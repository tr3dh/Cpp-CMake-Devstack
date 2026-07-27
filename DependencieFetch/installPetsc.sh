#!/bin/bash

# pacman -S mingw-w64-x86_64-gcc \
#           mingw-w64-x86_64-cmake \
#           mingw-w64-x86_64-ninja \
#           mingw-w64-x86_64-boost \
#           mingw-w64-x86_64-lapack \
#           mingw-w64-x86_64-openblas \
#           mingw-w64-x86_64-tbb \
#           mingw-w64-x86_64-muparser \
#           mingw-w64-x86_64-zlib \
#           mingw-w64-x86_64-petsc \
#           mingw-w64-x86_64-build \
#           mingw-w64-x86_64-mfem \
#           mingw-w64-x86_64-msmpi \
#           mingw-w64-x86_64-metis \
#           mingw-w64-x86_64-parmetis \
#           mingw-w64-x86_64-hypre \
#           --needed

# pacman -S autoconf \
#           automake-wrapper \
#           bison \
#           bsdcpio \
#           make \
#           git \
#           mingw-w64-x86_64-toolchain \
#           patch \
#           python \
#           flex \
#           pkg-config \
#           pkgfile \
#           tar \
#           unzip \
#           mingw-w64-x86_64-cmake \
#           mingw-w64-x86_64-msmpi \ 
#           mingw-w64-x86_64-openblas \
#           --needed

ROOT=$(pwd)

PETSC_VERSION=v3.21.0
PETSC_DIR=$ROOT/thirdParty/petsc

# Clone PETSc
git clone -b $PETSC_VERSION https://gitlab.com/petsc/petsc.git $PETSC_DIR

cd $PETSC_DIR

# Für Debug

/usr/bin/python ./configure \
  --with-mpi-dir=/mingw64 \
  --with-blaslapack-dir=/mingw64 \
  --with-shared-libraries=0 \
  --with-fc=0 \
  --with-64-bit-indices=1 \
  PETSC_ARCH=arch-mswin-c-debug

make PETSC_DIR=$PETSC_DIR PETSC_ARCH=arch-mswin-c-debug all

# Für Release

/usr/bin/python ./configure \
  --with-mpi-dir=/mingw64 \
  --with-blaslapack-dir=/mingw64 \
  --with-shared-libraries=0 \
  --with-fc=0 \
  --with-debugging=0 \
  --with-64-bit-indices \
  COPTFLAGS="-O3 -march=native" \
  CXXOPTFLAGS="-O3 -march=native" \
  PETSC_ARCH=arch-mswin-c-opt

make PETSC_DIR=$PETSC_DIR PETSC_ARCH=arch-mswin-c-opt all

cd $ROOT