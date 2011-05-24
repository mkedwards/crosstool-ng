# Build script for gawk

do_debug_gawk_get() {
    CT_GetFile "gawk-${CT_GAWK_VERSION}" \
               http://ftp.gnu.org/gnu/gawk/
}

do_debug_gawk_extract() {
    CT_Extract "gawk-${CT_GAWK_VERSION}"
    CT_Patch "gawk" "${CT_GAWK_VERSION}"
}

do_debug_gawk_build() {
    CT_DoStep INFO "Installing gawk"
    rm -rf "${CT_BUILD_DIR}/build-gawk"
    cp -a "${CT_SRC_DIR}/gawk-${CT_GAWK_VERSION}" "${CT_BUILD_DIR}/build-gawk"
    CT_Pushd "${CT_BUILD_DIR}/build-gawk"

    CT_DoLog EXTRA "Configuring gawk"

    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CFLAGS="-g -Os"                                             \
    LIBS="-lrt"                                                 \
    "./configure"                                               \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-switch                                         \
        --disable-largefile

    CT_DoLog EXTRA "Building gawk"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing gawk"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

