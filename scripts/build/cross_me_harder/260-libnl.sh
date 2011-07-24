# Build script for libnl

do_cross_me_harder_libnl_get() {
    CT_GetFile "libnl-${CT_LIBNL_VERSION}" \
               "http://www.infradead.org/~tgr/libnl/files"
}

do_cross_me_harder_libnl_extract() {
    CT_Extract "libnl-${CT_LIBNL_VERSION}"
    CT_Patch "libnl" "${CT_LIBNL_VERSION}"
}

do_cross_me_harder_libnl_build() {
    CT_DoStep EXTRA "Installing cross libnl"
    rm -rf "${CT_BUILD_DIR}/build-libnl-cross"
    cp -a "${CT_SRC_DIR}/libnl-${CT_LIBNL_VERSION}" "${CT_BUILD_DIR}/build-libnl-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-libnl-cross"
    
    CT_DoExecLog CFG \
    LEX="flex"                                                  \
    YACC="bison -y"                                             \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    ./configure                                                 \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target libnl"
    rm -rf "${CT_BUILD_DIR}/build-libnl-target"
    cp -a "${CT_SRC_DIR}/libnl-${CT_LIBNL_VERSION}" "${CT_BUILD_DIR}/build-libnl-target"
    CT_Pushd "${CT_BUILD_DIR}/build-libnl-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    LEX="${CT_TARGET}-flex"                                     \
    YACC="${CT_TARGET}-bison -y"                                \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    ./configure                                                 \
            --build=${CT_BUILD}                                 \
            --host=${CT_TARGET}                                 \
            --cache-file="$(pwd)/config.cache"                  \
            --sysconfdir=/etc                                   \
            --localstatedir=/var                                \
            --mandir=/usr/share/man                             \
            --infodir=/usr/share/info                           \
            --prefix=/usr
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
