# Build script for cgreen

do_debug_cgreen_get() {
    CT_GetFile "cgreen-${CT_CGREEN_VERSION}" \
               "http://mesh.dl.sourceforge.net/sourceforge/cgreen/cgreen/cgreen_1.0beta2/"
    # Downloading from sourceforge leaves garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_debug_cgreen_extract() {
    CT_Extract "cgreen-${CT_CGREEN_VERSION}"
    CT_Patch "cgreen" "${CT_CGREEN_VERSION}"
}

do_debug_cgreen_build() {
    CT_DoStep INFO "Installing cgreen"
    rm -rf "${CT_BUILD_DIR}/build-cgreen"
    cp -a "${CT_SRC_DIR}/cgreen-${CT_CGREEN_VERSION}" "${CT_BUILD_DIR}/build-cgreen"
    CT_Pushd "${CT_BUILD_DIR}/build-cgreen"

    mkdir -p m4
    rm -f all_tests.sh configure.ac Makefile.am
    ln -s contrib/automake/all_tests.sh contrib/automake/configure.ac contrib/automake/Makefile.am .

    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv

    CT_DoLog EXTRA "Configuring cgreen"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    LEX=${CT_TARGET}-flex                                       \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "./configure"                                               \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr/preen

    CT_DoLog EXTRA "Building cgreen"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing cgreen"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

