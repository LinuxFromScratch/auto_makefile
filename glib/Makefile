
current_dir := ${CURDIR}/glib

configure_zlib_args := --static --enable-shared --prefix=${CURDIR}/target

configure_libffi_args := --enable-silent-rules --enable-static --enable-shared --host=${HOST_NAME} --prefix=${CURDIR}/target

configure_glib_args := --enable-silent-rules --enable-static --enable-shared --with-pcre=internal --disable-gtk-doc-html --disable-man 
configure_glib_args += "glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=no ac_cv_func_posix_getgrgid_r=no"
configure_glib_args += --host=${HOST_NAME} --prefix=${CURDIR}/target  
configure_glib_args += ZLIB_CFLAGS="-I${CURDIR}/target/include" ZLIB_LIBS="${CURDIR}/target/lib/libz.a" 	
configure_glib_args += LIBFFI_CFLAGS="-I${CURDIR}/target/lib/libffi-3.2.1/include" LIBFFI_LIBS="${CURDIR}/target/libffi.la"

lib_name_zlib := zlib-1.2.11
lib_name_libffi := libffi-3.2.1
lib_name_glib := glib-2.40.2

sub_target:	
	$(call auto_build_lib,${current_dir},${lib_name_zlib},$(configure_zlib_args))
	$(call auto_build_lib,${current_dir},${lib_name_libffi},$(configure_libffi_args))
	$(call auto_build_lib,${current_dir},${lib_name_glib},$(configure_glib_args))

