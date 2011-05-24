# Build script for acl

do_acl_get() { :; }
do_acl_extract() { :; }
do_acl() { :; }
do_acl_target() { :; }

if [ "${CT_ACL}" = "y" -o "${CT_ACL_TARGET}" = "y" ]; then

do_acl_get() {
    CT_GetFile "acl-${CT_ACL_VERSION}" .src.tar.gz    \
               http://download.savannah.gnu.org/releases-noredirect/acl/
}

do_acl_extract() {
    CT_Extract "acl-${CT_ACL_VERSION}"
    CT_Patch "acl" "${CT_ACL_VERSION}"
}

if [ "${CT_ACL}" = "y" ]; then

do_acl() {
    CT_DoStep INFO "Installing acl"
    rm -rf "${CT_BUILD_DIR}/build-acl"
    cp -a "${CT_SRC_DIR}/acl-${CT_ACL_VERSION}" "${CT_BUILD_DIR}/build-acl"
    CT_Pushd "${CT_BUILD_DIR}/build-acl"

    CT_DoLog EXTRA "Configuring acl"

    CT_DoExecLog CFG                                            \
    MSGFMT=$(CT_Which msgfmt)                                   \
    MSGMERGE=$(CT_Which msgmerge)                               \
    XGETTEXT=$(CT_Which xgettext)                               \
    CC="${CT_HOST}-gcc"                                         \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib"                            \
    ./configure                                                 \
        --build=${CT_BUILD}                                     \
        --host=${CT_HOST}                                       \
        --target=${CT_TARGET}                                   \
        --prefix="${CT_PREFIX_DIR}"                             \
        --enable-shared                                         \
        --enable-static
    # --enable-shared because the install-lib step breaks without it

    CT_DoLog EXTRA "Building acl"
    CT_DoExecLog ALL                                            \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    make

    CT_DoLog EXTRA "Installing acl"
    CT_DoExecLog ALL make install-lib install-dev install

    CT_Popd
    CT_EndStep
}

fi # CT_ACL

if [ "${CT_ACL_TARGET}" = "y" ]; then

do_acl_target() {
    CT_DoStep INFO "Installing acl for the target"
    rm -rf "${CT_BUILD_DIR}/build-acl-for-target"
    cp -a "${CT_SRC_DIR}/acl-${CT_ACL_VERSION}" "${CT_BUILD_DIR}/build-acl-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-acl-for-target"

    CT_DoLog EXTRA "Configuring acl"
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

    CT_DoLog EXTRA "Building acl"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing acl"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install-lib install-dev install

    CT_Popd
    CT_EndStep
}

fi # CT_ACL_TARGET

fi # CT_ACL || CT_ACL_TARGET
