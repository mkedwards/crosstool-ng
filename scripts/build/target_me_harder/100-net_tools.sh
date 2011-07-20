# Build script for net-tools

do_target_me_harder_net_tools_get() {
    CT_GetFile "net-tools-${CT_NET_TOOLS_VERSION}" \
               http://download.berlios.de/net-tools/
}

do_target_me_harder_net_tools_extract() {
    CT_Extract "net-tools-${CT_NET_TOOLS_VERSION}"
    CT_Patch "net-tools" "${CT_NET_TOOLS_VERSION}"
}

do_target_me_harder_net_tools_build() {
    CT_DoStep EXTRA "Installing target net-tools"
    rm -rf "${CT_BUILD_DIR}/build-net-tools-target"
    cp -a "${CT_SRC_DIR}/net-tools-${CT_NET_TOOLS_VERSION}" "${CT_BUILD_DIR}/build-net-tools-target"
    CT_Pushd "${CT_BUILD_DIR}/build-net-tools-target"
    
    touch config.h

    CT_DoExecLog ALL make ${JOBSFLAGS} \
        CC=${CT_TARGET}-gcc AR=${CT_TARGET}-ar RANLIB=${CT_TARGET}-ranlib \
        COPTS="-D_GNU_SOURCE -Wall -g -Os"

    CT_DoExecLog ALL make BASEDIR="${CT_SYSROOT_DIR}" update
    CT_Popd
    CT_EndStep
}
