# export LD_LIBRARY_PATH=

PHONY : all

TARGET_NAME ?= target/bin/automakefile
LIBCOMM_D_NAME ?= target/lib/libautomakefile.so
LIBCOMM_S_NAME ?= target/lib/libautomakefile.a

#############################3

# Shell command ###########
TAR=tar
CP=/bin/cp
RM=/bin/rm -f
GREP=grep
SED=sed
MKDIR=mkdir -p
CHMOD=chmod
MV=mv
CD=cd
LN=ln
MAKE=make
MKNOD=mknod
PUSHD=pushd 
POPD=popd 
RMDIR=rmdir
DEPMOD=/sbin/depmod
RMDIR=rmdir
MKIMG=mkimage
PATCH=patch
DIFF=diff
TOUCH=touch
CAT=cat
PWD=`pwd`
HOME=$(shell cd ~ && pwd)

# How to install. If your install program does not support "-p", then
# you may have to run ranlib on the installed liblua.a.
INSTALL= install -p
INSTALL_EXEC= $(INSTALL) -m 0755
INSTALL_DATA= $(INSTALL) -m 0644

export MKDIR MAKE PWD HOME INSTALL INSTALL_EXEC INSTALL_DATA
#****************************************************************************
# functions defined: LOG
#****************************************************************************
# for debug
DEBUG_LOG_FILE='&2'
DEBUG_LOG_LEVEL=0

# ANSI COLORS for shell scrpts
COLOR_CRE="\033[39m"
COLOR_NORMAL="\033[0m"
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_MAGENTA="\033[36m"
COLOR_CYAN="\033[35m"
COLOR_WHITE="\033[37m"

#$1 string
log-err = $(shell echo -e ${COLOR_RED} ERR: ${1}${COLOR_NORMAL} >&2 )

#$1 string
log-warn = $(shell echo -e ${COLOR_YELLOW} WARN: ${1}${COLOR_NORMAL} >&2 )

#$1 string
log-cmd = $(shell echo -e ${COLOR_GREEN} CMD: ${1}${COLOR_NORMAL} >&2 )

# $1: string
log-debug = $(shell echo -e ${COLOR_CYAN} LOG: ${1}${COLOR_NORMAL} >&2 )

# $1: string
log-echo = $(shell echo -e ${COLOR_MAGENTA}${1}${COLOR_NORMAL} >&2 )
#############################################################################
LINK_STATIC ?= -Wl,-Bstatic
LINK_SHARED ?= -Wl,-Bdynamic
LINK_FALGS ?=
LINK_SLIBS ?=
LINK_DLIBS ?=
INSTALL_LIB ?= target/lib
LINK_COMMON_DEP_DLIBS ?= -lpthread -lm -lrt -ldl -lresolv 


export LINK_STATIC LINK_SHARED LINK_FALGS LINK_SLIBS LINK_DLIBS INSTALL_LIB

#****************************************************************************
# GCC
#****************************************************************************
HOST_NAME ?=
CROSS_COMPILE ?= 
CFLAGS ?=
LDFLAGS ?= 
TEST_CFLAGS ?= ${CFLAGS}
MERGE_LDFLAGS ?=
LD_LIBS ?= 
BUILD_FILE ?=

######################################
export BUILD_FILE
-include $(BUILD_FILE)
######################################

AS	= $(CROSS_COMPILE)as
LD	= $(CROSS_COMPILE)ld
CC	= $(CROSS_COMPILE)gcc
CPP	= $(CC) -E
AR	= $(CROSS_COMPILE)ar
NM	= $(CROSS_COMPILE)nm
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
RANLIB	= $(CROSS_COMPILE)ranlib

CFLAGS += -fPIC -rdynamic -pipe -O2 -Wall
CFLAGS += -I${CURDIR}/target/include



# merge share lib flags
MERGE_LDFLAGS := -z defs -z muldefs -undefined -Bsymbolic -shared
#MERGE_LDFLAGS := -t -z defs -z muldefs -undefined -Bsymbolic -shared


export AS LD CC CPP AR NM STRIP OBJCOPY OBJDUMP RANLIB CFLAGS LDFLAGS MERGE_LDFLAGS HOST_NAME

LINK_PATH := -L target/lib
PLATFORM_LIBS :=
LD_LIBS += -lpthread -lm -lrt -ldl -lresolv

ifeq ($(strip $(HOST_NAME)),arm-hisiv400-linux)
	PLATFORM_LIBS += 
	LINK_PATH += 
	CFLAGS += 
	CFLAGS += 
else
	LD_LIBS += -lselinux
	PLATFORM_LIBS += 
	LINK_PATH += 
	CFLAGS += 
	CFLAGS += 
endif


export TEST_CFLAGS LINK_PATH LD_LIBS

MAKEFILE_BUILD := scripts/Makefile.build
MAKEFILE_TEST_BUILD := scripts/Makefile.test.build
export MAKEFILE_BUILD MAKEFILE_TEST_BUILD

dirs := module/
dirs := ${patsubst %/,%,$(filter %/, $(dirs))}
PHONY += $(dirs)
$(dirs): FORCE
	@make -f ${MAKEFILE_BUILD}  obj=$@

build_comm_dym_lib: FORCE
	@$(call log-echo, "make build all common lib over !!! ")
	@$(call log-cmd, "Start building a shared library now...")
	@$(shell rm -f ${LIBCOMM_D_NAME})
	$(CC) ${CFLAGS} ${MERGE_LDFLAGS} -o ${LIBCOMM_D_NAME} ${LINK_PATH} \
	${LINK_STATIC} -Wl,--whole-archive ${shell ls ${INSTALL_LIB}/*.a} ${PLATFORM_LIBS} -Wl,--no-whole-archive \
	${LINK_SHARED} ${LD_LIBS}
	@$(call log-cmd, "make libcore.so SUCC...")

build_comms_static_lib: FORCE
	@$(call log-echo, "make build all common library over !!! ")
	@$(call log-cmd, "Start building a static library now...")
	@$(shell rm -f ${LIBCOMM_S_NAME})
	${LD} -r -o ${LIBCOMM_S_NAME}  ${LINK_PATH} --whole-archive ${shell ls ${INSTALL_LIB}/*.a} ${PLATFORM_LIBS} --no-whole-archive
	@$(call log-cmd, "make static library SUCC...")


build_3th: FORCE
	@${shell for i in `find 3th/ -name *.tar.*`;do tar -xvf $$i -C `dirname $$i` ;done}

objs := init/main.o

all: ${dirs} build_comms_static_lib build_comm_dym_lib FORCE

test_dirs := sample/
test_dirs := ${patsubst %/,%,$(filter %/, $(test_dirs))}
$(test_dirs): FORCE
	@make -f ${MAKEFILE_TEST_BUILD}  obj=$@
	
test: $(test_dirs) FORCE

opensouce_clean: FORCE
	@rm -fr module/glib/zlib-1.2.11
	@rm -fr module/glib/libffi-3.2.1
	@rm -fr module/glib/glib-2.40.2
	@rm -fr module/ubus/json-c
	@rm -fr module/ubus/libubox
	@rm -fr module/ubus/ubus
	@exit 0

clean: FORCE
	@echo  ">>> clean target"
	@rm -f *.bak *.so *.a
	@rm -f ${TARGET_NAME} ${LIBCOMM_NAME}
	@${shell for dir in `find -maxdepth 4 -type d | grep -v git| grep -v include | grep -v target |grep -v \.si4project`;\
	do rm -f $${dir}/*.o $${dir}/*.bak $${dir}/*.so $${dir}/*.a $${dir}/*.dep;done}
	@exit 0

distclean: opensouce_clean clean
	@echo ">>> distclean target"
	@rm -fr target
	@exit 0
	
help: 
	@echo  'Cleaning targets:'
	@echo  '  clean		  - Remove most generated files but keep the config and'
	@echo  '                    enough build support to build external modules'
	@echo  '  mrproper	  - Remove all generated files + config + various backup files'
	@echo  '  distclean	  - mrproper + remove editor backup and patch files'
	@echo  ''
	@exit 0


PHONY += FORCE
FORCE:
