# Build script for glibmm

do_cross_me_harder_glibmm_get() {
    CT_GetFile "glibmm-${CT_GLIBMM_VERSION}" \
               http://ftp.gnome.org/pub/GNOME/sources/glibmm/2.28/
}

do_cross_me_harder_glibmm_extract() {
    CT_Extract "glibmm-${CT_GLIBMM_VERSION}"
    CT_Patch "glibmm" "${CT_GLIBMM_VERSION}"
}

do_cross_me_harder_glibmm_build() {
    CT_DoStep EXTRA "Installing cross glibmm"
    mkdir -p "${CT_BUILD_DIR}/build-glibmm-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-glibmm-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}" \
    "${CT_SRC_DIR}/glibmm-${CT_GLIBMM_VERSION}/configure"       \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target glibmm"
    mkdir -p "${CT_BUILD_DIR}/build-glibmm-target"
    CT_Pushd "${CT_BUILD_DIR}/build-glibmm-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -DNDEBUG"                                    \
    CXXFLAGS="-g -Os -DNDEBUG"                                  \
    "${CT_SRC_DIR}/glibmm-${CT_GLIBMM_VERSION}/configure"       \
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
