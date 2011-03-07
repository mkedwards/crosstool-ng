# Build script for valgrind

do_debug_valgrind_get() {
    CT_GetFile "valgrind-${CT_VALGRIND_VERSION}" http://www.valgrind.org/downloads/
}

do_debug_valgrind_extract() {
    CT_Extract "valgrind-${CT_VALGRIND_VERSION}"
    CT_Patch "valgrind" "${CT_VALGRIND_VERSION}"
}

do_debug_valgrind_build() {
    CT_DoStep INFO "Installing valgrind"
    rm -rf "${CT_BUILD_DIR}/build-valgrind"
    cp -a "${CT_SRC_DIR}/valgrind-${CT_VALGRIND_VERSION}" "${CT_BUILD_DIR}/build-valgrind"
    CT_Pushd "${CT_BUILD_DIR}/build-valgrind"

    CT_DoLog EXTRA "Configuring valgrind"
    CT_DoExecLog CFG                                        \
    ./configure                                             \
        --build=${CT_BUILD}                                 \
        --host=${CT_TARGET}                                 \
        --enable-tls                                        \
        --sysconfdir=/etc                                   \
        --localstatedir=/var                                \
        --mandir=/usr/share/man                             \
        --infodir=/usr/share/info                           \
        --prefix=/usr

    CT_DoLog EXTRA "Building valgrind"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing valgrind"
    CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

