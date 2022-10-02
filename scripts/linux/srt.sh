#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
git clean -dfx 2>/dev/null 1>/dev/null

# OVERRIDE SYSTEM PROCESSOR
SYSTEM_PROCESSOR=""
case ${ARCH} in
x86-64)
  SYSTEM_PROCESSOR="x86_64"
  ;;
esac

# WORKAROUND TO GENERATE BASE BUILD FILES
./configure || echo "" 2>/dev/null 1>/dev/null

cmake -Wno-dev \
 -DUSE_ENCLIB=openssl \
 -DCMAKE_VERBOSE_MAKEFILE=0 \
 -DCMAKE_C_FLAGS="${CFLAGS}" \
 -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
 -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
 -DCMAKE_SYSTEM_NAME=Linux \
 -DCMAKE_CXX_COMPILER="$CXX" \
 -DCMAKE_C_COMPILER="$CC" \
 -DCMAKE_LINKER="$LD" \
 -DCMAKE_AR="$AR" \
 -DCMAKE_AS="$AS" \
 -DCMAKE_SYSTEM_LOADED=1 \
 -DCMAKE_SYSTEM_PROCESSOR="${SYSTEM_PROCESSOR}" \
 -DENABLE_STDCXX_SYNC=1 \
 -DENABLE_MONOTONIC_CLOCK=1 \
 -DENABLE_STDCXX_SYNC=1 \
 -DENABLE_CXX11=1 \
 -DUSE_OPENSSL_PC=1 \
 -DENABLE_DEBUG=0 \
 -DENABLE_LOGGING=0 \
 -DENABLE_HEAVY_LOGGING=0 \
 -DENABLE_APPS=0 \
 -DENABLE_SHARED=0 "${BASEDIR}"/src/"${LIB_NAME}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_srt_package_config "1.5.1" || return 1