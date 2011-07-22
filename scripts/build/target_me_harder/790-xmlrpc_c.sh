# Build script for xmlrpc-c

do_target_me_harder_xmlrpc_c_get() {
    CT_GetFile "xmlrpc-c-${CT_XMLRPC_C_VERSION}" .tgz \
               "http://mesh.dl.sourceforge.net/sourceforge/xmlrpc-c/Xmlrpc-c%20Super%20Stable/${CT_XMLRPC_C_VERSION}"
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_target_me_harder_xmlrpc_c_extract() {
    CT_Extract "xmlrpc-c-${CT_XMLRPC_C_VERSION}"
    CT_Patch "xmlrpc-c" "${CT_XMLRPC_C_VERSION}"
}

do_target_me_harder_xmlrpc_c_build() {
    CT_DoStep EXTRA "Installing target xmlrpc-c"
    mkdir -p "${CT_BUILD_DIR}/build-xmlrpc-c-target"
    CT_Pushd "${CT_BUILD_DIR}/build-xmlrpc-c-target"

    mkdir -p indirect-configs
    cat >indirect-configs/curl-config <<EOT
${CT_SYSROOT_DIR}/usr/bin/curl-config "\$@"
EOT
    cat >indirect-configs/xml2-config <<EOT
${CT_SYSROOT_DIR}/usr/bin/xml2-config --prefix=${CT_SYSROOT_DIR}/usr --exec-prefix=/usr "\$@"
EOT
    chmod 755 indirect-configs/curl-config indirect-configs/xml2-config

    cp ../../config.cache .
    CT_DoExecLog CFG \
    PATH="${CT_BUILD_DIR}/build-xmlrpc-c-target/indirect-configs:${PATH}" \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    CXXFLAGS="-g -Os"                                           \
    "${CT_SRC_DIR}/xmlrpc-c-${CT_XMLRPC_C_VERSION}/configure"   \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-curl                                             \
        --enable-libxml2-backend

    CT_DoExecLog ALL make ${JOBSFLAGS} CADD="-fPIC -DPIC"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install
    CT_Popd
    CT_EndStep
}
