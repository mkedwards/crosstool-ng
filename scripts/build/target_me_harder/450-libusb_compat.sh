# Build script for libusb-compat

do_target_me_harder_libusb_compat_get() {
    CT_GetFile "libusb-compat-${CT_LIBUSB_COMPAT_VERSION}" \
               http://mesh.dl.sourceforge.net/sourceforge/libusb/libusb-compat-0.1/libusb-compat-${CT_LIBUSB_COMPAT_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_target_me_harder_libusb_compat_extract() {
    CT_Extract "libusb-compat-${CT_LIBUSB_COMPAT_VERSION}"
    CT_Patch "libusb-compat" "${CT_LIBUSB_COMPAT_VERSION}"
}

do_target_me_harder_libusb_compat_build() {
    CT_DoStep EXTRA "Installing target libusb-compat"
    mkdir -p "${CT_BUILD_DIR}/build-libusb-compat-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libusb-compat-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/libusb-compat-${CT_LIBUSB_COMPAT_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
