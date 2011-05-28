# Build script for libxml2

do_target_me_harder_libxml2_get() {
    CT_GetFile "libxml2-${CT_LIBXML2_VERSION}" .tar.gz \
               http://xmlsoft.org/sources
}

do_target_me_harder_libxml2_extract() {
    CT_Extract "libxml2-${CT_LIBXML2_VERSION}"
    CT_Patch "libxml2" "${CT_LIBXML2_VERSION}"
}

do_target_me_harder_libxml2_build() {
    CT_DoStep EXTRA "Installing target libxml2"
    mkdir -p "${CT_BUILD_DIR}/build-libxml2-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libxml2-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/libxml2-${CT_LIBXML2_VERSION}/configure"     \
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
