# Build script for busybox

do_cross_me_harder_busybox_get() {
    CT_GetFile "busybox-${CT_BUSYBOX_VERSION}" \
               http://busybox.net/downloads
}

do_cross_me_harder_busybox_extract() {
    CT_Extract "busybox-${CT_BUSYBOX_VERSION}"
    CT_Patch "busybox" "${CT_BUSYBOX_VERSION}"
}

do_cross_me_harder_busybox_build() {
    CT_DoStep EXTRA "Installing cross busybox"
    rm -rf "${CT_BUILD_DIR}/build-busybox-cross"
    cp -a "${CT_SRC_DIR}/busybox-${CT_BUSYBOX_VERSION}" "${CT_BUILD_DIR}/build-busybox-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-busybox-cross"
    
    sed -r -e "s|@HOST_TUPLE@|${CT_HOST}|g; s|@CONFIG_PREFIX@|${CT_PREFIX_DIR}|g;" <../../busyboxconfig.in >.config

    CT_DoExecLog CFG make oldconfig
    CT_DoExecLog ALL make ${JOBSFLAGS}
    mkdir -p "${CT_PREFIX_DIR}"/bin
    cp -p busybox "${CT_PREFIX_DIR}"/bin
    mkdir -p "${CT_PREFIX_DIR}"/sbin
    ln -s ../bin/busybox "${CT_PREFIX_DIR}"/sbin/makedevs
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target busybox"
    rm -rf "${CT_BUILD_DIR}/build-busybox-target"
    cp -a "${CT_SRC_DIR}/busybox-${CT_BUSYBOX_VERSION}" "${CT_BUILD_DIR}/build-busybox-target"
    CT_Pushd "${CT_BUILD_DIR}/build-busybox-target"
    
    sed -r -e "s|@HOST_TUPLE@|${CT_TARGET}|g; s|@CONFIG_PREFIX@||g;" <../../busyboxconfig.in >.config

    CT_DoExecLog CFG make oldconfig
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make CONFIG_PREFIX="${CT_SYSROOT_DIR}" install
    local initramfs_path="${CT_PREFIX_DIR}/${CT_TARGET}/${CT_SYSROOT_DIR_PREFIX}/initramfs"
    mkdir -p "${initramfs_path}"/bin "${initramfs_path}"/sbin
    CT_DoExecLog ALL make CONFIG_PREFIX="${initramfs_path}" install
    CT_Popd
    CT_EndStep
}
