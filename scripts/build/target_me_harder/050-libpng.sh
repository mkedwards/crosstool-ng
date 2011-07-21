# Build script for libpng

do_target_me_harder_libpng_get() {
    CT_GetFile "libpng-${CT_LIBPNG_VERSION}" .tar.bz2 \
               http://mesh.dl.sourceforge.net/sourceforge/libpng/libpng15/${CT_LIBPNG_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_target_me_harder_libpng_extract() {
    CT_Extract "libpng-${CT_LIBPNG_VERSION}"
    CT_Patch "libpng" "${CT_LIBPNG_VERSION}"
}

do_target_me_harder_libpng_build() {
    CT_DoStep EXTRA "Installing target libpng"
    mkdir -p "${CT_BUILD_DIR}/build-libpng-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libpng-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/libpng-${CT_LIBPNG_VERSION}/configure"       \
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
