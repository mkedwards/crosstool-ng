# Build script for freetype

do_target_me_harder_freetype_get() {
    CT_GetFile "freetype-${CT_FREETYPE_VERSION}" \
               http://mesh.dl.sourceforge.net/sourceforge/freetype/freetype2/${CT_FREETYPE_VERSION}
    CT_GetFile "freetype-doc-${CT_FREETYPE_VERSION}" \
               http://mesh.dl.sourceforge.net/sourceforge/freetype/freetype-docs/${CT_FREETYPE_VERSION}
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_target_me_harder_freetype_extract() {
    CT_Extract "freetype-${CT_FREETYPE_VERSION}"
    CT_Pushd "${CT_SRC_DIR}"
    CT_Extract nochdir "freetype-doc-${CT_FREETYPE_VERSION}"
    CT_Popd
    CT_Patch "freetype" "${CT_FREETYPE_VERSION}"
}

do_target_me_harder_freetype_build() {
    CT_DoStep EXTRA "Installing target freetype"
    mkdir -p "${CT_BUILD_DIR}/build-freetype-target"
    CT_Pushd "${CT_BUILD_DIR}/build-freetype-target"
    
    cp ../../config.cache .
    CT_DoExecLog CFG \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/freetype-${CT_FREETYPE_VERSION}/configure"       \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd

    CT_Pushd "${CT_SYSROOT_DIR}"
    patch -p1 <<"EOF"
--- sysroot/usr/lib/pkgconfig/freetype2.pc
+++ sysroot/usr/lib/pkgconfig/freetype2.pc
@@ -9,4 +9,3 @@
 Requires:
-Libs: -L${libdir} -lfreetype
-Libs.private: -lz -lbz2 
+Libs: -L${libdir} -lfreetype -lz -lbz2
 Cflags: -I${includedir}/freetype2 -I${includedir}
EOF
    CT_Popd

    CT_EndStep
}
