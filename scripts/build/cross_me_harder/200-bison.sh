# Build script for bison

do_cross_me_harder_bison_get() {
    CT_GetFile "bison-${CT_BISON_VERSION}" \
               {ftp,http}://ftp.gnu.org/gnu/bison
}

do_cross_me_harder_bison_extract() {
    CT_Extract "bison-${CT_BISON_VERSION}"
    CT_DoExecLog ALL chmod -R u+w "${CT_SRC_DIR}/bison-${CT_BISON_VERSION}"
    CT_Patch "bison" "${CT_BISON_VERSION}"
    CT_Pushd "${CT_SRC_DIR}/bison-${CT_BISON_VERSION}"
    CT_DoExecLog ALL autoreconf -fiv
    CT_Popd
}

do_cross_me_harder_bison_build() {
    CT_DoStep EXTRA "Installing cross bison"
    mkdir -p "${CT_BUILD_DIR}/build-bison-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-bison-cross"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/bison-${CT_BISON_VERSION}/configure" \
            --build=${CT_BUILD}                         \
            --target=${CT_TARGET}                       \
            --prefix="${CT_PREFIX_DIR}"                 \
            --disable-nls                               \
            --disable-rpath
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Clobbering libraries from cross bison with host bison"
    mkdir -p "${CT_BUILD_DIR}/build-bison-clobber"
    CT_Pushd "${CT_BUILD_DIR}/build-bison-clobber"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/bison-${CT_BISON_VERSION}/configure" \
            --prefix="${CT_PREFIX_DIR}"                 \
            --disable-nls                               \
            --disable-rpath
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing host bison"
    mkdir -p "${CT_BUILD_DIR}/build-bison"
    CT_Pushd "${CT_BUILD_DIR}/build-bison"
    
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/bison-${CT_BISON_VERSION}/configure" \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target bison"
    mkdir -p "${CT_BUILD_DIR}/build-bison-target"
    CT_Pushd "${CT_BUILD_DIR}/build-bison-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    "${CT_SRC_DIR}/bison-${CT_BISON_VERSION}/configure"         \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --disable-nls                                           \
        --disable-rpath
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
