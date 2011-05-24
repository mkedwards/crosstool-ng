# Build script for libpcap

do_cross_me_harder_libpcap_get() {
    CT_GetFile "libpcap-${CT_LIBPCAP_VERSION}" \
               "http://www.tcpdump.org/release/"
}

do_cross_me_harder_libpcap_extract() {
    CT_Extract "libpcap-${CT_LIBPCAP_VERSION}"
    CT_Patch "libpcap" "${CT_LIBPCAP_VERSION}"
}

do_cross_me_harder_libpcap_build() {
    CT_DoStep EXTRA "Installing cross libpcap"
    rm -rf "${CT_BUILD_DIR}/build-libpcap-cross"
    cp -a "${CT_SRC_DIR}/libpcap-${CT_LIBPCAP_VERSION}" "${CT_BUILD_DIR}/build-libpcap-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-libpcap-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    ./configure                                                 \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"                         \
            --with-pcap=linux                                   \
            --with-libnl
    CT_DoExecLog ALL \
    make                                                        \
            INCLS="-I. -I${CT_PREFIX_DIR}/include"              \
            all
    CT_DoExecLog ALL \
    make                                                        \
            INCLS="-I. -I${CT_PREFIX_DIR}/include"              \
            install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target libpcap"
    rm -rf "${CT_BUILD_DIR}/build-libpcap-target"
    cp -a "${CT_SRC_DIR}/libpcap-${CT_LIBPCAP_VERSION}" "${CT_BUILD_DIR}/build-libpcap-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libpcap-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    ./configure                                                 \
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
            --with-pcap=linux                                   \
            --with-libnl
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
