# Build script for mm-common

do_cross_me_harder_mm_common_get() {
    CT_GetFile "mm-common-${CT_MM_COMMON_VERSION}" \
               http://ftp.gnome.org/pub/GNOME/sources/mm-common/0.9/
}

do_cross_me_harder_mm_common_extract() {
    CT_Extract "mm-common-${CT_MM_COMMON_VERSION}"
    CT_Patch "mm-common" "${CT_MM_COMMON_VERSION}"
}

do_cross_me_harder_mm_common_build() {
    CT_DoStep EXTRA "Installing cross mm-common"
    mkdir -p "${CT_BUILD_DIR}/build-mm-common-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-mm-common-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}" \
    "${CT_SRC_DIR}/mm-common-${CT_MM_COMMON_VERSION}/configure" \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make \
        pkgconfigdir="${CT_PREFIX_DIR}"/lib/pkgconfig           \
        shared_pkgconfigdir="${CT_PREFIX_DIR}"/lib/pkgconfig    \
        install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target mm-common"
    mkdir -p "${CT_BUILD_DIR}/build-mm-common-target"
    CT_Pushd "${CT_BUILD_DIR}/build-mm-common-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -DNDEBUG"                                    \
    CXXFLAGS="-g -Os -DNDEBUG"                                  \
    "${CT_SRC_DIR}/mm-common-${CT_MM_COMMON_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make \
        DESTDIR="${CT_SYSROOT_DIR}"                             \
        pkgconfigdir=/usr/lib/pkgconfig                         \
        shared_pkgconfigdir=/usr/lib/pkgconfig                  \
        install
    CT_Popd
    CT_EndStep
}
