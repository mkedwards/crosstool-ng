# Build script for alsa-utils

do_target_me_harder_alsa_utils_get() {
    CT_GetFile "alsa-utils-${CT_ALSA_UTILS_VERSION}" .tar.bz2 \
               ftp://ftp.alsa-project.org/pub/utils
}

do_target_me_harder_alsa_utils_extract() {
    CT_Extract "alsa-utils-${CT_ALSA_UTILS_VERSION}"
    CT_Patch "alsa-utils" "${CT_ALSA_UTILS_VERSION}"
}

do_target_me_harder_alsa_utils_build() {
    CT_DoStep EXTRA "Installing target alsa-utils"

    CT_Pushd "${CT_SRC_DIR}/alsa-utils-${CT_ALSA_UTILS_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    rm -rf "${CT_BUILD_DIR}/build-alsa-utils-target"
    cp -a "${CT_SRC_DIR}/alsa-utils-${CT_ALSA_UTILS_VERSION}" "${CT_BUILD_DIR}/build-alsa-utils-target"
    CT_Pushd "${CT_BUILD_DIR}/build-alsa-utils-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    CXXFLAGS="-g -Os"                                           \
    "${CT_SRC_DIR}/alsa-utils-${CT_ALSA_UTILS_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-xmlto

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install
    CT_Popd
    CT_EndStep
}
