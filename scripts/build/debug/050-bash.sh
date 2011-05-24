# Build script for bash

do_debug_bash_get() {
    CT_GetFile "bash-${CT_BASH_VERSION}" .tar.gz \
               http://ftp.gnu.org/gnu/bash/
}

do_debug_bash_extract() {
    CT_Extract "bash-${CT_BASH_VERSION}"
    CT_Patch "bash" "${CT_BASH_VERSION}"
}

do_debug_bash_build() {
    CT_DoStep INFO "Installing bash"
    rm -rf "${CT_BUILD_DIR}/build-bash"
    cp -a "${CT_SRC_DIR}/bash-${CT_BASH_VERSION}" "${CT_BUILD_DIR}/build-bash"
    CT_Pushd "${CT_BUILD_DIR}/build-bash"

    CT_DoLog EXTRA "Configuring bash"

    rm -f parser-built y.tab.c y.tab.h po/*.gmo
    CT_DoExecLog CFG autoconf --force -I support

    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CFLAGS="-g -Os"                                             \
    YACC="${CT_TARGET}-bison -y"                                \
    INTLBISON="${CT_TARGET}-bison"                              \
    "./configure"                                               \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-curses                                           \
        --disable-net-redirections                              \
        --disable-largefile

    CT_DoLog EXTRA "Building bash"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing bash"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

