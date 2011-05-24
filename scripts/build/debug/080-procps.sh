# Build script for procps

do_debug_procps_get() {
    CT_GetFile "procps-${CT_PROCPS_VERSION}" .tar.gz \
               http://procps.sourceforge.net/
    # Downloading from sourceforge leaves garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_debug_procps_extract() {
    CT_Extract "procps-${CT_PROCPS_VERSION}"
    CT_Patch "procps" "${CT_PROCPS_VERSION}"
}

do_debug_procps_build() {
    CT_DoStep INFO "Installing procps"
    rm -rf "${CT_BUILD_DIR}/build-procps"
    cp -a "${CT_SRC_DIR}/procps-${CT_PROCPS_VERSION}" "${CT_BUILD_DIR}/build-procps"
    CT_Pushd "${CT_BUILD_DIR}/build-procps"

    CT_DoLog EXTRA "Building procps"
    CT_DoExecLog ALL make \
    CC="${CT_TARGET}-gcc"                                       \
    AR="${CT_TARGET}-ar"                                        \
    RANLIB="${CT_TARGET}-ranlib"                                \
    W_SHOWFROM="-DW_SHOWFROM"                                   \
    lib64=lib                                                   \
    CPPFLAGS=""                                                 \
    CFLAGS="-g -Os"                                             \
    all

    CT_DoLog EXTRA "Installing procps"
    CT_DoExecLog ALL make \
    CC="${CT_TARGET}-gcc"                                       \
    AR="${CT_TARGET}-ar"                                        \
    RANLIB="${CT_TARGET}-ranlib"                                \
    W_SHOWFROM="-DW_SHOWFROM"                                   \
    lib64=lib                                                   \
    CPPFLAGS=""                                                 \
    CFLAGS="-g -Os"                                             \
    install="install -D"                                        \
    ln_f="ln -sf"                                               \
    ldconfig="echo"                                             \
    DESTDIR="${CT_DEBUGROOT_DIR}"                               \
    install

    CT_Popd
    CT_EndStep
}

