#!/usr/bin/env bash

sudo apt-get update

#for libs
sudo apt-get install -y git cmake libcurl4-gnutls-dev libjansson-dev
sudo apt-get remove -y libyder-dev liborcania-dev liborcania1.1 libyder2.0 libulfius-dev ulfius2.2

#for counter
sudo apt-get install -y libhiredis0.13 libhiredis-dev

mkdir -p lib/
pushd lib/

[ -d libmicrohttpd-0.9.63 ] || {
  wget https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-latest.tar.gz
  tar zxvf libmicrohttpd-latest.tar.gz
  rm libmicrohttpd-latest.tar.gz
}

pushd libmicrohttpd-0.9.63
./configure --disable-doc --disable-examples --enable-https=no --disable-dauth --disable-httpupgrade 
make clean
make
sudo make install
popd

[ -d orcania ] || git clone https://github.com/babelouest/orcania.git
[ -d orcania/build ] && rm -rf orcania/build
mkdir -p orcania/build
pushd orcania/build
cmake .. -DBUILD_STATIC=on -DWITH_JOURNALD=off -DWITH_GNUTLS=off
make GNUTLSFLAG=1
sudo make install
popd

[ -d yder ] || git clone https://github.com/babelouest/yder.git
[ -d yder/build ] && rm -rf yder/build
mkdir -p yder/build
pushd yder/build
cmake .. -DBUILD_STATIC=on -DWITH_JOURNALD=off -DWITH_GNUTLS=off
make GNUTLSFLAG=1
sudo make install
popd

[ -d ulfius ] || git clone https://github.com/babelouest/ulfius.git
[ -d ulfius/build ] && rm -rf ulfius/build
mkdir -p ulfius/build
pushd ulfius/build
cmake .. -DBUILD_STATIC=on -DWITH_JOURNALD=off -DWITH_GNUTLS=off
make GNUTLSFLAG=1
sudo make install
popd

popd # exit lib/
