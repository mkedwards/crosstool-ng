# Build script for elfutils

do_elfutils_get() { :; }
do_elfutils_extract() { :; }
do_elfutils() { :; }
do_elfutils_target() { :; }

if [ "${CT_ELFUTILS}" = "y" -o "${CT_ELFUTILS_TARGET}" = "y" ]; then

do_elfutils_get() {
    CT_GetFile "elfutils-${CT_ELFUTILS_VERSION}" .tar.bz2 https://fedorahosted.org/releases/e/l/elfutils/${CT_ELFUTILS_VERSION}/
}

do_elfutils_extract() {
    CT_Extract "elfutils-${CT_ELFUTILS_VERSION}"
    CT_Patch "elfutils" "${CT_ELFUTILS_VERSION}"
}

if [ "${CT_ELFUTILS}" = "y" ]; then

do_elfutils() {
    CT_DoStep INFO "Installing elfutils"
    mkdir -p "${CT_BUILD_DIR}/build-elfutils"
    CT_Pushd "${CT_BUILD_DIR}/build-elfutils"

    CT_DoLog EXTRA "Configuring elfutils"

    CT_DoExecLog CFG                                            \
    CC="${CT_HOST}-gcc"                                         \
    CFLAGS="-fPIC"                                              \
    "${CT_SRC_DIR}/elfutils-${CT_ELFUTILS_VERSION}/configure"   \
        --build=${CT_BUILD}                                     \
        --host=${CT_HOST}                                       \
        --target=${CT_TARGET}                                   \
        --prefix="${CT_PREFIX_DIR}"                             \
        --disable-shared                                        \
        --enable-static

    CT_DoLog EXTRA "Building elfutils"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing elfutils"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_ELFUTILS

if [ "${CT_ELFUTILS_TARGET}" = "y" ]; then

do_elfutils_target() {
    CT_DoStep INFO "Installing elfutils for the target"
    mkdir -p "${CT_BUILD_DIR}/build-elfutils-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-elfutils-for-target"

    CT_DoLog EXTRA "Configuring elfutils"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC"                                       \
    "${CT_SRC_DIR}/elfutils-${CT_ELFUTILS_VERSION}/configure"   \
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

    CT_DoLog EXTRA "Building elfutils"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing elfutils"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_ELFUTILS_TARGET

fi # CT_ELFUTILS || CT_ELFUTILS_TARGET
