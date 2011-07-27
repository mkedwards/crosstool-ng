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

    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    ./configure                                                 \
            --build=${CT_BUILD}                                 \
            --host=${CT_HOST}                                   \
            --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"              \
            --enable-shared

    CT_DoLog EXTRA "Building xz"
    CT_DoExecLog ALL make ${JOBSFLAGS}

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
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    CXXFLAGS="-g -Os -fPIC -DPIC"                               \
    ./configure                                                 \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-shared                                         \

    CT_DoLog EXTRA "Building xz"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing xz"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" pkgconfigdir=/usr/lib/pkgconfig install

    CT_Popd
    CT_EndStep
}

fi # CT_XZ_TARGET

fi # CT_XZ || CT_XZ_TARGET
