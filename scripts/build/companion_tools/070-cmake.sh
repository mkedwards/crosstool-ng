# Build script for cmake

CT_CMAKE_VERSION=2.8.5

do_companion_tools_cmake_get() {
    CT_GetFile "cmake-${CT_CMAKE_VERSION}" .tar.gz \
               http://www.cmake.org/files/v2.8
}

do_companion_tools_cmake_extract() {
    CT_Extract "cmake-${CT_CMAKE_VERSION}"
    CT_DoExecLog ALL chmod -R u+w "${CT_SRC_DIR}/cmake-${CT_CMAKE_VERSION}"
    CT_Patch "cmake" "${CT_CMAKE_VERSION}"
}

do_companion_tools_cmake_build() {
    CT_DoStep EXTRA "Installing cmake"
    mkdir -p "${CT_BUILD_DIR}/build-cmake"
    CT_Pushd "${CT_BUILD_DIR}/build-cmake"

    CT_DoExecLog CFG "${CT_SRC_DIR}/cmake-${CT_CMAKE_VERSION}/bootstrap" \
                     --prefix="${CT_BUILDTOOLS_PREFIX_DIR}" \
                     --mandir=/share/man

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep
}
