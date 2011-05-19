# Build script for nspr

do_cross_me_harder_nspr_get() {
    CT_GetFile "nspr-${CT_NSPR_VERSION}" .tar.gz \
               "https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${CT_NSPR_VERSION}/src"
}

do_cross_me_harder_nspr_extract() {
    CT_Extract "nspr-${CT_NSPR_VERSION}"
    CT_Patch "nspr" "${CT_NSPR_VERSION}"
}

do_cross_me_harder_nspr_build() {
    local -a host_extra_config
    local -a target_extra_config

    CT_DoStep EXTRA "Installing host nspr"
    rm -rf "${CT_BUILD_DIR}/build-nspr"
    cp -a "${CT_SRC_DIR}/nspr-${CT_NSPR_VERSION}" "${CT_BUILD_DIR}/build-nspr"
    CT_Pushd "${CT_BUILD_DIR}/build-nspr/mozilla/nsprpub"
    
    case "$CT_BUILD" in
        x86_64-* )
            host_extra_config+=( --enable-64bit )
            ;;
    esac

    CT_DoLog DEBUG "Extra config passed: '${host_extra_config[*]}'"

    CC="${CT_HOST}-gcc"                                         \
    CFLAGS="-fPIC"                                              \
    CT_DoExecLog CFG                                            \
    ./configure                                                 \
            --prefix="${CT_PREFIX_DIR}"                         \
            --enable-optimize=-Os                               \
            --enable-debug=-g                                   \
            --with-pthreads                                     \
            "${host_extra_config[@]}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target nspr"
    rm -rf "${CT_BUILD_DIR}/build-nspr-target"
    cp -a "${CT_SRC_DIR}/nspr-${CT_NSPR_VERSION}" "${CT_BUILD_DIR}/build-nspr-target"
    CT_Pushd "${CT_BUILD_DIR}/build-nspr-target/mozilla/nsprpub"
    
    if [ "${CT_ARCH_ARM_MODE_THUMB}" = "y" ]; then
        target_extra_config+=( --enable-thumb2 )
    fi

    CT_DoLog DEBUG "Extra config passed: '${target_extra_config[*]}'"

    # Notice that NSPR detects a cross-compile using host != target rather than build != host!

    cp ../../../../config.cache .
    CT_DoExecLog CFG                                            \
    ./configure                                                 \
        --host=${CT_BUILD}                                      \
        --target=${CT_TARGET}                                   \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-optimize=-Os                                   \
        --enable-debug=-g                                       \
        --with-pthreads                                         \
        "${target_extra_config[@]}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd

    cat > "${CT_SYSROOT_DIR}"/usr/lib/pkgconfig/nspr.pc <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include/nspr

Name: NSPR
Description: The Netscape Portable Runtime
Version: ${CT_NSPR_VERSION}
Libs: -L\${libdir} -lplds4 -lplc4 -lnspr4 -lpthread
Cflags: -I\${includedir}
EOF

    CT_EndStep
}
