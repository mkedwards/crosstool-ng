# Build script for fontconfig

do_target_me_harder_fontconfig_get() {
    CT_GetFile "fontconfig-${CT_FONTCONFIG_VERSION}" .tar.gz \
               http://www.freedesktop.org/software/fontconfig/release
}

do_target_me_harder_fontconfig_extract() {
    CT_Extract "fontconfig-${CT_FONTCONFIG_VERSION}"
    CT_Patch "fontconfig" "${CT_FONTCONFIG_VERSION}"
}

do_target_me_harder_fontconfig_build() {
    local fc_arch

    CT_DoStep EXTRA "Installing target fontconfig"
    mkdir -p "${CT_BUILD_DIR}/build-fontconfig-target"
    CT_Pushd "${CT_BUILD_DIR}/build-fontconfig-target"
    
    case "${CT_ARCH}:${CT_ARCH_BITNESS}" in
        arm:*)      fc_arch="le32d8";;
        x86:32)     fc_arch="le32d4";;
    esac

    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/fontconfig-${CT_FONTCONFIG_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-arch="${fc_arch}"                                \
        --enable-libxml2

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
