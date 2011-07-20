# Build script for gettext

CT_GETTEXT_VERSION=0.18.1.1

do_companion_tools_gettext_get() {
    CT_GetFile "gettext-${CT_GETTEXT_VERSION}" \
               {ftp,http}://ftp.gnu.org/gnu/gettext
}

do_companion_tools_gettext_extract() {
    CT_Extract "gettext-${CT_GETTEXT_VERSION}"
    CT_Patch "gettext" "${CT_GETTEXT_VERSION}"
}

do_companion_tools_gettext_build() {
    CT_DoStep EXTRA "Installing gettext"
    mkdir -p "${CT_BUILD_DIR}/build-gettext"
    CT_Pushd "${CT_BUILD_DIR}/build-gettext"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/gettext-${CT_GETTEXT_VERSION}/configure" \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep
}
