# Build script for xz

do_xz_get() { :; }
do_xz_extract() { :; }
do_xz() { :; }
do_xz_target() { :; }

if [ "${CT_XZ}" = "y" -o "${CT_XZ_TARGET}" = "y" ]; then

do_xz_get() {
    CT_GetFile "xz-${CT_XZ_VERSION}" .tar.bz2 http://tukaani.org/xz
}

do_xz_extract() {
    CT_Extract "xz-${CT_XZ_VERSION}"
    CT_Patch "xz" "${CT_XZ_VERSION}"
}

if [ "${CT_XZ}" = "y" ]; then

do_xz() {
    CT_DoStep INFO "Installing xz"
    rm -rf "${CT_BUILD_DIR}/build-xz"
    cp -a "${CT_SRC_DIR}/xz-${CT_XZ_VERSION}" "${CT_BUILD_DIR}/build-xz"
    CT_Pushd "${CT_BUILD_DIR}/build-xz"

    CT_DoLog EXTRA "Configuring xz"

    CT_DoExecLog CFG                                        \
    CC="${CT_HOST}-gcc"                                     \
    AR="${CT_HOST}-ar"                                      \
    RANLIB="${CT_HOST}-ranlib"                              \
    CFLAGS="-g -Os -fPIC -DPIC"                             \
    ./configure                                             \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"              \
        --enable-shared

    CT_DoLog EXTRA "Building xz"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing xz"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_XZ

if [ "${CT_XZ_TARGET}" = "y" ]; then

do_xz_target() {
    CT_DoStep INFO "Installing xz for the target"
    rm -rf "${CT_BUILD_DIR}/build-xz-for-target"
    cp -a "${CT_SRC_DIR}/xz-${CT_XZ_VERSION}" "${CT_BUILD_DIR}/build-xz-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-xz-for-target"

    CT_DoLog EXTRA "Configuring xz"
    CT_DoExecLog CFG                                        \
    CC="${CT_TARGET}-gcc"                                   \
    AR="${CT_TARGET}-ar"                                    \
    RANLIB="${CT_TARGET}-ranlib"                            \
    CFLAGS="-g -Os -fPIC -DPIC"                             \
    ./configure                                             \
        --prefix=/usr                                       \
        --enable-shared

    CT_DoLog EXTRA "Building xz"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing xz"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_XZ_TARGET

fi # CT_XZ || CT_XZ_TARGET
