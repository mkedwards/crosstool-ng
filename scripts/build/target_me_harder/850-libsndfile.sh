# Build script for libsndfile

do_target_me_harder_libsndfile_get() {
    CT_GetFile "libsndfile-${CT_LIBSNDFILE_VERSION}" .tar.gz \
               http://www.mega-nerd.com/libsndfile/files
}

do_target_me_harder_libsndfile_extract() {
    CT_Extract "libsndfile-${CT_LIBSNDFILE_VERSION}"
    CT_Patch "libsndfile" "${CT_LIBSNDFILE_VERSION}"
}

do_target_me_harder_libsndfile_build() {
    CT_DoStep EXTRA "Installing target libsndfile"
    mkdir -p "${CT_BUILD_DIR}/build-libsndfile-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libsndfile-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/libsndfile-${CT_LIBSNDFILE_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-sqlite                                         \
        --enable-alsa                                           \
        --disable-octave                                        \
        --enable-largefile

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
