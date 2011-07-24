# Build script for glib

do_cross_me_harder_glib_get() {
    CT_GetFile "glib-${CT_GLIB_VERSION}" \
               http://ftp.gnome.org/pub/GNOME/sources/glib/2.28
}

do_cross_me_harder_glib_extract() {
    CT_Extract "glib-${CT_GLIB_VERSION}"
    CT_Patch "glib" "${CT_GLIB_VERSION}"
}

do_cross_me_harder_glib_build() {
    CT_DoStep EXTRA "Installing cross glib"
    mkdir -p "${CT_BUILD_DIR}/build-glib-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-glib-cross"
    
    CT_DoExecLog CFG \
    PCRE_CFLAGS="`pkg-config --cflags libpcre`"                 \
    PCRE_LIBS="`(pkg-config --libs libpcre && pkg-config --libs-only-L libpcre | sed -e 's/-L/-Wl,-rpath=/g') | tr '\n' ' '`" \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    "${CT_SRC_DIR}/glib-${CT_GLIB_VERSION}/configure"           \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"                         \
            --with-pcre=system                                  \
            --with-threads=posix
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target glib"
    mkdir -p "${CT_BUILD_DIR}/build-glib-target"
    CT_Pushd "${CT_BUILD_DIR}/build-glib-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -DNDEBUG"                                    \
    CXXFLAGS="-g -Os -DNDEBUG"                                  \
    "${CT_SRC_DIR}/glib-${CT_GLIB_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-man                                           \
        --with-pcre=system                                      \
        --with-threads=posix
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
