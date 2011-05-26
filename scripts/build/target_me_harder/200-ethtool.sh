# Build script for ethtool

do_target_me_harder_ethtool_get() {
    CT_GetFile "ethtool-${CT_ETHTOOL_VERSION}" .tar.gz \
               http://mesh.dl.sourceforge.net/sourceforge/gkernel/ethtool/${CT_ETHTOOL_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_target_me_harder_ethtool_extract() {
    CT_Extract "ethtool-${CT_ETHTOOL_VERSION}"
    CT_Patch "ethtool" "${CT_ETHTOOL_VERSION}"
}

do_target_me_harder_ethtool_build() {
    CT_DoStep EXTRA "Installing target ethtool"
    mkdir -p "${CT_BUILD_DIR}/build-ethtool-target"
    CT_Pushd "${CT_BUILD_DIR}/build-ethtool-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    CFLAGS="-g -Os"                                             \
    "${CT_SRC_DIR}/ethtool-${CT_ETHTOOL_VERSION}/configure"     \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
