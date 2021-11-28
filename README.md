# auto makefile

make HOST_NAME=arm-hisiv400-linux CROSS_COMPILE=arm-hisiv400-linux-



#####################################################
# cmd
#####################################################
CC=gcc  CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2"


rm -fr zlib-1.2.11 && rm -fr glib-2.40.2  && rm -fr libffi-3.2.1

for i in `ls *.tar.gz`;do tar -zxf $i;done

unset CFLAGS
export CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2"

#####################################################

cd zlib-1.2.11 && \
./configure --static --enable-shared --prefix=`pwd`/../../target && \
make -j 8 && make install && cd -
#####################################################

cd libffi-3.2.1 && \
./configure  --enable-silent-rules --enable-static --enable-shared --prefix=`pwd`/../../target && \
make -j 8 && make install && cd -

#####################################################
cd glib-2.40.2 && \ 
./configure  --enable-silent-rules --enable-static --enable-shared --with-pcre=internal --disable-gtk-doc-html --disable-man \
glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=no ac_cv_func_posix_getgrgid_r=no --prefix=`pwd`/../../target \
CFLAGS="-fPIC -Wall -Wno-format -fno-strict-aliasing -O2 -Wno-format-nonliteral -Wno-format-overflow  -Wno-format-security" \
ZLIB_CFLAGS="-I `pwd`/../../target/include" ZLIB_LIBS="`pwd`/../../target/lib/libz.a" \
LIBFFI_CFLAGS="-I `pwd`/../../target/lib/libffi-3.2.1/include" LIBFFI_LIBS="`pwd`/../../target/lib/libffi.la" &&  \
make -j 8 && make install && cd -

#####################################################
cd glib-2.40.2 && make -j 8 && make install && cd -

