# Build script for automoc4

do_target_me_harder_automoc4_get() {
    CT_GetFile "automoc4-${CT_AUTOMOC4_VERSION}" .tar.bz2 \
               ftp://ftp.kde.org/pub/kde/stable/automoc4/"${CT_AUTOMOC4_VERSION}"
}

do_target_me_harder_automoc4_extract() {
    CT_Extract "automoc4-${CT_AUTOMOC4_VERSION}"
    CT_Patch "automoc4" "${CT_AUTOMOC4_VERSION}"
}

do_target_me_harder_automoc4_build() {
    CT_DoStep EXTRA "Installing cross automoc4"
    rm -rf "${CT_BUILD_DIR}/build-automoc4-cross"
    cp -a "${CT_SRC_DIR}/automoc4-${CT_AUTOMOC4_VERSION}" "${CT_BUILD_DIR}/build-automoc4-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-automoc4-cross"
    
    cat >buildtools.cmake <<EOT
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)

SET(CMAKE_C_COMPILER   gcc)
SET(CMAKE_CXX_COMPILER g++)

SET(QT_LIBRARY_DIR ${CT_BUILDTOOLS_PREFIX_DIR}/lib)
SET(QT_BINARY_DIR ${CT_BUILDTOOLS_PREFIX_DIR}/bin)
SET(QT_INCLUDE_DIR ${CT_BUILDTOOLS_PREFIX_DIR}/include)
SET(QT_QT_INCLUDE_DIR ${CT_BUILDTOOLS_PREFIX_DIR}/include/Qt)
EOT

    CT_DoExecLog CFG \
    cmake \
        -DCMAKE_TOOLCHAIN_FILE="${CT_BUILD_DIR}/build-automoc4-cross"/buildtools.cmake \
        -DCMAKE_INSTALL_PREFIX="${CT_BUILDTOOLS_PREFIX_DIR}"

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep
}
