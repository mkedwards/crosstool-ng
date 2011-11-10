# Build script for udev

do_target_me_harder_udev_get() {
    CT_GetFile "udev_${CT_UDEV_VERSION}.orig" .tar.gz               \
               {ftp,http}://ftp.de.debian.org/debian/pool/main/u/udev/
    # Create a link so that the following steps are easier to do:
    CT_Pushd "${CT_TARBALLS_DIR}"
    udev_ext=$(CT_GetFileExtension "udev_${CT_UDEV_VERSION}.orig")
    ln -sf "udev_${CT_UDEV_VERSION}.orig${udev_ext}"              \
           "udev-${CT_UDEV_VERSION}${udev_ext}"
    CT_Popd
}

do_target_me_harder_udev_extract() {
    CT_Extract "udev-${CT_UDEV_VERSION}"
    CT_Patch "udev" "${CT_UDEV_VERSION}"
}

do_target_me_harder_udev_build() {
    CT_DoStep EXTRA "Installing target udev"

    CT_Pushd "${CT_SRC_DIR}/udev-${CT_UDEV_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    mkdir -p "${CT_BUILD_DIR}/build-udev-target"
    CT_Pushd "${CT_BUILD_DIR}/build-udev-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    "${CT_SRC_DIR}/udev-${CT_UDEV_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --libexecdir=/etc/udev                                  \
        --enable-extras                                         \
        --disable-introspection                                 \
        --disable-gtk-doc                                       \
        --with-pci-ids-path=/usr/share/pci.ids
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
