# Build script for protobuf

do_cross_me_harder_protobuf_get() {
    CT_GetFile "protobuf-${CT_PROTOBUF_VERSION}" \
               http://protobuf.googlecode.com/files/
}

do_cross_me_harder_protobuf_extract() {
    CT_Extract "protobuf-${CT_PROTOBUF_VERSION}"
    CT_Patch "protobuf" "${CT_PROTOBUF_VERSION}"
}

do_cross_me_harder_protobuf_build() {
    CT_DoStep EXTRA "Installing cross protobuf"
    mkdir -p "${CT_BUILD_DIR}/build-protobuf-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-protobuf-cross"
    
    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_PREFIX_DIR}/include"                       \
    LDFLAGS="-L${CT_PREFIX_DIR}/lib -Wl,-rpath=${CT_PREFIX_DIR}/lib" \
    "${CT_SRC_DIR}/protobuf-${CT_PROTOBUF_VERSION}/configure"   \
            --build=${CT_BUILD}                                 \
            --target=${CT_TARGET}                               \
            --prefix="${CT_PREFIX_DIR}"
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target protobuf"
    mkdir -p "${CT_BUILD_DIR}/build-protobuf-target"
    CT_Pushd "${CT_BUILD_DIR}/build-protobuf-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -DNDEBUG"                                    \
    CXXFLAGS="-g -Os -DNDEBUG"                                  \
    "${CT_SRC_DIR}/protobuf-${CT_PROTOBUF_VERSION}/configure"   \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --with-protoc=${CT_PREFIX_DIR}/bin/${CT_TARGET}-protoc  \
        --enable-tls
    CT_DoExecLog ALL make
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd
    CT_EndStep
}
