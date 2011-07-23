# Build script for pixman

do_target_me_harder_pixman_get() {
    CT_GetFile "pixman-${CT_PIXMAN_VERSION}" .tar.gz \
               http://cairographics.org/releases
}

do_target_me_harder_pixman_extract() {
    CT_Extract "pixman-${CT_PIXMAN_VERSION}"
    CT_Patch "pixman" "${CT_PIXMAN_VERSION}"
}

do_target_me_harder_pixman_build() {
    CT_DoStep EXTRA "Installing target pixman"
    mkdir -p "${CT_BUILD_DIR}/build-pixman-target"
    CT_Pushd "${CT_BUILD_DIR}/build-pixman-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/pixman-${CT_PIXMAN_VERSION}/configure"       \
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
