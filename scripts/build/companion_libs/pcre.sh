# Build script for pcre

do_pcre_get() { :; }
do_pcre_extract() { :; }
do_pcre() { :; }
do_pcre_target() { :; }

if [ "${CT_PCRE}" = "y" -o "${CT_PCRE_TARGET}" = "y" ]; then

do_pcre_get() {
    CT_GetFile "pcre-${CT_PCRE_VERSION}" .tar.gz    \
               http://mesh.dl.sourceforge.net/sourceforge/pcre/pcre/${CT_PCRE_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_pcre_extract() {
    CT_Extract "pcre-${CT_PCRE_VERSION}"
    CT_Patch "pcre" "${CT_PCRE_VERSION}"
}

if [ "${CT_PCRE}" = "y" ]; then

do_pcre() {
    CT_DoStep INFO "Installing pcre"
    mkdir -p "${CT_BUILD_DIR}/build-pcre"
    CT_Pushd "${CT_BUILD_DIR}/build-pcre"

    CT_DoLog EXTRA "Configuring pcre"

    CT_DoExecLog CFG                                            \
    CC="${CT_HOST}-gcc"                                         \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/pcre-${CT_PCRE_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_HOST}                                       \
        --target=${CT_TARGET}                                   \
        --prefix="${CT_PREFIX_DIR}"                             \
        --enable-unicode-properties                             \
        --enable-pcregrep-libz                                  \
        --enable-pcregrep-libbz2                                \
        --enable-shared                                         \
        --enable-static
    # --enable-shared because glib builds a shared library linked against pcre

    CT_DoLog EXTRA "Building pcre"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing pcre"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_PCRE

if [ "${CT_PCRE_TARGET}" = "y" ]; then

do_pcre_target() {
    CT_DoStep INFO "Installing pcre for the target"
    mkdir -p "${CT_BUILD_DIR}/build-pcre-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-pcre-for-target"

    CT_DoLog EXTRA "Configuring pcre"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/pcre-${CT_PCRE_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --target=${CT_TARGET}                                   \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-unicode-properties                             \
        --enable-pcregrep-libz                                  \
        --enable-pcregrep-libbz2                                \
        --enable-shared                                         \
        --enable-static

    CT_DoLog EXTRA "Building pcre"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing pcre"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_PCRE_TARGET

fi # CT_PCRE || CT_PCRE_TARGET
