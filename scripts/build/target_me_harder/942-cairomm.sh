# Build script for cairomm

do_target_me_harder_cairomm_get() {
    CT_GetFile "cairomm-${CT_CAIROMM_VERSION}" .tar.gz \
               http://cairographics.org/releases
}

do_target_me_harder_cairomm_extract() {
    CT_Extract "cairomm-${CT_CAIROMM_VERSION}"
    CT_Patch "cairomm" "${CT_CAIROMM_VERSION}"
}

do_target_me_harder_cairomm_build() {
    CT_DoStep EXTRA "Installing target cairomm"
    mkdir -p "${CT_BUILD_DIR}/build-cairomm-target"
    CT_Pushd "${CT_BUILD_DIR}/build-cairomm-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/cairomm-${CT_CAIROMM_VERSION}/configure"     \
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
