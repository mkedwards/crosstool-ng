# Build script for e2fsprogs

do_cross_me_harder_e2fsprogs_get() {
    CT_GetFile "e2fsprogs-${CT_E2FSPROGS_VERSION}" \
               http://mesh.dl.sourceforge.net/sourceforge/e2fsprogs/e2fsprogs/${CT_E2FSPROGS_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_cross_me_harder_e2fsprogs_extract() {
    CT_Extract "e2fsprogs-${CT_E2FSPROGS_VERSION}"
    CT_Patch "e2fsprogs" "${CT_E2FSPROGS_VERSION}"
}

do_cross_me_harder_e2fsprogs_build() {
    CT_DoStep EXTRA "Installing host e2fsprogs"
    mkdir -p "${CT_BUILD_DIR}/build-e2fsprogs-host"
    CT_Pushd "${CT_BUILD_DIR}/build-e2fsprogs-host"
    
    CT_DoExecLog CFG \
    PKG_CONFIG_LIBDIR="${CT_PREFIX_DIR}/lib/pkgconfig"          \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/e2fsprogs-${CT_E2FSPROGS_VERSION}/configure" \
            --build=${CT_BUILD}                                 \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing cross e2fsprogs"
    mkdir -p "${CT_BUILD_DIR}/build-e2fsprogs-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-e2fsprogs-cross"
    
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/e2fsprogs-${CT_E2FSPROGS_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
