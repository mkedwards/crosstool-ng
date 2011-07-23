# Build script for pangomm

do_target_me_harder_pangomm_get() {
    CT_GetFile "pangomm-${CT_PANGOMM_VERSION}" .tar.bz2 \
               http://ftp.gnome.org/pub/GNOME/sources/pangomm/2.28
}

do_target_me_harder_pangomm_extract() {
    CT_Extract "pangomm-${CT_PANGOMM_VERSION}"
    CT_Patch "pangomm" "${CT_PANGOMM_VERSION}"
}

do_target_me_harder_pangomm_build() {
    CT_DoStep EXTRA "Installing target pangomm"
    mkdir -p "${CT_BUILD_DIR}/build-pangomm-target"
    CT_Pushd "${CT_BUILD_DIR}/build-pangomm-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/pangomm-${CT_PANGOMM_VERSION}/configure"     \
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
