# Build script for clips-core

do_cross_me_harder_clips_core_get() {
    CT_GetFile "clips-core-${CT_CLIPS_CORE_VERSION}" .tgz \
               "http://sourceforge.net/projects/clipsrules/files/CLIPS/6.30"
}

do_cross_me_harder_clips_core_extract() {
    CT_Extract "clips-core-${CT_CLIPS_CORE_VERSION}"
    CT_Patch "clips-core" "${CT_CLIPS_CORE_VERSION}"
}

do_cross_me_harder_clips_core_build() {
    CT_DoStep EXTRA "Installing host clips-core"

    CT_Pushd "${CT_SRC_DIR}/clips-core-${CT_CLIPS_CORE_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    rm -rf "${CT_BUILD_DIR}/build-clips-core-host"
    cp -a "${CT_SRC_DIR}/clips-core-${CT_CLIPS_CORE_VERSION}" "${CT_BUILD_DIR}/build-clips-core-host"
    CT_Pushd "${CT_BUILD_DIR}/build-clips-core-host"
    
    CT_DoExecLog CFG \
    PKG_CONFIG_LIBDIR="${CT_PREFIX_DIR}/lib/pkgconfig"          \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    ./configure                                                 \
            --build=${CT_BUILD}                                 \
            --prefix="${CT_PREFIX_DIR}"                         \
            --enable-debug
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing cross clips-core"
    rm -rf "${CT_BUILD_DIR}/build-clips-core-cross"
    cp -a "${CT_SRC_DIR}/clips-core-${CT_CLIPS_CORE_VERSION}" "${CT_BUILD_DIR}/build-clips-core-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-clips-core-cross"
    
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    ./configure                                                 \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-debug
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
