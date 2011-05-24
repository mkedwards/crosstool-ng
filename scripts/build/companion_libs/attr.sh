# Build script for attr

do_attr_get() { :; }
do_attr_extract() { :; }
do_attr() { :; }
do_attr_target() { :; }

if [ "${CT_ATTR}" = "y" -o "${CT_ATTR_TARGET}" = "y" ]; then

do_attr_get() {
    CT_GetFile "attr-${CT_ATTR_VERSION}" .src.tar.gz    \
               http://download.savannah.gnu.org/releases-noredirect/attr/
}

do_attr_extract() {
    CT_Extract "attr-${CT_ATTR_VERSION}"
    CT_Patch "attr" "${CT_ATTR_VERSION}"
}

if [ "${CT_ATTR}" = "y" ]; then

do_attr() {
    CT_DoStep INFO "Installing attr"
    rm -rf "${CT_BUILD_DIR}/build-attr"
    cp -a "${CT_SRC_DIR}/attr-${CT_ATTR_VERSION}" "${CT_BUILD_DIR}/build-attr"
    CT_Pushd "${CT_BUILD_DIR}/build-attr"

    CT_DoLog EXTRA "Configuring attr"

    CT_DoExecLog CFG                                            \
    MSGFMT=$(CT_Which msgfmt)                                   \
    MSGMERGE=$(CT_Which msgmerge)                               \
    XGETTEXT=$(CT_Which xgettext)                               \
    CC="${CT_HOST}-gcc"                                         \
    ./configure                                                 \
        --build=${CT_BUILD}                                     \
        --host=${CT_HOST}                                       \
        --target=${CT_TARGET}                                   \
        --prefix="${CT_PREFIX_DIR}"                             \
        --enable-shared                                         \
        --enable-static
    # --enable-shared because the install-lib step breaks without it

    CT_DoLog EXTRA "Building attr"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing attr"
    CT_DoExecLog ALL make install-lib install-dev install

    CT_Popd
    CT_EndStep
}

fi # CT_ATTR

if [ "${CT_ATTR_TARGET}" = "y" ]; then

do_attr_target() {
    CT_DoStep INFO "Installing attr for the target"
    rm -rf "${CT_BUILD_DIR}/build-attr-for-target"
    cp -a "${CT_SRC_DIR}/attr-${CT_ATTR_VERSION}" "${CT_BUILD_DIR}/build-attr-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-attr-for-target"

    CT_DoLog EXTRA "Configuring attr"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    MSGFMT=$(CT_Which msgfmt)                                   \
    MSGMERGE=$(CT_Which msgmerge)                               \
    XGETTEXT=$(CT_Which xgettext)                               \
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    ./configure                                                 \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --target=${CT_TARGET}                                   \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-shared                                         \
        --enable-static

    CT_DoLog EXTRA "Building attr"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing attr"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install-lib install-dev install

    CT_Popd
    CT_EndStep
}

fi # CT_ATTR_TARGET

fi # CT_ATTR || CT_ATTR_TARGET
