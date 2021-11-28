

source ../scripts/common.sh

cur_dir=`pwd`
install_path=$cur_dir/../target

#
if [ $# -lt 2 ];then
	ERR [$FUNCNAME-$LINENO] "usage: $0 [action] [host]"
	CMD [$FUNCNAME-$LINENO] "action options: [make/clean/install/uninstall]"
	CMD [$FUNCNAME-$LINENO] "host options: [arm-hisiv300-linux/arm-hisiv400-linux/x86]"
	exit 1
fi

CMD [$FUNCNAME-$LINENO] "action=$action host=$host cur_dir=$cur_dir install_path=$install_path"

action=$1
LOG "action=$action"
if [ "$action" != "make" ] \
&& [ "$action" != "clean" ] \
&& [ "$action" != "install" ] \
&& [ "$action" != "uninstall" ] ;then
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
	&& make && make install
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
	
	make && make install
}

auto_clean_libffi()
{
	CMD [$FUNCNAME-$LINENO] "rm -fr libffi-3.2.1"
	rm -fr libffi-3.2.1/
}

######################################################################
# do work
######################################################################
if [ "$action" == "make" ] ;then
	auto_make_libffi $host $install_path
	exit 0
	
elif [ "$action" == "clean" ] ;then
	auto_clean_zlib
	exit 0
else
	ERR [$FUNCNAME-$LINENO] "unknow command..."
	exit 0
fi	

