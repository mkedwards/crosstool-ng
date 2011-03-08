# Build script for gperf

CT_GPERF_VERSION=3.0.4

do_companion_tools_gperf_get() {
    CT_GetFile "gperf-${CT_GPERF_VERSION}" \
               {ftp,http}://ftp.gnu.org/gnu/gperf
}

do_companion_tools_gperf_extract() {
    CT_Extract "gperf-${CT_GPERF_VERSION}"
    CT_Patch "gperf" "${CT_GPERF_VERSION}"
}

do_companion_tools_gperf_build() {
    CT_DoStep EXTRA "Installing gperf"
    mkdir -p "${CT_BUILD_DIR}/build-gperf"
    CT_Pushd "${CT_BUILD_DIR}/build-gperf"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/gperf-${CT_GPERF_VERSION}/configure" \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep
}
