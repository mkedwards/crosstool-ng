# Build script for libogg

do_target_me_harder_libogg_get() {
    CT_GetFile "libogg-${CT_LIBOGG_VERSION}" .tar.gz \
               http://downloads.xiph.org/releases/ogg
}

do_target_me_harder_libogg_extract() {
    CT_Extract "libogg-${CT_LIBOGG_VERSION}"
    CT_Patch "libogg" "${CT_LIBOGG_VERSION}"
}

do_target_me_harder_libogg_build() {
    CT_DoStep EXTRA "Installing target libogg"

    CT_Pushd "${CT_SRC_DIR}/libogg-${CT_LIBOGG_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    mkdir -p "${CT_BUILD_DIR}/build-libogg-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libogg-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/libogg-${CT_LIBOGG_VERSION}/configure"       \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
