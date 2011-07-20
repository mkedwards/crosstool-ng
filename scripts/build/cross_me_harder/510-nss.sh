# Build script for nss

do_cross_me_harder_nss_get() {
    CT_GetFile "nss-${CT_NSS_VERSION}" .tar.gz \
               "https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_${CT_NSS_VERSION}_RTM/src"
}

do_cross_me_harder_nss_extract() {
    CT_Extract "nss-${CT_NSS_VERSION}"
    CT_Patch "nss" "${CT_NSS_VERSION}"
}

do_cross_me_harder_nss_build() {
    local -a host_extra_config
    local -a target_extra_config
    local ssldir

    CT_DoStep EXTRA "Installing host shlibsign"
    rm -rf "${CT_BUILD_DIR}/build-nss"
    cp -a "${CT_SRC_DIR}/nss-${CT_NSS_VERSION}" "${CT_BUILD_DIR}/build-nss"
    CT_Pushd "${CT_BUILD_DIR}/build-nss/mozilla"
    
    case "$CT_BUILD" in
        x86_64-* )
            host_extra_config+=( "USE_64=1" )
            ;;
    esac

    CT_DoLog DEBUG "Extra config passed: '${host_extra_config[*]}'"

    CT_Pushd "security/coreconf"
    CT_DoExecLog ALL                                            \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    make                                                        \
            CC="${CT_HOST}-gcc"                                 \
            BUILD_OPT=1                                         \
            "${host_extra_config[@]}"
    mkdir -p "${CT_PREFIX_DIR}/bin" "${CT_PREFIX_DIR}/lib"
    CT_DoExecLog ALL \
    cp -L nsinstall/Linux*/nsinstall "${CT_PREFIX_DIR}/bin"
    CT_Popd

    CT_Pushd "security/dbm"
    CT_DoExecLog ALL                                            \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    make                                                        \
            NSPR_INCLUDE_DIR="${CT_PREFIX_DIR}/include/nspr"    \
            NSPR_LIB_DIR="${CT_PREFIX_DIR}/lib"                 \
            NSINSTALL="${CT_PREFIX_DIR}/bin/nsinstall"          \
            CC="${CT_HOST}-gcc"                                 \
            BUILD_OPT=1                                         \
            "${host_extra_config[@]}"
    CT_Popd
    ssldir=$(dirname $(find `pwd`/dist -name libdbm.a))

    CT_Pushd "security/nss"
    CT_DoExecLog ALL                                            \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    LD_LIBRARY_PATH="${ssldir}:${CT_PREFIX_DIR}/lib"            \
    make                                                        \
            NSPR_INCLUDE_DIR="${CT_PREFIX_DIR}/include/nspr"    \
            NSPR_LIB_DIR="${CT_PREFIX_DIR}/lib"                 \
            NSINSTALL="${CT_PREFIX_DIR}/bin/nsinstall"          \
            CC="${CT_HOST}-gcc"                                 \
            BUILD_OPT=1                                         \
            USE_SYSTEM_ZLIB=1                                   \
            "${host_extra_config[@]}"
    CT_DoExecLog ALL \
    cp -p $(find cmd/shlibsign -name shlibsign -type f) "${CT_PREFIX_DIR}/bin"
    CT_Popd

    CT_DoExecLog ALL \
    cp -L $(find dist -name '*.so' -type l) "${CT_PREFIX_DIR}/lib"

    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target nss"
    rm -rf "${CT_BUILD_DIR}/build-nss-target"
    cp -a "${CT_SRC_DIR}/nss-${CT_NSS_VERSION}" "${CT_BUILD_DIR}/build-nss-target"
    CT_Pushd "${CT_BUILD_DIR}/build-nss-target/mozilla"

    case "${CT_ARCH}:${CT_ARCH_BITNESS}" in
        x86:32)     target_extra_config="OS_TEST=i686";;
        *)          target_extra_config="OS_TEST=${CT_ARCH}";;
    esac

    CT_DoLog DEBUG "Extra config passed: '${target_extra_config[*]}'"

    CT_Pushd "security/dbm"
    CT_DoExecLog ALL                                            \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    PKG_CONFIG_LIBDIR=${CT_SYSROOT_DIR}/usr/lib/pkgconfig       \
    make                                                        \
            NSPR_INCLUDE_DIR="${CT_SYSROOT_DIR}/usr/include/nspr" \
            NSPR_LIB_DIR="${CT_SYSROOT_DIR}/usr/lib"            \
            NSINSTALL="${CT_PREFIX_DIR}/bin/nsinstall"          \
            HOST_CC="${CT_HOST}-gcc"                            \
            CC="${CT_TARGET}-gcc"                               \
            CCC="${CT_TARGET}-g++"                              \
            RANLIB="${CT_TARGET}-ranlib"                        \
            G++INCLUDES=                                        \
            BUILD_OPT=1                                         \
            ALLOW_OPT_CODE_SIZE=1                               \
            OPT_CODE_SIZE=1                                     \
            MOZ_DEBUG_SYMBOLS=1                                 \
            CROSS_COMPILE=1                                     \
            OS_ARCH=Linux                                       \
            OS_RELEASE=2.6                                      \
            OS_TARGET=Linux                                     \
            "${target_extra_config[@]}"
    CT_Popd

    CT_Pushd "security/nss"
    CT_DoExecLog ALL                                            \
    SHLIBSIGN="${CT_PREFIX_DIR}/bin/shlibsign"                  \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    PKG_CONFIG_LIBDIR=${CT_SYSROOT_DIR}/usr/lib/pkgconfig       \
    make                                                        \
            USE_SYSTEM_ZLIB=1                                   \
            NSS_USE_SYSTEM_SQLITE=1                             \
            NSPR_INCLUDE_DIR="${CT_SYSROOT_DIR}/usr/include/nspr" \
            NSPR_LIB_DIR="${CT_SYSROOT_DIR}/usr/lib"            \
            NSINSTALL="${CT_PREFIX_DIR}/bin/nsinstall"          \
            HOST_CC="${CT_HOST}-gcc"                            \
            CC="${CT_TARGET}-gcc"                               \
            CCC="${CT_TARGET}-g++"                              \
            RANLIB="${CT_TARGET}-ranlib"                        \
            G++INCLUDES=                                        \
            BUILD_OPT=1                                         \
            ALLOW_OPT_CODE_SIZE=1                               \
            OPT_CODE_SIZE=1                                     \
            MOZ_DEBUG_SYMBOLS=1                                 \
            CROSS_COMPILE=1                                     \
            OS_ARCH=Linux                                       \
            OS_RELEASE=2.6                                      \
            OS_TARGET=Linux                                     \
            "${target_extra_config[@]}"
    CT_Popd

    CT_DoExecLog ALL \
    rm -rf "${CT_SYSROOT_DIR}/usr/include/dbm" "${CT_SYSROOT_DIR}/usr/include/nss"
    CT_DoExecLog ALL \
    cp -rL dist/public/dbm dist/public/nss "${CT_SYSROOT_DIR}/usr/include"
    CT_DoExecLog ALL \
    cp -L $(find dist -name '*.so' -type l) "${CT_SYSROOT_DIR}/usr/lib"

    CT_Popd

    cat > "${CT_SYSROOT_DIR}"/usr/lib/pkgconfig/nss.pc <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include/nss

Name: NSS
Description: Network Security Services
Version: ${CT_NSS_VERSION}
Requires: nspr >= 4.8
Libs: -L\${libdir} -lssl3 -lsmime3 -lnss3 -lnssutil3
Cflags: -I\${includedir}
EOF

    CT_EndStep
}
