# Build script for curl

do_target_me_harder_curl_get() {
    CT_GetFile "curl-${CT_CURL_VERSION}" .tar.bz2 \
               http://curl.haxx.se/download
}

do_target_me_harder_curl_extract() {
    CT_Extract "curl-${CT_CURL_VERSION}"
    CT_Patch "curl" "${CT_CURL_VERSION}"
}

do_target_me_harder_curl_build() {
    CT_DoStep EXTRA "Installing target curl"
    mkdir -p "${CT_BUILD_DIR}/build-curl-target"
    CT_Pushd "${CT_BUILD_DIR}/build-curl-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/curl-${CT_CURL_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-libz                                             \
        --with-libssl                                           \
        --without-libssh2                                       \
        --enable-ares                                           \
        --with-random=/dev/urandom
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
