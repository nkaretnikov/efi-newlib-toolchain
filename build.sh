source envvars.sh

export CFLAGS="-fPIC"

set -e

function check_hash {
  local hash=`sha1sum $1 | cut -f1 -d' '`
  if [[ $hash != $2 ]];
  then
    echo "$1 hash $hash doesn't match the expected $2"
    exit 1
  fi
}

mkdir $SRC_PREFIX

# Binutils.
mkdir $BINUTILS_SRC_DIR
cd $BINUTILS_SRC_DIR
wget https://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.gz
check_hash binutils-2.25.1.tar.gz "3b5e9351d94b94c037e55dd1f8e985a5a8cb0fde"
tar xf binutils-2.25.1.tar.gz

mkdir $BINUTILS_BUILD_DIR
cd $BINUTILS_BUILD_DIR
$BINUTILS_CONFIGURE --target=$TARGET --prefix=$PREFIX
make all -j4
make install

# GCC.
mkdir $GCC_SRC_DIR
cd $GCC_SRC_DIR
wget https://ftp.gnu.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.gz
check_hash gcc-4.9.3.tar.gz "8cd8fd546fada384bf3d5b3439d6825669c29a9d"
tar xf gcc-4.9.3.tar.gz

mkdir $GCC_BUILD_DIR
cd $GCC_BUILD_DIR
$GCC_CONFIGURE --target=$TARGET --prefix=$PREFIX --without-headers --with-newlib --with-gnu-as --with-gnu-ld --enable-languages=c,c++
make all-gcc -j4
make install-gcc

# Newlib.
mkdir $NEWLIB_SRC_DIR
cd $NEWLIB_SRC_DIR
git clone git://sourceware.org/git/newlib-cygwin.git
cd newlib-cygwin
git checkout eed35efbe67e3b0588d5afbdf7926eb9f52e5766

mkdir $NEWLIB_BUILD_DIR
cd $NEWLIB_BUILD_DIR
$NEWLIB_CONFIGURE --target=$TARGET --prefix=$PREFIX
make all -j4
make install

# GCC again.
cd $GCC_BUILD_DIR
$GCC_CONFIGURE --target=$TARGET --prefix=$PREFIX --with-newlib --with-gnu-as --with-gnu-ld --disable-shared --disable-libssp --enable-languages=c,c++
make all -j4
make install

# GNU EFI.
mkdir $EFI_SRC_DIR
cd $EFI_SRC_DIR
wget http://downloads.sourceforge.net/project/gnu-efi/gnu-efi-3.0.3.tar.bz2
check_hash gnu-efi-3.0.3.tar.bz2 "14e3c1861f3e2f7226f12d6d37ce2c2281155ce3"
tar xf gnu-efi-3.0.3.tar.bz2

cd gnu-efi-3.0.3
make PREFIX=$PREFIX all
make PREFIX=$PREFIX install

unset CFLAGS
