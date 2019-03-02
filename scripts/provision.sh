#!/usr/bin/env bash

CROSS_TRIPLE=${CROSS_TRIPLE:-x86_64-linux-gnu}

#use latest cmake
CMAKE=3.10.2
[[ `cmake --version` =~ "${CMAKE}" ]] || {
  wget -q https://github.com/Kitware/CMake/releases/download/v${CMAKE}/cmake-${CMAKE}-Linux-x86_64.sh
  sudo bash ./cmake-${CMAKE}-Linux-x86_64.sh --skip-license --prefix=/usr/local
  rm cmake-${CMAKE}-Linux-x86_64.sh
}

mkdir -p lib/
pushd lib/

[ -f /usr/local/lib/libhiredis.a ] || {
  wget -q https://github.com/redis/hiredis/archive/master.tar.gz
  tar zxvf master.tar.gz
  rm master.tar.gz
  pushd hiredis-master
  make static
  sudo make install
  popd
  rm -fr hiredis
}

[ -f /usr/local/lib/libcurl.a ] || {
  [ -d /usr/src/curl-7.52.1 ] || {
    sudo wget -q https://curl.haxx.se/download/curl-7.52.1.tar.gz 
    sudo tar zxvf curl-7.52.1.tar.gz -C /usr/src
    sudo rm curl-7.52.1.tar.gz
  }
  pushd /usr/src/curl-7.52.1
  ./configure --enable-static --host=${CROSS_TRIPLE} --target=${CROSS_TRIPLE}
  make
  sudo make install
  popd
}

[ -f /usr/local/lib/libjansson.a ] || {
  [ -d jansson ] || {
    wget -q https://github.com/akheron/jansson/archive/master.tar.gz
    tar zxvf master.tar.gz
    rm master.tar.gz
    pushd jansson-master
    cmake . -DJANSSON_BUILD_DOCS=OFF
    make
    sudo make install
  }

  popd
  rm -fr jansson 
}

[ -f /usr/local/lib/libmicrohttpd.a ] || {

  [ -d libmicrohttpd-0.9.63 ] || {
    wget -q https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-latest.tar.gz
    tar zxvf libmicrohttpd-latest.tar.gz
    rm libmicrohttpd-latest.tar.gz
  }

  pushd libmicrohttpd-0.9.63
  ./configure --host=$CROSS_TRIPLE --target=$CROSS_TRIPLE --disable-dependency-tracking --disable-doc --disable-examples --enable-https=no --disable-dauth --disable-httpupgrade 
  make clean
  make
  sudo make install
  popd
  rm -fr libmicrohttpd-0.9.63
}


[ -f /usr/local/lib/liborcania.a ] || {
  [ -d orcania ] || {
    wget -q https://github.com/babelouest/orcania/archive/master.tar.gz
    tar zxvf master.tar.gz
    rm master.tar.gz
  }
  mkdir -p orcania-master/build
  pushd orcania-master/build
  cmake .. -DBUILD_STATIC=on -DWITH_JOURNALD=off -DWITH_GNUTLS=off
  make GNUTLSFLAG=1
  sudo make install
  popd
  rm -fr orcania
}


[ -f /usr/local/lib/libyder.a ] || {
  [ -d yder ] || {
    wget -q https://github.com/babelouest/yder/archive/master.tar.gz
    tar zxvf master.tar.gz
    rm master.tar.gz
  }
  mkdir -p yder-master/build
  pushd yder-master/build
  cmake .. -DBUILD_STATIC=on -DWITH_JOURNALD=off -DWITH_GNUTLS=off
  make GNUTLSFLAG=1
  sudo make install
  popd
  rm -fr yder
}


[ -f /usr/local/lib/libulfius.a ] || {
  [ -d ulfius ] || {
    wget -q https://github.com/babelouest/ulfius/archive/master.tar.gz
    tar zxvf master.tar.gz
    rm master.tar.gz
  }
  mkdir -p ulfius-master/build
  pushd ulfius-master/build
  cmake .. -DBUILD_STATIC=on -DWITH_JOURNALD=off -DWITH_GNUTLS=off
  make GNUTLSFLAG=1
  sudo make install
  popd
  rm -fr ulfius
}

popd # exit lib/
rm -fr lib/
