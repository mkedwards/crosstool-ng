# Build script for dbus

do_cross_me_harder_dbus_get() {
    CT_GetFile "dbus-${CT_DBUS_VERSION}" \
               http://dbus.freedesktop.org/releases/dbus/
}

do_cross_me_harder_dbus_extract() {
    CT_Extract "dbus-${CT_DBUS_VERSION}"
    CT_Patch "dbus" "${CT_DBUS_VERSION}"
}

do_cross_me_harder_dbus_build() {
    CT_DoStep EXTRA "Installing cross dbus"
    mkdir -p "${CT_BUILD_DIR}/build-dbus-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-dbus-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    "${CT_SRC_DIR}/dbus-${CT_DBUS_VERSION}/configure"           \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"                         \
            --enable-inotify                                    \
            --without-x                                         \
            --with-init-scripts=none                            \
            --with-xml=expat
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target dbus"
    mkdir -p "${CT_BUILD_DIR}/build-dbus-target"
    CT_Pushd "${CT_BUILD_DIR}/build-dbus-target"
    
    rm -rf "${CT_SYSROOT_DIR}/etc/dbus-1"
    mkdir -p "${CT_SYSROOT_DIR}/etc/dbus-1/system.d"
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -DNDEBUG"                                    \
    CXXFLAGS="-g -Os -DNDEBUG"                                  \
    "${CT_SRC_DIR}/dbus-${CT_DBUS_VERSION}/configure"           \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --libexecdir=/usr/lib/dbus-1.0                          \
        --enable-inotify                                        \
        --without-x                                             \
        --with-init-scripts=slackware                           \
        --with-xml=expat
    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
