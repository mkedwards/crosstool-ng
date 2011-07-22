# Build script for libjpeg-turbo

do_target_me_harder_libjpeg_turbo_get() {
    CT_MktempDir tmp_dir
    CT_Pushd "${tmp_dir}"

    CT_HasOrAbort svn

    case "${CT_LIBJPEG_TURBO_VERSION}" in
        trunk)  svn_url="https://libjpeg-turbo.svn.sourceforge.net/svnroot/libjpeg-turbo/trunk";;
        *)      svn_url="https://libjpeg-turbo.svn.sourceforge.net/svnroot/libjpeg-turbo/branches/${CT_LIBJPEG_TURBO_VERSION}";;
    esac

    CT_DoExecLog ALL svn checkout -r "${CT_LIBJPEG_TURBO_REVISION:-HEAD}" "${svn_url}" "$(pwd)"/libjpeg-turbo

    # Compress libjpeg-turbo
    CT_DoExecLog ALL mv libjpeg-turbo "libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}"
    CT_DoExecLog ALL tar cjf "libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}.tar.bz2" "libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}"
    CT_DoExecLog ALL mv -f "libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}.tar.bz2" "${CT_TARBALLS_DIR}"

    CT_Popd

    # Remove source files
    CT_DoExecLog ALL rm -rf "${tmp_dir}"

    if [ "${CT_SAVE_TARBALLS}" = "y" ]; then
        CT_DoLog EXTRA "Saving 'libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}' to local storage"
        for file in "libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}.tar.bz2"; do
            CT_DoExecLog ALL mv -f "${CT_TARBALLS_DIR}/${file}" "${CT_LOCAL_TARBALLS_DIR}"
            CT_DoExecLog ALL ln -s "${CT_LOCAL_TARBALLS_DIR}/${file}" "${CT_TARBALLS_DIR}/${file}"
        done
    fi
}

do_target_me_harder_libjpeg_turbo_extract() {
    CT_Extract "libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}"
    CT_Patch "libjpeg-turbo" "${CT_LIBJPEG_TURBO_VERSION}"
}

do_target_me_harder_libjpeg_turbo_build() {
    CT_DoStep EXTRA "Installing target libjpeg-turbo"

    CT_Pushd "${CT_SRC_DIR}/libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    mkdir -p "${CT_BUILD_DIR}/build-libjpeg-turbo-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libjpeg-turbo-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -O3 -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/libjpeg-turbo-${CT_LIBJPEG_TURBO_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-static                                        \
        --enable-shared                                         \
        --enable-maxmem=1024

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
