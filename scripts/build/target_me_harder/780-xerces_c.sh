# Build script for xerces-c

do_target_me_harder_xerces_c_get() {
    CT_GetFile "xerces-c-${CT_XERCES_C_VERSION}" .tar.gz \
               http://www.apache.org/dist/xerces/c/3/sources
}

do_target_me_harder_xerces_c_extract() {
    CT_Extract "xerces-c-${CT_XERCES_C_VERSION}"
    CT_Patch "xerces-c" "${CT_XERCES_C_VERSION}"
}

do_target_me_harder_xerces_c_build() {
    CT_DoStep EXTRA "Installing target xerces-c"
    mkdir -p "${CT_BUILD_DIR}/build-xerces-c-target"
    CT_Pushd "${CT_BUILD_DIR}/build-xerces-c-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/xerces-c-${CT_XERCES_C_VERSION}/configure"   \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-curl="${CT_SYSROOT_DIR}"/usr

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install
    CT_Popd
    CT_EndStep
}
