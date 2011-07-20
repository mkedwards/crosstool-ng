# Build script for c-ares

do_target_me_harder_c_ares_get() {
    CT_GetFile "c-ares-${CT_C_ARES_VERSION}" .tar.gz \
               http://c-ares.haxx.se
}

do_target_me_harder_c_ares_extract() {
    CT_Extract "c-ares-${CT_C_ARES_VERSION}"
    CT_Patch "c-ares" "${CT_C_ARES_VERSION}"
}

do_target_me_harder_c_ares_build() {
    CT_DoStep EXTRA "Installing target c-ares"
    mkdir -p "${CT_BUILD_DIR}/build-c-ares-target"
    CT_Pushd "${CT_BUILD_DIR}/build-c-ares-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/c-ares-${CT_C_ARES_VERSION}/configure"       \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-random=/dev/urandom
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
