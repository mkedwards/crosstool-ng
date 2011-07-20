# Build script for orc

do_cross_me_harder_orc_get() {
    CT_GetFile "orc-${CT_ORC_VERSION}" .tar.gz \
               http://code.entropywave.com/download/orc
}

do_cross_me_harder_orc_extract() {
    CT_Extract "orc-${CT_ORC_VERSION}"
    CT_Patch "orc" "${CT_ORC_VERSION}"
}

do_cross_me_harder_orc_build() {
    CT_DoStep EXTRA "Installing host orc"
    mkdir -p "${CT_BUILD_DIR}/build-orc-host"
    CT_Pushd "${CT_BUILD_DIR}/build-orc-host"
    
    CT_DoExecLog CFG \
    PKG_CONFIG_LIBDIR="${CT_PREFIX_DIR}/lib/pkgconfig"          \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/orc-${CT_ORC_VERSION}/configure"             \
            --build=${CT_BUILD}                                 \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing cross orc"
    mkdir -p "${CT_BUILD_DIR}/build-orc-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-orc-cross"
    
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/orc-${CT_ORC_VERSION}/configure"             \
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
