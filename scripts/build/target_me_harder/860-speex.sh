# Build script for speex

do_target_me_harder_speex_get() {
    CT_GetFile "speex-${CT_SPEEX_VERSION}" .tar.gz \
               http://downloads.xiph.org/releases/speex
}

do_target_me_harder_speex_extract() {
    CT_Extract "speex-${CT_SPEEX_VERSION}"
    CT_Patch "speex" "${CT_SPEEX_VERSION}"
}

do_target_me_harder_speex_build() {
    CT_DoStep EXTRA "Installing target speex"
    mkdir -p "${CT_BUILD_DIR}/build-speex-target"
    CT_Pushd "${CT_BUILD_DIR}/build-speex-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/speex-${CT_SPEEX_VERSION}/configure"         \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-oggtest                                       \
        --without-ogg

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
