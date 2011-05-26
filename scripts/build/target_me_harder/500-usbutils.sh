# Build script for usbutils

do_target_me_harder_usbutils_get() {
    CT_GetFile "usbutils-${CT_USBUTILS_VERSION}" \
               http://www.kernel.org/pub/linux/utils/usb/usbutils
}

do_target_me_harder_usbutils_extract() {
    CT_Extract "usbutils-${CT_USBUTILS_VERSION}"
    CT_Patch "usbutils" "${CT_USBUTILS_VERSION}"
}

do_target_me_harder_usbutils_build() {
    CT_DoStep EXTRA "Installing target usbutils"
    mkdir -p "${CT_BUILD_DIR}/build-usbutils-target"
    CT_Pushd "${CT_BUILD_DIR}/build-usbutils-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    "${CT_SRC_DIR}/usbutils-${CT_USBUTILS_VERSION}/configure"   \
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
