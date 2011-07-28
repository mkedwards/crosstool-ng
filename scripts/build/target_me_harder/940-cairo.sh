# Build script for cairo

do_target_me_harder_cairo_get() {
    CT_GetFile "cairo-${CT_CAIRO_VERSION}" .tar.gz \
               http://cairographics.org/releases
}

do_target_me_harder_cairo_extract() {
    CT_Extract "cairo-${CT_CAIRO_VERSION}"
    CT_Patch "cairo" "${CT_CAIRO_VERSION}"
}

do_target_me_harder_cairo_build() {
    CT_DoStep EXTRA "Installing target cairo"
    mkdir -p "${CT_BUILD_DIR}/build-cairo-target"
    CT_Pushd "${CT_BUILD_DIR}/build-cairo-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/cairo-${CT_CAIRO_VERSION}/configure"         \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-tee                                            \
        --enable-qt=yes

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
