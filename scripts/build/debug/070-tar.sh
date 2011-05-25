# Build script for tar

do_debug_tar_get() {
    CT_GetFile "tar-${CT_TAR_VERSION}" \
               http://ftp.gnu.org/gnu/tar/
}

do_debug_tar_extract() {
    CT_Extract "tar-${CT_TAR_VERSION}"
    CT_Patch "tar" "${CT_TAR_VERSION}"
}

do_debug_tar_build() {
    CT_DoStep INFO "Installing tar"
    rm -rf "${CT_BUILD_DIR}/build-tar"
    cp -a "${CT_SRC_DIR}/tar-${CT_TAR_VERSION}" "${CT_BUILD_DIR}/build-tar"
    CT_Pushd "${CT_BUILD_DIR}/build-tar"

    CT_DoLog EXTRA "Configuring tar"

    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CFLAGS="-g -Os"                                             \
    "./configure"                                               \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=                                               \
        --disable-largefile

    CT_DoLog EXTRA "Building tar"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing tar"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

