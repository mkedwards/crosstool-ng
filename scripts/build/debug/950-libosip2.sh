# Build script for libosip2

do_debug_libosip2_get() {
    CT_GetFile "libosip2-${CT_LIBOSIP2_VERSION}" .tar.gz http://ftp.gnu.org/gnu/osip
}

do_debug_libosip2_extract() {
    CT_Extract "libosip2-${CT_LIBOSIP2_VERSION}"
    CT_Patch "libosip2" "${CT_LIBOSIP2_VERSION}"
}

do_debug_libosip2_build() {
    CT_DoStep INFO "Installing libosip2"
    mkdir -p "${CT_BUILD_DIR}/build-libosip2"
    CT_Pushd "${CT_BUILD_DIR}/build-libosip2"

    CT_DoLog EXTRA "Configuring libosip2"

    CT_Pushd "${CT_SRC_DIR}/libosip2-${CT_LIBOSIP2_VERSION}"
    mkdir -p m4 scripts
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/libosip2-${CT_LIBOSIP2_VERSION}/configure"   \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-debug --enable-trace --enable-test --disable-mt

    CT_DoLog EXTRA "Building libosip2"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing libosip2"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install

    CT_Popd
    CT_EndStep
}

