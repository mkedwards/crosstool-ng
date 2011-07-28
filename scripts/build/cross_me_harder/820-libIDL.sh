# Build script for libIDL

do_cross_me_harder_libIDL_get() {
    CT_GetFile "libIDL-${CT_LIBIDL_VERSION}" .tar.bz2 \
               http://ftp.gnome.org/pub/GNOME/sources/libIDL/0.8
}

do_cross_me_harder_libIDL_extract() {
    CT_Extract "libIDL-${CT_LIBIDL_VERSION}"
    CT_Patch "libIDL" "${CT_LIBIDL_VERSION}"
}

do_cross_me_harder_libIDL_build() {
    CT_DoStep EXTRA "Installing cross libIDL"
    mkdir -p "${CT_BUILD_DIR}/build-libIDL-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-libIDL-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    "${CT_SRC_DIR}/libIDL-${CT_LIBIDL_VERSION}/configure"       \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target libIDL"
    mkdir -p "${CT_BUILD_DIR}/build-libIDL-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libIDL-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/libIDL-${CT_LIBIDL_VERSION}/configure"       \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
