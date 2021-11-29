

source ../scripts/common.sh

cur_dir=`pwd`
install_path=$cur_dir/../target

#
if [ $# -lt 2 ];then
	ERR [$FUNCNAME-$LINENO] "usage: $0 [action] [host]"
	CMD [$FUNCNAME-$LINENO] "action options: [make/clean/merge]"
	CMD [$FUNCNAME-$LINENO] "host options: [arm-hisiv300-linux/arm-hisiv400-linux/x86]"
	exit 1
fi

CMD [$FUNCNAME-$LINENO] "action=$action host=$host cur_dir=$cur_dir install_path=$install_path"

action=$1
LOG "action=$action"
if [ "$action" != "make" ] \
&& [ "$action" != "clean" ] \
&& [ "$action" != "merge" ] ;then
	 ERR [$FUNCNAME-$LINENO] "action: $action unsupport..."
	 exit 1
fi

host=$2
LOG "host=host"
if [ "$host" != "arm-hisiv300-linux" ] \
&& [ "$host" != "arm-hisiv400-linux" ] \
&& [ "$host" != "x86" ] ;then
	 ERR [$FUNCNAME-$LINENO] "host: $host unsupport..."
	 exit 1
fi


mkdir -p $install_path


######################################################################
# auto make/clean zlib
######################################################################
#$1 : host
#$2 : install_path
auto_make_zlib()
{
	ENV_VAR_UNSET
	
	CMD [$FUNCNAME-$LINENO] "host=$1 install_path=$2"
	tar -zxf zlib-1.2.11.tar.gz -C ./ 

	export CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2" 
	
	if [ "$1" == "arm-hisiv300-linux" ] ;then	
		export CC=$1-gcc
	elif [ "$1" == "arm-hisiv400-linux" ] ;then		
		export CC=$1-gcc
	elif [ "$1" == "x86" ] ;then		
		export CC=gcc
	else
		ERR [$FUNCNAME-$LINENO] "host: $1 unsupport..."
		exit 1
	fi
	
	cd zlib-1.2.11 && ./configure --static --enable-shared --prefix=$2 \
	&& make -j8 && make install
	cd -
	unset CFLAGS
	unset CC
}

auto_clean_zlib()
{
	CMD [$FUNCNAME-$LINENO] "rm -fr zlib-1.2.11"
	rm -fr zlib-1.2.11/
}

######################################################################
# auto make/clean libffi
######################################################################
#$1 : host
#$2 : install_path
auto_make_libffi()
{
	ENV_VAR_UNSET
	
	CMD [$FUNCNAME-$LINENO] "host=$1 install_path=$2"
	tar -zxf libffi-3.2.1.tar.gz -C ./ 
	cd libffi-3.2.1
	options="--enable-silent-rules --enable-static --enable-shared"
	
	if [ "$1" == "arm-hisiv300-linux" ] ;then	
		./configure  ${options} --host=$host --prefix=$2 \
		CC=$1-gcc \
		CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2" 
	elif [ "$1" == "arm-hisiv400-linux" ] ;then		
		./configure  ${options} --host=$host --prefix=$2 \
		CC=$1-gcc \
		CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2" 
	elif [ "$1" == "x86" ] ;then		
		./configure  ${options} --prefix=$2 \
		CC=gcc \
		CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2" 
	else
		ERR [$FUNCNAME-$LINENO] "host: $1 unsupport..."
		exit 1
	fi
	
	make -j8 && make install
	cd -
}

auto_clean_libffi()
{
	CMD [$FUNCNAME-$LINENO] "rm -fr libffi-3.2.1"
	rm -fr libffi-3.2.1/
}

######################################################################
# auto make/clean glib
######################################################################
#$1 : host
#$2 : install_path
auto_make_glib()
{
	ENV_VAR_UNSET
	export PKG_CONFIG_PATH=$2/lib/pkgconfig
	
	CMD [$FUNCNAME-$LINENO] "host=$1 install_path=$2"
	tar -zxf glib-2.40.2.tar.gz -C ./ 
	cd glib-2.40.2
	options="--enable-silent-rules --enable-static --enable-shared --with-pcre=internal --disable-gtk-doc-html --disable-man "
	cache_options="glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=no ac_cv_func_posix_getgrgid_r=no"
	
	if [ "$1" == "arm-hisiv300-linux" ] ;then	
		./configure  ${options} ${cache_options} --host=$host --prefix=$2 \
		CC=$1-gcc \
		CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2 -Wno-format-nonliteral -Wno-format-overflow  -Wno-format-security -I$2/include" \
		LDFLAGS="-L$2/lib"
	elif [ "$1" == "arm-hisiv400-linux" ] ;then		
		./configure  ${options} ${cache_options} --host=$host --prefix=$2 \
		CC=$1-gcc \
		CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2 -Wno-format-nonliteral -Wno-format-overflow  -Wno-format-security -I$2/include" \
		LDFLAGS="-L$2/lib"
	elif [ "$1" == "x86" ] ;then		
		./configure  ${options} ${cache_options} --prefix=$2 \
		CC=gcc \
		CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2 -Wno-format-nonliteral -Wno-format-overflow  -Wno-format-security -I$2/include" \
		LDFLAGS="-L$2/lib"
	else
		ERR [$FUNCNAME-$LINENO] "host: $1 unsupport..."
		exit 1
	fi
	
	make -j8 && make install
	cd -
	unset PKG_CONFIG_PATH
}

auto_clean_glib()
{
	CMD [$FUNCNAME-$LINENO] "rm -fr glib-2.40.2"
	rm -fr glib-2.40.2/
}

######################################################################
# Merge all libs
######################################################################
merge_mutil_libs()
{
	set -e
	CMD [$FUNCNAME-$LINENO] "ld -r -o $install_path/lib/libAUTOMAKE.a  -L $install_path/lib --whole-archive `ls $install_path/lib/*.a | xargs` --no-whole-archive"
	ld -r -o $install_path/lib/libAUTOMAKE.a  -L $install_path/lib --whole-archive `ls $install_path/lib/*.a | xargs` --no-whole-archive
	exit 0
}


######################################################################
# do work
######################################################################
if [ "$action" == "make" ] ;then
	set -e
	auto_make_zlib $host $install_path
	auto_make_libffi $host $install_path
	auto_make_glib $host $install_path
	exit 0
	
elif [ "$action" == "clean" ] ;then
	auto_clean_zlib
	auto_clean_libffi
	auto_clean_glib
	exit 0
elif [ "$action" == "merge" ] ;then
	merge_mutil_libs
	exit 0	
else
	ERR [$FUNCNAME-$LINENO] "unknow command..."
	exit 0
fi	




