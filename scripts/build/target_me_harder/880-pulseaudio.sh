# Build script for pulseaudio

do_target_me_harder_pulseaudio_get() {
    CT_GetFile "pulseaudio-${CT_PULSEAUDIO_VERSION}" .tar.gz \
               http://freedesktop.org/software/pulseaudio/releases
}

do_target_me_harder_pulseaudio_extract() {
    CT_Extract "pulseaudio-${CT_PULSEAUDIO_VERSION}"
    CT_Patch "pulseaudio" "${CT_PULSEAUDIO_VERSION}"
}

do_target_me_harder_pulseaudio_build() {
    CT_DoStep EXTRA "Installing target pulseaudio"

    CT_Pushd "${CT_SRC_DIR}/pulseaudio-${CT_PULSEAUDIO_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    mkdir -p "${CT_BUILD_DIR}/build-pulseaudio-target"
    CT_Pushd "${CT_BUILD_DIR}/build-pulseaudio-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/pulseaudio-${CT_PULSEAUDIO_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-udev-rules-dir=/etc/udev/rules.d                 \

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install
    CT_Popd
    CT_EndStep
}
