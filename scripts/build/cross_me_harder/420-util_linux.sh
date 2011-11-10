# Build script for util-linux

do_cross_me_harder_util_linux_get() {
    CT_GetFile "util-linux_${CT_UTIL_LINUX_VERSION}" \
               {ftp,http}://ftp.de.debian.org/debian/pool/main/u/util-linux/
    # Create a link so that the following steps are easier to do:
    CT_Pushd "${CT_TARBALLS_DIR}"
    util_linux_ext=$(CT_GetFileExtension "util-linux_${CT_UTIL_LINUX_VERSION}.orig")
    ln -sf "util-linux_${CT_UTIL_LINUX_VERSION}.orig${util_linux_ext}"              \
           "util-linux-${CT_UTIL_LINUX_VERSION}${util_linux_ext}"
    CT_Popd
}

do_cross_me_harder_util_linux_extract() {
    CT_Extract "util-linux-${CT_UTIL_LINUX_VERSION}"
    CT_Patch "util-linux" "${CT_UTIL_LINUX_VERSION}"
}

do_cross_me_harder_util_linux_build() {
    CT_DoStep EXTRA "Installing host util-linux"

    CT_Pushd "${CT_SRC_DIR}/util-linux-${CT_UTIL_LINUX_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    mkdir -p "${CT_BUILD_DIR}/build-util-linux-host"
    CT_Pushd "${CT_BUILD_DIR}/build-util-linux-host"
    
    CT_DoExecLog CFG \
    PKG_CONFIG_LIBDIR="${CT_PREFIX_DIR}/lib/pkgconfig"          \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/util-linux-${CT_UTIL_LINUX_VERSION}/configure" \
            --build=${CT_BUILD}                                 \
            --prefix="${CT_PREFIX_DIR}"                         \
            --disable-wall
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing cross util-linux"
    mkdir -p "${CT_BUILD_DIR}/build-util-linux-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-util-linux-cross"
    
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/util-linux-${CT_UTIL_LINUX_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-wall
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
