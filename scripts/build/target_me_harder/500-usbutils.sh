# Build script for usbutils

do_target_me_harder_usbutils_get() {
    CT_GetFile "usbutils_${CT_USBUTILS_VERSION}.orig" .tar.gz               \
               {ftp,http}://ftp.de.debian.org/debian/pool/main/u/usbutils/
    # Create a link so that the following steps are easier to do:
    CT_Pushd "${CT_TARBALLS_DIR}"
    usbutils_ext=$(CT_GetFileExtension "usbutils_${CT_USBUTILS_VERSION}.orig")
    ln -sf "usbutils_${CT_USBUTILS_VERSION}.orig${usbutils_ext}"              \
           "usbutils-${CT_USBUTILS_VERSION}${usbutils_ext}"
    CT_Popd
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
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make \
        DESTDIR="${CT_SYSROOT_DIR}"                             \
        pkgconfigdir=/usr/lib/pkgconfig                         \
        shared_pkgconfigdir=/usr/lib/pkgconfig                  \
        install
    CT_Popd
    CT_EndStep
}
