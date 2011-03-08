# Build script for oprofile

do_debug_oprofile_get() {
    CT_GetFile "oprofile-${CT_OPROFILE_VERSION}" http://mesh.dl.sourceforge.net/sourceforge/oprofile/
    # Downloading from sourceforge leaves garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_debug_oprofile_extract() {
    CT_Extract "oprofile-${CT_OPROFILE_VERSION}"
    CT_Patch "oprofile" "${CT_OPROFILE_VERSION}"
}

do_debug_oprofile_build() {
    CT_DoStep INFO "Installing oprofile"
    mkdir -p "${CT_BUILD_DIR}/build-oprofile"
    CT_Pushd "${CT_BUILD_DIR}/build-oprofile"

    kernel_path="${CT_SRC_DIR}/linux-${CT_KERNEL_VERSION}"
    if [ "${CT_KERNEL_LINUX_CUSTOM}" = "y" ]; then
        kernel_path="${CT_SRC_DIR}/linux-custom"
    fi

    CT_DoLog EXTRA "Configuring oprofile"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    "${CT_SRC_DIR}/oprofile-${CT_OPROFILE_VERSION}/configure"   \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file=config.cache                               \
        --with-kernel-support                                   \
        --with-linux="$kernel_path"                             \
        --without-x                                             \
        --disable-rpath                                         \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr

    CT_DoLog EXTRA "Building oprofile"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing oprofile"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

