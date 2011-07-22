# Build script for alsa-plugins

do_target_me_harder_alsa_plugins_get() {
    CT_GetFile "alsa-plugins-${CT_ALSA_PLUGINS_VERSION}" .tar.bz2 \
               ftp://ftp.alsa-project.org/pub/plugins
}

do_target_me_harder_alsa_plugins_extract() {
    CT_Extract "alsa-plugins-${CT_ALSA_PLUGINS_VERSION}"
    CT_Patch "alsa-plugins" "${CT_ALSA_PLUGINS_VERSION}"
}

do_target_me_harder_alsa_plugins_build() {
    CT_DoStep EXTRA "Installing target alsa-plugins"

    CT_Pushd "${CT_SRC_DIR}/alsa-plugins-${CT_ALSA_PLUGINS_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    mkdir -p "${CT_BUILD_DIR}/build-alsa-plugins-target"
    CT_Pushd "${CT_BUILD_DIR}/build-alsa-plugins-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/alsa-plugins-${CT_ALSA_PLUGINS_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-speex=lib

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install
    CT_Popd
    CT_EndStep
}
