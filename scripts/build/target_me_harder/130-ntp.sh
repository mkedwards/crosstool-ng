# Build script for ntp

do_target_me_harder_ntp_get() {
    CT_GetFile "ntp-${CT_NTP_VERSION}" .tar.gz \
               http://archive.ntp.org/ntp4/ntp-4.2
}

do_target_me_harder_ntp_extract() {
    CT_Extract "ntp-${CT_NTP_VERSION}"
    CT_Patch "ntp" "${CT_NTP_VERSION}"
}

do_target_me_harder_ntp_build() {
    CT_DoStep EXTRA "Installing target ntp"
    mkdir -p "${CT_BUILD_DIR}/build-ntp-target"
    CT_Pushd "${CT_BUILD_DIR}/build-ntp-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    "${CT_SRC_DIR}/ntp-${CT_NTP_VERSION}/configure"             \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-crypto=openssl                                   \
        --with-openssl-libdir="${CT_SYSROOT_DIR}"/usr/lib       \
        --with-openssl-incdir="${CT_SYSROOT_DIR}"/usr/include   \
        --without-rpath


    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
