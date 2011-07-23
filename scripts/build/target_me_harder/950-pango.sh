# Build script for pango

do_target_me_harder_pango_get() {
    CT_GetFile "pango-${CT_PANGO_VERSION}" .tar.bz2 \
               http://ftp.gnome.org/pub/GNOME/sources/pango/1.29
}

do_target_me_harder_pango_extract() {
    CT_Extract "pango-${CT_PANGO_VERSION}"
    CT_Patch "pango" "${CT_PANGO_VERSION}"
}

do_target_me_harder_pango_build() {
    CT_DoStep EXTRA "Installing target pango"
    mkdir -p "${CT_BUILD_DIR}/build-pango-target"
    CT_Pushd "${CT_BUILD_DIR}/build-pango-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/pango-${CT_PANGO_VERSION}/configure"         \
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
