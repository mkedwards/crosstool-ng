# Build script for libtool

CT_LIBTOOL_VERSION=2.2.6b

do_companion_tools_libtool_get() {
    CT_GetFile "libtool-${CT_LIBTOOL_VERSION}" \
               {ftp,http}://ftp.gnu.org/gnu/libtool
}

do_companion_tools_libtool_extract() {
    CT_Extract "libtool-${CT_LIBTOOL_VERSION}"
    CT_DoExecLog ALL chmod -R u+w "${CT_SRC_DIR}/libtool-${CT_LIBTOOL_VERSION}"
    CT_Patch "libtool" "${CT_LIBTOOL_VERSION}"
}

do_companion_tools_libtool_build() {
    CT_DoStep EXTRA "Installing libtool"
    mkdir -p "${CT_BUILD_DIR}/build-libtool"
    CT_Pushd "${CT_BUILD_DIR}/build-libtool"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/libtool-${CT_LIBTOOL_VERSION}/configure" \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep
}

do_companion_tools_libtool_build_for_target() {
    CT_DoStep EXTRA "Installing libtool for the target"
    mkdir -p "${CT_BUILD_DIR}/build-libtool-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libtool-for-target"

    CT_DoLog EXTRA "Configuring libtool for the target"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/libtool-${CT_LIBTOOL_VERSION}/configure"     \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --target=${CT_TARGET}                                   \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-shared                                         \
        --enable-static

    CT_DoLog EXTRA "Building libtool for the target"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing libtool for the target"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}
