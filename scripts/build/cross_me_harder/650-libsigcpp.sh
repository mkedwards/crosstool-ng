# Build script for libsigc++

do_cross_me_harder_libsigcpp_get() {
    CT_GetFile "libsigc++-${CT_LIBSIGCPP_VERSION}" \
               "http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.2/"
}

do_cross_me_harder_libsigcpp_extract() {
    CT_Extract "libsigc++-${CT_LIBSIGCPP_VERSION}"
    CT_Patch "libsigc++" "${CT_LIBSIGCPP_VERSION}"
}

do_cross_me_harder_libsigcpp_build() {
    CT_DoStep EXTRA "Installing cross libsigc++"
    mkdir -p "${CT_BUILD_DIR}/build-libsigc++-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-libsigc++-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    "${CT_SRC_DIR}/libsigc++-${CT_LIBSIGCPP_VERSION}/configure" \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target libsigc++"
    mkdir -p "${CT_BUILD_DIR}/build-libsigc++-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libsigc++-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -DNDEBUG"                                    \
    CXXFLAGS="-g -Os -DNDEBUG"                                  \
    "${CT_SRC_DIR}/libsigc++-${CT_LIBSIGCPP_VERSION}/configure" \
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
