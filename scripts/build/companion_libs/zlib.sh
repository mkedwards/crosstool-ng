# Build script for zlib

do_zlib_get() { :; }
do_zlib_extract() { :; }
do_zlib() { :; }
do_zlib_target() { :; }

if [ "${CT_ZLIB}" = "y" -o "${CT_ZLIB_TARGET}" = "y" ]; then

do_zlib_get() {
    CT_GetFile "zlib-${CT_ZLIB_VERSION}" .tar.gz http://www.zlib.net/
}

do_zlib_extract() {
    CT_Extract "zlib-${CT_ZLIB_VERSION}"
    CT_Patch "zlib" "${CT_ZLIB_VERSION}"
}

if [ "${CT_ZLIB}" = "y" ]; then

do_zlib() {
    CT_DoStep INFO "Installing zlib"
    rm -rf "${CT_BUILD_DIR}/build-zlib"
    cp -a "${CT_SRC_DIR}/zlib-${CT_ZLIB_VERSION}" "${CT_BUILD_DIR}/build-zlib"
    CT_Pushd "${CT_BUILD_DIR}/build-zlib"

    CT_DoLog EXTRA "Configuring zlib"

    CC="${CT_HOST}-gcc"                                     \
    AR="${CT_HOST}-ar"                                      \
    RANLIB="${CT_HOST}-ranlib"                              \
    CFLAGS="-fPIC"                                          \
    CT_DoExecLog CFG                                        \
    ./configure                                             \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"              \
        --disable-shared                                    \
        --enable-static

    CT_DoLog EXTRA "Building zlib"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing zlib"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_ZLIB

if [ "${CT_ZLIB_TARGET}" = "y" ]; then

do_zlib_target() {
    CT_DoStep INFO "Installing zlib for the target"
    rm -rf "${CT_BUILD_DIR}/build-zlib-for-target"
    cp -a "${CT_SRC_DIR}/zlib-${CT_ZLIB_VERSION}" "${CT_BUILD_DIR}/build-zlib-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-zlib-for-target"

    CT_DoLog EXTRA "Configuring zlib"
    CC="${CT_TARGET}-gcc"                                   \
    AR="${CT_TARGET}-ar"                                    \
    RANLIB="${CT_TARGET}-ranlib"                            \
    CFLAGS="-g -Os -fPIC"                                   \
    CT_DoExecLog CFG                                        \
    ./configure                                             \
        --prefix=/usr                                       \
        --enable-shared

    CT_DoLog EXTRA "Building zlib"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing zlib"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_ZLIB_TARGET

fi # CT_ZLIB || CT_ZLIB_TARGET
