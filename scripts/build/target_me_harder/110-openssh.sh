# Build script for openssh

do_target_me_harder_openssh_get() {
    CT_GetFile "openssh-${CT_OPENSSH_VERSION}" .tar.gz \
               http://mirror.mcs.anl.gov/openssh/portable
}

do_target_me_harder_openssh_extract() {
    CT_Extract "openssh-${CT_OPENSSH_VERSION}"
    CT_Patch "openssh" "${CT_OPENSSH_VERSION}"
}

do_target_me_harder_openssh_build() {
    CT_DoStep EXTRA "Installing target openssh"
    mkdir -p "${CT_BUILD_DIR}/build-openssh-target"
    CT_Pushd "${CT_BUILD_DIR}/build-openssh-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    "${CT_SRC_DIR}/openssh-${CT_OPENSSH_VERSION}/configure"     \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-libz                                             \
        --without-pam                                           \
        --disable-strip

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install-nokeys
    CT_Popd
    CT_EndStep
}
