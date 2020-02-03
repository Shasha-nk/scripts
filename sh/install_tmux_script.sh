#!/usr/bin/bash
# Script for installing tmux on systems where you don't have root access.
# Assumption        : C/C++ compiler & wget are installed.
# Installation dir  : $HOME/local/bin.
# Details           : Script is copied from https://gist.github.com/ryin/3106801
#                   : and updated acc to needs

set -e
set -x

HOME=`pwd`
TMUX_VERSION=3.0a
LIBEVENT_VERSION=2.1.11-stable
NCURSES_VERSION=6.1

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

create_dirs()
{
    mkdir -p $HOME/local
    mkdir -p $HOME/log
}

download_req_files()
{
    $wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
    $wget https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz
    $wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
}

install_libevents()
{
    cd $HOME
    tar xvzf libevent-${LIBEVENT_VERSION}.tar.gz
    mv libevent-${LIBEVENT_VERSION}.tar.gz $HOME/libevent-${LIBEVENT_VERSION}
    cd $HOME/libevent-${LIBEVENT_VERSION}
    ./configure --prefix=$HOME/local --disable-shared
    make
    make install
}

install_ncurses()
{
    cd $HOME
    tar xvzf ncurses-${NCURSES_VERSION}.tar.gz
    mv ncurses-${NCURSES_VERSION}.tar.gz $HOME/ncurses-${NCURSES_VERSION}
    cd $HOME/ncurses-${NCURSES_VERSION}
    ./configure --prefix=$HOME/local
    make 
    make install
}

install_tmux()
{
    cd $HOME
    tar xvzf tmux-${TMUX_VERSION}.tar.gz
    mv tmux-${TMUX_VERSION}.tar.gz tmux-${TMUX_VERSION}
    cd tmux-${TMUX_VERSION}
    ./configure CFLAGS="-I$HOME/local/include \
            -I$HOME/local/include/ncurses" \
            LDFLAGS="-L$HOME/local/lib \
            -L$HOME/local/include/ncurses \
            -L$HOME/local/include"
    CPPFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-static -L$HOME/local/include -L$HOME/local/include/ncurses -L$HOME/local/lib" make
    cp tmux $HOME/local/bin
}

clean_tmp_dir()
{
    echo "#REMOVING ALL DOWNLOADED FILES=========="
    rm -rf $HOME/tmux-${TMUX_VERSION}
    rm -rf $HOME/ncurses-${NCURSES_VERSION}
    rm -rf $HOME/libevent-${LIBEVENT_VERSION}
    echo "#CREATING SOFT LINK FOR TMUX"
}

run_tmux()
{
    create_dirs
    download_req_files 2>&1 | tee $HOME/log/log_tmux.txt
    install_libevents 2>&1 | tee -a $HOME/log/log_tmux.txt
    install_ncurses 2>&1 | tee -a $HOME/log/log_tmux.txt
    install_tmux 2>&1 | tee -a $HOME/log/log_tmux.txt
    echo "$HOME/local/bin/tmux is now available." 2>&1 | tee -a $HOME/log/log_tmux.txt
    echo "Please add $HOME/local/bin to your PATH or else tmux would not be available from all directories" 2>&1 | tee -a $HOME/log/log_tmux.txt
}

run_tmux
