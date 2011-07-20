# Build script for libusb

do_target_me_harder_libusb_get() {
    CT_GetFile "libusb-${CT_LIBUSB_VERSION}" \
               http://mesh.dl.sourceforge.net/sourceforge/libusb/libusb-1.0/libusb-${CT_LIBUSB_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_target_me_harder_libusb_extract() {
    CT_Extract "libusb-${CT_LIBUSB_VERSION}"
    CT_Patch "libusb" "${CT_LIBUSB_VERSION}"
}

do_target_me_harder_libusb_build() {
    CT_DoStep EXTRA "Installing target libusb"
    mkdir -p "${CT_BUILD_DIR}/build-libusb-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libusb-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/libusb-${CT_LIBUSB_VERSION}/configure"       \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-examples-build
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
