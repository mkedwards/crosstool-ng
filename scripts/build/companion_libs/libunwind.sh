# Build script for libunwind

do_libunwind_get() { :; }
do_libunwind_extract() { :; }
do_libunwind() { :; }
do_libunwind_target() { :; }

if [ "${CT_LIBUNWIND}" = "y" -o "${CT_LIBUNWIND_TARGET}" = "y" ]; then

do_libunwind_get() {
    CT_GetFile "libunwind-${CT_LIBUNWIND_VERSION}" .tar.gz http://download.savannah.gnu.org/releases/libunwind/
}

do_libunwind_extract() {
    CT_Extract "libunwind-${CT_LIBUNWIND_VERSION}"
    CT_Patch "libunwind" "${CT_LIBUNWIND_VERSION}"
}

if [ "${CT_LIBUNWIND}" = "y" ]; then

do_libunwind() {
    CT_DoStep INFO "Installing libunwind"
    mkdir -p "${CT_BUILD_DIR}/build-libunwind"
    CT_Pushd "${CT_BUILD_DIR}/build-libunwind"

    CT_DoLog EXTRA "Configuring libunwind"

    CT_DoExecLog CFG                                            \
    CC="${CT_HOST}-gcc"                                         \
    CFLAGS="-fPIC"                                              \
    "${CT_SRC_DIR}/libunwind-${CT_LIBUNWIND_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_HOST}                                       \
        --target=${CT_TARGET}                                   \
        --prefix="${CT_PREFIX_DIR}"                             \
        --disable-shared                                        \
        --enable-static

    CT_DoLog EXTRA "Building libunwind"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing libunwind"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_LIBUNWIND

if [ "${CT_LIBUNWIND_TARGET}" = "y" ]; then

do_libunwind_target() {
    CT_DoStep INFO "Installing libunwind for the target"
    mkdir -p "${CT_BUILD_DIR}/build-libunwind-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libunwind-for-target"

    CT_DoLog EXTRA "Configuring libunwind"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC"                                       \
    "${CT_SRC_DIR}/libunwind-${CT_LIBUNWIND_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --target=${CT_TARGET}                                   \
        --cache-file="$(pwd)/config.cache"                      \
        --enable-cxx-exceptions                                 \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-shared                                         \
        --enable-static

    CT_DoLog EXTRA "Building libunwind"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing libunwind"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    rm -f "${CT_SYSROOT_DIR}"/usr/lib/libunwind*.la

    CT_Popd
    CT_EndStep
}

fi # CT_LIBUNWIND_TARGET

fi # CT_LIBUNWIND || CT_LIBUNWIND_TARGET
