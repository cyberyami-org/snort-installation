#!/bin/bash
# update the system
sudo apt-get update && sudo apt-get dist-upgrade -y

# Creating a directory to store everything
mkdir ~/snort_src
cd ~/snort_src

# Install the Snort 3 prerequisites:
sudo apt-get install -y build-essential autotools-dev libdumbnet-dev libluajit-5.1-dev libpcap-dev \
zlib1g-dev pkg-config libhwloc-dev cmake liblzma-dev openssl libssl-dev cpputest libsqlite3-dev \
libtool uuid-dev git autoconf bison flex libcmocka-dev libnetfilter-queue-dev libunwind-dev \
libmnl-dev ethtool libjemalloc-dev

#Download and install safec for runtime bounds checks on certain legacy C-library calls:
cd ~/snort_src
wget https://github.com/rurban/safeclib/releases/download/v02092020/libsafec-02092020.tar.gz
tar -xzvf libsafec-02092020.tar.gz
cd libsafec-02092020.0-g6d921f
./configure
make
sudo make install

# First Install PCRE: Perl Compatible Regular Expressions. We don’t use the Ubuntu repository because it has an older version:
cd ~/snort_src/
wget wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz
tar -xzvf pcre-8.45.tar.gz
cd pcre-8.45
./configure
make
sudo make install

# Download and install gperftools:
cd ~/snort_src
wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
tar xzvf gperftools-2.9.1.tar.gz
cd gperftools-2.9.1
./configure
make
sudo make install

#Download and install Ragel:
cd ~/snort_src
wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz
tar -xzvf ragel-6.10.tar.gz
cd ragel-6.10
./configure
make
sudo make install

# And finally, download (but don’t install) the Boost C++ Libraries:
cd ~/snort_src
wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz
tar -xvzf boost_1_77_0.tar.gz

# Install Hyperscan 5.4 from source, referencing the location of the Boost source directory:
cd ~/snort_src
wget https://github.com/intel/hyperscan/archive/refs/tags/v5.4.0.tar.gz
tar -xvzf v5.4.0.tar.gz
mkdir ~/snort_src/hyperscan-5.4.0-build
cd hyperscan-5.4.0-build/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBOOST_ROOT=~/snort_src/boost_1_77_0/ ../hyperscan-5.4.0
make
sudo make install

# Install flatbuffers:
cd ~/snort_src
wget https://github.com/google/flatbuffers/archive/refs/tags/v2.0.0.tar.gz -O flatbuffers-v2.0.0.tar.gz
tar -xzvf flatbuffers-v2.0.0.tar.gz
mkdir flatbuffers-build
cd flatbuffers-build
cmake ../flatbuffers-2.0.0
make
sudo make install

# Next, download and install Data Acquisition library (DAQ) from the Snort website. Note that Snort 3 uses a different DAQ than the Snort 2.9.
cd ~/snort_src
wget https://github.com/snort3/libdaq/archive/refs/tags/v3.0.5.tar.gz -O libdaq-3.0.5.tar.gz
tar -xzvf libdaq-3.0.5.tar.gz
cd libdaq-3.0.5
./bootstrap
./configure
make
sudo make install

# Update shared libraries:
sudo ldconfig

# Now we are ready to download, compile, and install Snort 3 from the snort website. If you are interested in enabling additional compile-time
cd ~/snort_src
wget https://github.com/snort3/snort3/archive/refs/tags/3.1.18.0.tar.gz -O snort3-3.1.18.0.tar.gz
tar -xzvf snort3-3.1.18.0.tar.gz
cd snort3-3.1.18.0
./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc --enable-jemalloc
cd build
make
sudo make install

# Snort should now be installed under /usr/local/. Finally, verify that Snort runs correctly. To do this, we pass the snort executable the -V flag
/usr/local/bin/snort -V
