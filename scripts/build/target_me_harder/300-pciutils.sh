# Build script for pciutils

do_target_me_harder_pciutils_get() {
    CT_GetFile "pciutils-${CT_PCIUTILS_VERSION}" \
               http://www.kernel.org/pub/software/utils/pciutils
}

do_target_me_harder_pciutils_extract() {
    CT_Extract "pciutils-${CT_PCIUTILS_VERSION}"
    CT_Patch "pciutils" "${CT_PCIUTILS_VERSION}"
}

do_target_me_harder_pciutils_build() {
    CT_DoStep EXTRA "Installing target pciutils"
    rm -rf "${CT_BUILD_DIR}/build-pciutils-target"
    cp -a "${CT_SRC_DIR}/pciutils-${CT_PCIUTILS_VERSION}" "${CT_BUILD_DIR}/build-pciutils-target"
    CT_Pushd "${CT_BUILD_DIR}/build-pciutils-target"
    
    CT_DoExecLog ALL make \
        PREFIX=/usr MANDIR=/usr/share/man STRIP= \
        CROSS_COMPILE=${CT_TARGET}- HOST=${CT_TARGET} RELEASE=2.6.y.z \
        OPT="-g -Os"

    CT_DoExecLog ALL make \
        PREFIX=/usr MANDIR=/usr/share/man STRIP= \
        DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
