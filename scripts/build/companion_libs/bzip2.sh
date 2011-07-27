# Build script for bzip2

do_bzip2_get() { :; }
do_bzip2_extract() { :; }
do_bzip2() { :; }
do_bzip2_target() { :; }

if [ "${CT_BZIP2}" = "y" -o "${CT_BZIP2_TARGET}" = "y" ]; then

do_bzip2_get() {
    CT_GetFile "bzip2-${CT_BZIP2_VERSION}" .tar.gz "http://bzip.org/${CT_BZIP2_VERSION}"
}

do_bzip2_extract() {
    CT_Extract "bzip2-${CT_BZIP2_VERSION}"
    CT_Patch "bzip2" "${CT_BZIP2_VERSION}"
}

if [ "${CT_BZIP2}" = "y" ]; then

do_bzip2() {
    CT_DoStep INFO "Installing bzip2"
    rm -rf "${CT_BUILD_DIR}/build-bzip2"
    cp -a "${CT_SRC_DIR}/bzip2-${CT_BZIP2_VERSION}" "${CT_BUILD_DIR}/build-bzip2"
    CT_Pushd "${CT_BUILD_DIR}/build-bzip2"

    CT_DoLog EXTRA "Configuring bzip2"

    CT_DoExecLog CFG                                        \
    CC="${CT_HOST}-gcc"                                     \
    AR="${CT_HOST}-ar"                                      \
    RANLIB="${CT_HOST}-ranlib"                              \
    CFLAGS="-g -Os -fPIC -DPIC"                             \
    ./configure                                             \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"              \
        --enable-shared                                     \
        --enable-static
    # --enable-shared because later steps may build a shared library linked against bzip2

    CT_DoLog EXTRA "Building bzip2"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing bzip2"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_BZIP2

if [ "${CT_BZIP2_TARGET}" = "y" ]; then

do_bzip2_target() {
    CT_DoStep INFO "Installing bzip2 for the target"
    rm -rf "${CT_BUILD_DIR}/build-bzip2-for-target"
    cp -a "${CT_SRC_DIR}/bzip2-${CT_BZIP2_VERSION}" "${CT_BUILD_DIR}/build-bzip2-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-bzip2-for-target"

    CT_DoLog EXTRA "Configuring bzip2"
    CT_DoExecLog CFG                                        \
    CC="${CT_TARGET}-gcc"                                   \
    AR="${CT_TARGET}-ar"                                    \
    RANLIB="${CT_TARGET}-ranlib"                            \
    CFLAGS="-g -Os -fPIC -DPIC"                             \
    ./configure                                             \
        --prefix=/usr                                       \
        --enable-shared

    CT_DoLog EXTRA "Building bzip2"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing bzip2"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_BZIP2_TARGET

fi # CT_BZIP2 || CT_BZIP2_TARGET
