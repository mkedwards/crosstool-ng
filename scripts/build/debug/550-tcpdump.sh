# Build script for tcpdump

do_debug_tcpdump_get() {
    CT_GetFile "tcpdump-${CT_TCPDUMP_VERSION}" .tar.gz \
               "http://www.tcpdump.org/release/"
}

do_debug_tcpdump_extract() {
    CT_Extract "tcpdump-${CT_TCPDUMP_VERSION}"
    CT_Patch "tcpdump" "${CT_TCPDUMP_VERSION}"
}

do_debug_tcpdump_build() {
    CT_DoStep EXTRA "Installing cross tcpdump"
    mkdir -p "${CT_BUILD_DIR}/build-tcpdump-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-tcpdump-cross"
    
    CT_DoExecLog CFG \
    PKG_CONFIG_LIBDIR="${CT_PREFIX_DIR}/lib/pkgconfig"          \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/tcpdump-${CT_TCPDUMP_VERSION}/configure"     \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"                         \
            --enable-ipv6                                       \
            --disable-smb
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target tcpdump"
    mkdir -p "${CT_BUILD_DIR}/build-tcpdump-target"
    CT_Pushd "${CT_BUILD_DIR}/build-tcpdump-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "${CT_SRC_DIR}/tcpdump-${CT_TCPDUMP_VERSION}/configure"     \
            --build=${CT_BUILD}                                 \
            --host=${CT_TARGET}                                 \
            --cache-file="$(pwd)/config.cache"                  \
            --sysconfdir=/etc                                   \
            --localstatedir=/var                                \
            --mandir=/usr/share/man                             \
            --infodir=/usr/share/info                           \
            --prefix=/usr                                       \
            --with-bison="${CT_TARGET}-bison"                   \
            --with-flex="${CT_TARGET}-flex"                     \
            --enable-ipv6                                       \
            --disable-smb
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
