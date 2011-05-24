# Build script for gmock

do_debug_gmock_get() {
    CT_GetFile "gmock-${CT_GMOCK_VERSION}" .zip \
               http://googlemock.googlecode.com/files/
}

do_debug_gmock_extract() {
    CT_Extract "gmock-${CT_GMOCK_VERSION}"
    CT_Patch "gmock" "${CT_GMOCK_VERSION}"
}

do_debug_gmock_build() {
    CT_DoStep INFO "Installing gmock"
    rm -rf "${CT_BUILD_DIR}/build-gmock"
    cp -a "${CT_SRC_DIR}/gmock-${CT_GMOCK_VERSION}" "${CT_BUILD_DIR}/build-gmock"
    CT_Pushd "${CT_BUILD_DIR}/build-gmock"

    CT_DoLog EXTRA "Configuring gmock"

    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv

    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    "./configure"                                               \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-tls

    CT_DoLog EXTRA "Building gmock"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing gmock"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

