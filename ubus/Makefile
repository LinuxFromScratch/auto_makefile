
current_dir := ${CURDIR}/ubus

configure_jsonc_args := --enable-static --enable-shared  --host=${HOST_NAME} --prefix=${CURDIR}/target 
configure_jsonc_args += CFLAGS="${CFLAGS} -Drpl_realloc=realloc -Drpl_malloc=malloc"

configure_ubox_args := --enable-static --host=${HOST_NAME} --prefix=${CURDIR}/target LDFLAGS=""

configure_ubus_args := 

lib_name_jsonc := json-c
lib_name_suffix :=.tar.gz

sub_target:	
	$(call auto_make_install_compressed_lib_once,${current_dir},${lib_name_jsonc},$(lib_name_suffix),$(configure_jsonc_args))

