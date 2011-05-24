# Build script for pkg-config

do_cross_me_harder_pkg_config_get() {
    CT_GetFile "pkg-config-${CT_PKG_CONFIG_VERSION}" \
               http://pkgconfig.freedesktop.org/releases/
}

do_cross_me_harder_pkg_config_extract() {
    CT_Extract "pkg-config-${CT_PKG_CONFIG_VERSION}"
    CT_DoExecLog ALL chmod -R u+w "${CT_SRC_DIR}/pkg-config-${CT_PKG_CONFIG_VERSION}"
    CT_Patch "pkg-config" "${CT_PKG_CONFIG_VERSION}"
}

do_cross_me_harder_pkg_config_build() {
    CT_DoStep EXTRA "Installing host pkg-config"
    mkdir -p "${CT_BUILD_DIR}/build-pkg-config-host"
    CT_Pushd "${CT_BUILD_DIR}/build-pkg-config-host"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/pkg-config-${CT_PKG_CONFIG_VERSION}/configure" \
            --prefix="${CT_PREFIX_DIR}"                           \
            --with-pc-path="${CT_PREFIX_DIR}"/lib/pkgconfig
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing cross pkg-config"
    mkdir -p "${CT_BUILD_DIR}/build-pkg-config-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-pkg-config-cross"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/pkg-config-${CT_PKG_CONFIG_VERSION}/configure" \
            --target=${CT_TARGET}                       \
            --program-prefix=${CT_TARGET}-              \
            --prefix="${CT_PREFIX_DIR}"                 \
            --with-pc-path="${CT_SYSROOT_DIR}"/usr/lib/pkgconfig
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep
}
