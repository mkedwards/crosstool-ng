# Build script for openssl

do_target_me_harder_openssl_get() {
    CT_GetFile "openssl-${CT_OPENSSL_VERSION}" .tar.gz \
               http://www.openssl.org/source
}

do_target_me_harder_openssl_extract() {
    CT_Extract "openssl-${CT_OPENSSL_VERSION}"
    CT_Patch "openssl" "${CT_OPENSSL_VERSION}"
}

do_target_me_harder_openssl_build() {
    local linux_subtype

    CT_DoStep EXTRA "Installing target openssl"
    rm -rf "${CT_BUILD_DIR}/build-openssl-target"
    cp -a "${CT_SRC_DIR}/openssl-${CT_OPENSSL_VERSION}" "${CT_BUILD_DIR}/build-openssl-target"
    CT_Pushd "${CT_BUILD_DIR}/build-openssl-target"

    case "${CT_ARCH}:${CT_ARCH_BITNESS}" in
        arm:*)      linux_subtype="${CT_ARCH}";;
        *)          linux_subtype="elf";;
    esac

    CT_DoExecLog CFG \
    CROSS_COMPILE=${CT_TARGET}-                            \
    ./Configure                                            \
    --prefix=/usr                                          \
    --openssldir=/usr/share                                \
    linux-${linux_subtype}-Os                              \
    shared                                                 \
    zlib-dynamic                                           \

    CT_DoExecLog ALL make
    CT_DoExecLog ALL make INSTALL_PREFIX="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}
