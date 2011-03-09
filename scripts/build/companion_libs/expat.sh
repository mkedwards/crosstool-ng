# Build script for expat

do_expat_get() { :; }
do_expat_extract() { :; }
do_expat() { :; }
do_expat_target() { :; }

if [ "${CT_EXPAT}" = "y" -o "${CT_EXPAT_TARGET}" = "y" ]; then

do_expat_get() {
    CT_GetFile "expat-${CT_EXPAT_VERSION}" .tar.gz    \
               http://mesh.dl.sourceforge.net/sourceforge/expat/expat/${CT_EXPAT_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_expat_extract() {
    CT_Extract "expat-${CT_EXPAT_VERSION}"
    CT_Patch "expat" "${CT_EXPAT_VERSION}"
}

if [ "${CT_EXPAT}" = "y" ]; then

do_expat() {
    local -a expat_opts

    CT_DoStep INFO "Installing expat"
    mkdir -p "${CT_BUILD_DIR}/build-expat"
    CT_Pushd "${CT_BUILD_DIR}/build-expat"

    CT_DoLog EXTRA "Configuring expat"

    if [ "${CT_COMPLIBS_SHARED}" = "y" ]; then
        expat_opts+=( --enable-shared --disable-static )
    else
        expat_opts+=( --disable-shared --enable-static )
    fi

    CC="${CT_HOST}-gcc"                                         \
    CFLAGS="-fPIC"                                              \
    CT_DoExecLog CFG                                            \
    "${CT_SRC_DIR}/expat-${CT_EXPAT_VERSION}/configure"         \
        --build=${CT_BUILD}                                     \
        --host=${CT_HOST}                                       \
        --target=${CT_TARGET}                                   \
        --prefix="${CT_PREFIX_DIR}"                             \
        "${expat_opts[@]}"

    CT_DoLog EXTRA "Building expat"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing expat"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_EXPAT

if [ "${CT_EXPAT_TARGET}" = "y" ]; then

do_expat_target() {
    CT_DoStep INFO "Installing expat for the target"
    mkdir -p "${CT_BUILD_DIR}/build-expat-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-expat-for-target"

    CT_DoLog EXTRA "Configuring expat"
    cp ../../config.cache .
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC"                                       \
    CT_DoExecLog CFG                                            \
    "${CT_SRC_DIR}/expat-${CT_EXPAT_VERSION}/configure"         \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --target=${CT_TARGET}                                   \
        --cache-file=config.cache                               \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-shared                                         \
        --enable-static

    CT_DoLog EXTRA "Building expat"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing expat"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_EXPAT_TARGET

fi # CT_EXPAT || CT_EXPAT_TARGET
