# Build script for intltool

CT_INTLTOOL_VERSION=0.41.1

do_companion_tools_intltool_get() {
    CT_GetFile "intltool-${CT_INTLTOOL_VERSION}" .tar.gz \
               http://edge.launchpad.net/intltool/trunk/${CT_INTLTOOL_VERSION}/+download/
}

do_companion_tools_intltool_extract() {
    CT_Extract "intltool-${CT_INTLTOOL_VERSION}"
    CT_Patch "intltool" "${CT_INTLTOOL_VERSION}"
}

do_companion_tools_intltool_build() {
    CT_DoStep EXTRA "Installing intltool"
    mkdir -p "${CT_BUILD_DIR}/build-intltool"
    CT_Pushd "${CT_BUILD_DIR}/build-intltool"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/intltool-${CT_INTLTOOL_VERSION}/configure" \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep
}
