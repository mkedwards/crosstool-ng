# Build script for dbus-glib

do_cross_me_harder_dbus_glib_get() {
    CT_GetFile "dbus-glib-${CT_DBUS_GLIB_VERSION}" .tar.gz \
               http://dbus.freedesktop.org/releases/dbus-glib
}

do_cross_me_harder_dbus_glib_extract() {
    CT_Extract "dbus-glib-${CT_DBUS_GLIB_VERSION}"
    CT_Patch "dbus-glib" "${CT_DBUS_GLIB_VERSION}"
}

do_cross_me_harder_dbus_glib_build() {
    CT_DoStep EXTRA "Installing cross dbus-glib"
    mkdir -p "${CT_BUILD_DIR}/build-dbus-glib-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-dbus-glib-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    "${CT_SRC_DIR}/dbus-glib-${CT_DBUS_GLIB_VERSION}/configure" \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target dbus-glib"
    mkdir -p "${CT_BUILD_DIR}/build-dbus-glib-target"
    CT_Pushd "${CT_BUILD_DIR}/build-dbus-glib-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -DNDEBUG"                                    \
    CXXFLAGS="-g -Os -DNDEBUG"                                  \
    "${CT_SRC_DIR}/dbus-glib-${CT_DBUS_GLIB_VERSION}/configure" \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-dbus-binding-tool=${CT_PREFIX_DIR}/bin/dbus-binding-tool
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
