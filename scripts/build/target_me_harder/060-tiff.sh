# Build script for tiff

do_target_me_harder_tiff_get() {
    CT_GetFile "tiff-${CT_TIFF_VERSION}" \
               http://download.osgeo.org/libtiff
}

do_target_me_harder_tiff_extract() {
    CT_Extract "tiff-${CT_TIFF_VERSION}"
    CT_Patch "tiff" "${CT_TIFF_VERSION}"
}

do_target_me_harder_tiff_build() {
    CT_DoStep EXTRA "Installing target tiff"
    mkdir -p "${CT_BUILD_DIR}/build-tiff-target"
    CT_Pushd "${CT_BUILD_DIR}/build-tiff-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/tiff-${CT_TIFF_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-rpath                                         \
        --without-x                                             \
        --enable-cxx                                            \
        --enable-jpeg                                           \
        --enable-zlib

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
