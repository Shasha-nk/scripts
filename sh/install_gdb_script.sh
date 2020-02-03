#!/usr/bin/bash

set -e
set -x

MY_HOME=`pwd`
GDB_VERSION=8.3.1


wget=`which wget`
url='www.google.com'
wget -q --proxy-user=test --proxy-password=test --spider $url
if [ $? = 1 ]
then
    STATUS="PROXY : DISABLED"
    wget="/usr/bin/wget --no-proxy"
else
    STATUS="PROXY : ENABLED"
    wget="/usr/bin/wget"
fi
echo $STATUS

download_req_files()
{
	#Below 2 dependencies to be installed
	#dnf --enablerepo=PowerTools install texinfo
	#dnf --enablerepo=PowerTools install doxygen doxygen-latex doxygen-doxywizard
	wget https://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.gz
}

install_gdb()
{
	cd $MY_HOME
	tar -zxvf gdb-${GDB_VERSION}.tar.gz
	cd gdb-${GDB_VERSION}
	./configure --enable-gold --enable-ld --enable-libada --enable-libssp --with-system-zlib --prefix=$MY_HOME/gdb-${GDB_VERSION}
	make
	make -C gdb/doc doxy  #This is required only if you need documentation
	make -C gdb install
}

run_gdb()
{
	download_req_files
	install_gdb
	echo "==========GDB IS INSTALLED ON YOUR SYSTEM=========="
	echo "==========GDB executable is present in $MY_HOME/bin=========="
	echo "==========Please create soft link to $MY_HOME/bin/gdb=========="
}

run_gdb
