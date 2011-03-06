# Build script for popt

do_popt_get() { :; }
do_popt_extract() { :; }
do_popt() { :; }
do_popt_target() { :; }

if [ "${CT_POPT}" = "y" -o "${CT_POPT_TARGET}" = "y" ]; then

do_popt_get() {
    CT_GetFile "popt-${CT_POPT_VERSION}" .tar.gz http://rpm5.org/files/popt/
}

do_popt_extract() {
    CT_Extract "popt-${CT_POPT_VERSION}"
    CT_Patch "popt" "${CT_POPT_VERSION}"
}

if [ "${CT_POPT}" = "y" ]; then

do_popt() {
    local -a popt_opts

    CT_DoStep INFO "Installing popt"
    mkdir -p "${CT_BUILD_DIR}/build-popt"
    CT_Pushd "${CT_BUILD_DIR}/build-popt"

    CT_DoLog EXTRA "Configuring popt"

    if [ "${CT_COMPLIBS_SHARED}" = "y" ]; then
        popt_opts+=( --enable-shared --disable-static )
    else
        popt_opts+=( --disable-shared --enable-static )
    fi

    CC="${CT_HOST}-gcc"                                     \
    CFLAGS="-fPIC"                                          \
    CT_DoExecLog CFG                                        \
    "${CT_SRC_DIR}/popt-${CT_POPT_VERSION}/configure"   \
        --build=${CT_BUILD}                                 \
        --host=${CT_HOST}                                   \
        --target=${CT_TARGET}                               \
        --prefix="${CT_COMPLIBS_DIR}"                       \
        "${popt_opts[@]}"

    CT_DoLog EXTRA "Building popt"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing popt"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_POPT

if [ "${CT_POPT_TARGET}" = "y" ]; then

do_popt_target() {
    CT_DoStep INFO "Installing popt for the target"
    mkdir -p "${CT_BUILD_DIR}/build-popt-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-popt-for-target"

    CT_DoLog EXTRA "Configuring popt"
    CC="${CT_TARGET}-gcc"                                   \
    CFLAGS="-fPIC"                                          \
    CT_DoExecLog CFG                                        \
    "${CT_SRC_DIR}/popt-${CT_POPT_VERSION}/configure"   \
        --build=${CT_BUILD}                                 \
        --host=${CT_TARGET}                                 \
        --target=${CT_TARGET}                               \
        --sysconfdir=/etc                                   \
        --localstatedir=/var                                \
        --mandir=/usr/share/man                             \
        --infodir=/usr/share/info                           \
        --prefix=/usr                                       \
        --disable-shared                                    \
        --enable-static

    CT_DoLog EXTRA "Building popt"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing popt"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_POPT_TARGET

fi # CT_POPT || CT_POPT_TARGET
