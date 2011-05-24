# Build script for latencytop

do_debug_latencytop_get() {
    CT_GetFile "latencytop-${CT_LATENCYTOP_VERSION}" .tar.gz http://www.latencytop.org/download/
}

do_debug_latencytop_extract() {
    CT_Extract "latencytop-${CT_LATENCYTOP_VERSION}"
    CT_Patch "latencytop" "${CT_LATENCYTOP_VERSION}"
}

do_debug_latencytop_build() {
    CT_DoStep INFO "Installing latencytop"
    rm -rf "${CT_BUILD_DIR}/build-latencytop"
    cp -a "${CT_SRC_DIR}/latencytop-${CT_LATENCYTOP_VERSION}" "${CT_BUILD_DIR}/build-latencytop"
    CT_Pushd "${CT_BUILD_DIR}/build-latencytop"

    CT_DoLog EXTRA "Building latencytop"
    CT_DoExecLog ALL \
        PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
        HOST_TUPLE="${CT_TARGET}" \
        make

    CT_DoLog EXTRA "Installing latencytop"
    mkdir -p "${CT_DEBUGROOT_DIR}"/usr/sbin
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

