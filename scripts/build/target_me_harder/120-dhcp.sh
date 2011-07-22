# Build script for dhcp

do_target_me_harder_dhcp_get() {
    CT_GetFile "dhcp-${CT_DHCP_VERSION}" .tar.gz \
               http://ftp.isc.org/isc/dhcp
}

do_target_me_harder_dhcp_extract() {
    CT_Extract "dhcp-${CT_DHCP_VERSION}"
    CT_Patch "dhcp" "${CT_DHCP_VERSION}"
}

do_target_me_harder_dhcp_build() {
    CT_DoStep EXTRA "Installing target dhcp"
    mkdir -p "${CT_BUILD_DIR}/build-dhcp-target"
    CT_Pushd "${CT_BUILD_DIR}/build-dhcp-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    "${CT_SRC_DIR}/dhcp-${CT_DHCP_VERSION}/configure"           \
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
