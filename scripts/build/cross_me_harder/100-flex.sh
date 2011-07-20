# Build script for flex

do_cross_me_harder_flex_get() {
    CT_GetFile "flex-${CT_FLEX_VERSION}" \
               http://mesh.dl.sourceforge.net/sourceforge/flex/flex/flex-${CT_FLEX_VERSION}/
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_cross_me_harder_flex_extract() {
    CT_Extract "flex-${CT_FLEX_VERSION}"
    CT_Patch "flex" "${CT_FLEX_VERSION}"
    CT_Pushd "${CT_SRC_DIR}/flex-${CT_FLEX_VERSION}"
    CT_DoExecLog ALL autoreconf -fiv
    CT_Popd
}

do_cross_me_harder_flex_build() {
    CT_DoStep EXTRA "Installing cross flex"
    mkdir -p "${CT_BUILD_DIR}/build-flex-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-flex-cross"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/flex-${CT_FLEX_VERSION}/configure"   \
            --build=${CT_BUILD}                         \
            --target=${CT_TARGET}                       \
            --prefix="${CT_PREFIX_DIR}"                 \
            --disable-nls                               \
            --disable-rpath
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Clobbering libraries from cross flex with host flex"
    mkdir -p "${CT_BUILD_DIR}/build-flex-clobber"
    CT_Pushd "${CT_BUILD_DIR}/build-flex-clobber"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/flex-${CT_FLEX_VERSION}/configure"   \
            --prefix="${CT_PREFIX_DIR}"                 \
            --disable-nls                               \
            --disable-rpath
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing host flex"
    mkdir -p "${CT_BUILD_DIR}/build-flex"
    CT_Pushd "${CT_BUILD_DIR}/build-flex"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/flex-${CT_FLEX_VERSION}/configure"   \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target flex"
    mkdir -p "${CT_BUILD_DIR}/build-flex-target"
    CT_Pushd "${CT_BUILD_DIR}/build-flex-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/flex-${CT_FLEX_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-nls                                           \
        --disable-rpath
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
