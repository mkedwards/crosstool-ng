# Build script for clips-core

do_cross_me_harder_clips_core_get() {
    local svn_url
    local bz2file="clips-core-${CT_CLIPS_CORE_VERSION}.tar.bz2"

    if [ -f "${CT_TARBALLS_DIR}/${bz2file}" ]; then
        CT_DoLog DEBUG "Already have 'clips-core-${CT_CLIPS_CORE_VERSION}'"
        return 0
    fi

    if [    -f "${CT_LOCAL_TARBALLS_DIR}/${bz2file}"                \
         -a "${CT_FORCE_DOWNLOAD}" != "y"                           \
       ]; then
        CT_DoLog DEBUG "Got 'clips-core-${CT_CLIPS_CORE_VERSION}' from local storage"
        CT_DoExecLog ALL ln -s "${CT_LOCAL_TARBALLS_DIR}/${bz2file}" "${CT_TARBALLS_DIR}/${bz2file}"
        return 0
    fi

    CT_MktempDir tmp_dir
    CT_Pushd "${tmp_dir}"

    CT_HasOrAbort svn

    svn_url="https://clipsrules.svn.sourceforge.net/svnroot/clipsrules/core"

    CT_DoExecLog ALL svn checkout -r "${CT_CLIPS_CORE_REVISION:-HEAD}" "${svn_url}" "$(pwd)"/clips-core

    # Compress clips-core
    CT_DoExecLog ALL mv clips-core "clips-core-${CT_CLIPS_CORE_VERSION}"
    CT_DoExecLog ALL tar cjf "${bz2file}" "clips-core-${CT_CLIPS_CORE_VERSION}"
    CT_DoExecLog ALL mv -f "${bz2file}" "${CT_TARBALLS_DIR}"

    CT_Popd

    # Remove source files
    CT_DoExecLog ALL rm -rf "${tmp_dir}"

    if [ "${CT_SAVE_TARBALLS}" = "y" ]; then
        CT_DoLog EXTRA "Saving 'clips-core-${CT_CLIPS_CORE_VERSION}' to local storage"
        CT_DoExecLog ALL mv -f "${CT_TARBALLS_DIR}/${bz2file}" "${CT_LOCAL_TARBALLS_DIR}"
        CT_DoExecLog ALL ln -s "${CT_LOCAL_TARBALLS_DIR}/${bz2file}" "${CT_TARBALLS_DIR}/${bz2file}"
    fi
}

do_cross_me_harder_clips_core_extract() {
    CT_Extract "clips-core-${CT_CLIPS_CORE_VERSION}"
    CT_Patch "clips-core" "${CT_CLIPS_CORE_VERSION}"
}

do_cross_me_harder_clips_core_build() {
    CT_DoStep EXTRA "Installing host clips-core"

    CT_Pushd "${CT_SRC_DIR}/clips-core-${CT_CLIPS_CORE_VERSION}"
    CT_DoExecLog CFG                                            \
    ACLOCAL="aclocal -I ${CT_SYSROOT_DIR}/usr/share/aclocal -I ${CT_PREFIX_DIR}/share/aclocal" \
    autoreconf -fiv
    CT_Popd

    rm -rf "${CT_BUILD_DIR}/build-clips-core-host"
    cp -a "${CT_SRC_DIR}/clips-core-${CT_CLIPS_CORE_VERSION}" "${CT_BUILD_DIR}/build-clips-core-host"
    CT_Pushd "${CT_BUILD_DIR}/build-clips-core-host"
    
    CT_DoExecLog CFG \
    PKG_CONFIG_LIBDIR="${CT_PREFIX_DIR}/lib/pkgconfig"          \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    ./configure                                                 \
            --build=${CT_BUILD}                                 \
            --prefix="${CT_PREFIX_DIR}"                         \
            --enable-debug
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing cross clips-core"
    rm -rf "${CT_BUILD_DIR}/build-clips-core-cross"
    cp -a "${CT_SRC_DIR}/clips-core-${CT_CLIPS_CORE_VERSION}" "${CT_BUILD_DIR}/build-clips-core-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-clips-core-cross"
    
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    ./configure                                                 \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-debug
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
