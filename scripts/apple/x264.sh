#!/bin/bash

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
i386 | x86-64*)
  ASM_OPTIONS="--disable-asm"

  if ! [ -x "$(command -v nasm)" ]; then
    echo -e "\n(*) nasm command not found\n"
    return 1
  fi

  export AS="$(command -v nasm)"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_x264} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}"
fi

# UPDATE CONFIG FILES TO SUPPORT APPLE ARCHITECTURES
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.guess "${BASEDIR}"/src/"${LIB_NAME}"/config.guess || return 1
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.sub "${BASEDIR}"/src/"${LIB_NAME}"/config.sub || return 1

# WORKAROUND DISABLE INLINE -arch DEFINITIONS
# @TODO TEST THESE
# ${SED_INLINE} 's/CFLAGS=\"\$CFLAGS \-arch x86_64/CFLAGS=\"\$CFLAGS/g' configure
# ${SED_INLINE} 's/LDFLAGS=\"\$LDFLAGS \-arch x86_64/LDFLAGS=\"\$CFLAGS/g' configure

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --enable-pic \
  --sysroot=${SDK_PATH} \
  --enable-static \
  --disable-cli \
  ${ASM_OPTIONS} \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp x264.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
