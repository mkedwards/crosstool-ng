# Build script for libeXosip2

do_debug_libeXosip2_get() {
    CT_GetFile "libeXosip2-${CT_LIBEXOSIP2_VERSION}" .tar.gz http://download.savannah.gnu.org/releases/exosip
}

do_debug_libeXosip2_extract() {
    CT_Extract "libeXosip2-${CT_LIBEXOSIP2_VERSION}"
    CT_Patch "libeXosip2" "${CT_LIBEXOSIP2_VERSION}"
}

do_debug_libeXosip2_build() {
    CT_DoStep INFO "Installing libeXosip2"
    mkdir -p "${CT_BUILD_DIR}/build-libeXosip2"
    CT_Pushd "${CT_BUILD_DIR}/build-libeXosip2"

    CT_DoLog EXTRA "Configuring libeXosip2"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/libeXosip2-${CT_LIBEXOSIP2_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-debug --enable-trace --enable-test --disable-mt

    CT_DoLog EXTRA "Building libeXosip2"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing libeXosip2"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install

    CT_Popd
    CT_EndStep
}

