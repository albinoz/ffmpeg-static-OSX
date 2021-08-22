#!/bin/bash
clear
( exec &> >(while read -r line; do echo "$(date +"[%Y-%m-%d %H:%M:%S]") $line"; done;) #_Date to Every Line

tput bold ; echo "adam | 2014 < 2021-08-22" ; tput sgr0
tput bold ; echo "Download and Build Last Static FFmpeg" ; tput sgr0
tput bold ; echo "macOS 10.12 < 11 Build Compatibility" ; tput sgr0
echo "macOS $(sw_vers -productVersion) | $(system_profiler SPHardwareDataType | grep Memory | cut -d ':' -f2) | $(system_profiler SPHardwareDataType | grep Cores: | cut -d ':' -f2) Cores | $(system_profiler SPHardwareDataType | grep Speed | cut -d ':' -f2)" ; sleep 2

#_ Check Xcode CLI Install
tput bold ; echo ; echo '♻️  ' Check Xcode CLI Install ; tput sgr0
if xcode-select -v | grep version ; then tput sgr0 ; echo "Xcode CLI AllReady Installed" ; else tput bold ; echo "Xcode CLI Install" ; tput sgr0 ; xcode-select --install
sleep 1
while pgrep 'Install Command Line Developer Tools' >/dev/null ; do sleep 5 ; done
if xcode-select -v | grep version ; then tput sgr0 ; echo "Xcode CLI Was SucessFully Installed" ; else tput bold ; echo "Xcode CLI Was NOT Installed" ; tput sgr0 ; exit ; fi ; fi

#_ Check Homebrew Install
tput bold ; echo ; echo '♻️  ' Check Homebrew Install ; tput sgr0 ; sleep 2
if ls /usr/local/bin/brew >/dev/null ; then tput sgr0 ; echo "HomeBrew AllReady Installed" ; else tput bold ; echo "Installing HomeBrew" ; tput sgr0 ; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ; fi

#_ Check Homebrew Update
tput bold ; echo ; echo '♻️  ' Check Homebrew Update ; tput sgr0 ; sleep 2
brew cleanup ; brew doctor ; brew update ; brew upgrade

#_ Java Install - Fix PopUp
tput bold ; echo ; echo '♻️  ' Check Java Install ; tput sgr0 ; sleep 2
if java -version ; then tput sgr0 ; echo "Java AllReady Installed"
else tput bold ; echo "Java Install" ; tput sgr0 ; sleep 2
brew reinstall java
sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
fi

#_ Check Homebrew Config
tput bold ; echo ; echo '♻️  ' Check Homebrew Config ; tput sgr0 ; sleep 2
brew install git wget cmake autoconf automake nasm libtool ninja meson pkg-config rtmpdump
#brew uninstall --ignore-dependencies libx11

#_ Check Miminum Requirement Build Time
Time="$(echo 'obase=60;'$SECONDS | bc | sed 's/ /:/g' | cut -c 2-)"
tput bold ; echo ; echo '⏱  ' Miminum Requirement Build in "$Time"s ; tput sgr0 ; sleep 2

#_ Eject RamDisk
if df | grep RamDisk > /dev/null ; then tput bold ; echo ; echo '⏏  ' Eject RamDisk ; tput sgr0 ; fi
if df | grep RamDisk > /dev/null ; then diskutil eject RamDisk ; sleep 2 ; fi

#_ Made RamDisk
tput bold ; echo ; echo '💾 ' Made 1Go RamDisk ; tput sgr0
diskutil erasevolume HFS+ 'RamDisk' $(hdiutil attach -nomount ram://2097152)
#diskutil partitionDisk $(hdiutil attach -nomount ram://2097152) 1 GPTFormat APFS 'RamDisk' '100%'
sleep 1

#_ CPU & PATHS & ERROR
THREADS=$(sysctl -n hw.ncpu)
TARGET="/Volumes/RamDisk/sw"
CMPL="/Volumes/RamDisk/compile"
export PATH="${TARGET}"/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/include:/usr/local/opt:/usr/local/Cellar:/usr/local/lib:/usr/local/share:/usr/local/etc
mdutil -i off /Volumes/RamDisk

#_ Make RamDisk Directories
mkdir ${TARGET}
mkdir ${CMPL}



#-> BASE
tput bold ; echo ; echo ; echo '⚙️  ' Base Builds ; tput sgr0

#_ xz
tput bold ; echo ; echo '📍 ' xz git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://git.tukaani.org/xz.git
cd xz
./autogen.sh
./configure --prefix=${TARGET} --enable-static --disable-shared --disable-docs --disable-examples
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

set -o errexit

#_ libexpat
tput bold ; echo ; echo '📍 ' libexpat git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/libexpat/libexpat.git libexpat
cd libexpat/expat
./buildconf.sh
./configure --prefix=${TARGET} CPPFLAGS=-DXML_LARGE_SIZE --enable-static
make -j "$THREADS" && make install DESTDIR=/
rm -fr /Volumes/RamDisk/compile/*

#_ iconv
tput bold ; echo ; echo '📍 ' iconv 1.16 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz"
tar -zxvf libiconv*
cd libiconv*/
./configure --prefix=${TARGET} --with-iconv=${TARGET} --enable-static --enable-extra-encodings
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ gettext - Requirement for fontconfig, fribidi
tput bold ; echo ; echo '📍 ' gettext 0.21 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate "https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.gz"
tar -zxvf gettex*
cd gettex*/
#autoreconf -fiv
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-silent-rules --disable-debug --with-included-gettext --with-included-glib \
 --with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --disable-java --disable-native-java --disable-csharp \
 --disable-shared --enable-static --without-git --without-cvs --disable-docs --disable-examples
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ libpng git - Requirement for freetype
tput bold ; echo ; echo '📍 ' libpng git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/glennrp/libpng.git
cd libpng
autoreconf -fiv
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-silent-rules --enable-static --disable-shared
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ pkg-config
LastVersion=$(wget --no-check-certificate 'https://pkg-config.freedesktop.org/releases/' -O- -q | grep -Eo 'pkg-config-0.29[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate 'https://pkg-config.freedesktop.org/releases/'"$LastVersion"
tar -zxvf pkg-config-*
cd pkg-config-*/
./configure --prefix=${TARGET} --disable-debug --disable-host-tool --with-internal-glib
make -j "$THREADS" && make check && make install
rm -fr /Volumes/RamDisk/compile/*

#_ Yasm
LastVersion=$(wget --no-check-certificate 'http://www.tortall.net/projects/yasm/releases/' -O- -q | grep -Eo 'yasm-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate 'http://www.tortall.net/projects/yasm/releases/'"$LastVersion"
tar -zxvf /Volumes/RamDisk/compile/yasm-*
cd yasm-*/
./configure --prefix=${TARGET} && make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ bzip2
tput bold ; echo ; echo '📍 ' bzip2 git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone git://sourceware.org/git/bzip2.git bzip2
cd bzip2
make -j "$THREADS" && make install PREFIX=${TARGET}
rm -fr /Volumes/RamDisk/compile/*

#_ SDL2
tput bold ; echo ; echo '📍 ' SDL2 2.0.14 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget http://www.libsdl.org/release/SDL2-2.0.14.tar.gz
tar xvf SDL2-*.tar.gz
cd SDL2*/
./autogen.sh
./configure --prefix=${TARGET} --enable-static --disable-shared --without-x --enable-hidapi
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ libudfread git
tput bold ; echo ; echo '📍 ' libudfread git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/vlc-mirror/libudfread.git
cd libud*/
./bootstrap
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install

#_ bluray git
JAVAV=$(find /Library/Java/JavaVirtualMachines -iname "*.jdk" | tail -1)
export JAVA_HOME="$JAVAV/Contents/Home"
tput bold ; echo ; echo '📍 ' libbluray git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://code.videolan.org/videolan/libbluray.git
cd libblura*/
cp -r /Volumes/RamDisk/compile/libudfread/src /Volumes/RamDisk/compile/libbluray/contrib/libudfread/src
./bootstrap
./configure --prefix=${TARGET} --disable-shared --disable-dependency-tracking --build x86_64 --disable-doxygen-dot --without-libxml2 --without-freetype --disable-udf --disable-bdjava-jar
cp -vpfr /Volumes/RamDisk/compile/libblura*/jni/darwin/jni_md.h /Volumes/RamDisk/compile/libblura*/jni
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*



#-> SUBTITLES
tput bold ; echo ; echo ; echo '⚙️  ' Subtitles Builds ; tput sgr0

#_ freetype
LastVersion=$(wget --no-check-certificate 'https://download.savannah.gnu.org/releases/freetype/' -O- -q | grep -Eo 'freetype-[0-9\.]+\.10+\.[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate 'https://download.savannah.gnu.org/releases/freetype/'"$LastVersion"
tar xzpf freetype-*
cd freetype-*/
pip3 install docwriter
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ fribidi
tput bold ; echo ; echo '📍 ' fribidi 1.0.10 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate https://github.com/fribidi/fribidi/releases/download/v1.0.10/fribidi-1.0.10.tar.xz
tar -xJf fribid*
cd fribid*/
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-silent-rules --disable-debug --disable-dependency-tracking
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ fontconfig
tput bold ; echo ; echo '📍 ' fontconfig 2.13.92 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.92.tar.gz
tar xzpf fontconfig-*
cd fontconfig-*/
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-silent-rules --with-add-fonts="/System/Library/Fonts,/Library/Fonts" --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ harfbuzz git
tput bold ; echo ; echo '📍 ' harfbuzz git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/harfbuzz/harfbuzz.git
cd harfbuzz
./autogen.sh
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ libass git ( require harfbuzz )
tput bold ; echo ; echo '📍 ' libass git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/libass/libass.git
cd libas*/
./autogen.sh
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ openssl
LastVersion=$(wget --no-check-certificate 'https://www.openssl.org/source/' -O- -q | grep -Eo 'openssl-[0-9\.]+\.[0-9\.]+\.[0-9\.]+[A-Za-z].tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate https://www.openssl.org/source/"$LastVersion"
tar -zxvf openssl*
cd openssl-*/
./Configure --prefix=${TARGET} -openssldir=${TARGET}/usr/local/etc/openssl no-ssl3 no-zlib enable-cms darwin64-x86_64-cc shared enable-ec_nistp_64_gcc_128
make -j "$THREADS" depend && make install_sw
rm -fr /Volumes/RamDisk/compile/*

#_ str ( Require openssl )
tput bold ; echo ; echo '📍 ' str git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone --depth 1 https://github.com/Haivision/srt.git
cd srt/
mkdir build && cd build
cmake -G "Ninja" .. -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_C_DEPS=ON -DENABLE_SHARED=OFF -DENABLE_STATIC=ON
ninja && ninja install
rm -fr /Volumes/RamDisk/compile/*

#_ snappy
tput bold ; echo ; echo '📍 ' snappy 1.1.8 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget -O snappy.tar.gz --no-check-certificate https://github.com/google/snappy/archive/1.1.8.tar.gz
tar -zxvf snappy.tar.gz
cd snappy-*/
mkdir build && cd build
cmake -G "Ninja" ../ -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_SHARED="OFF" -DENABLE_C_DEPS="ON"
ninja && ninja install
rm -fr /Volumes/RamDisk/compile/*

#-> AUDIO
tput bold ; echo ; echo ; echo '⚙️  ' Audio Builds ; tput sgr0

#_ openal-soft
tput bold ; echo ; echo '📍 ' openal-soft git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/kcat/openal-soft
cd openal-soft*/
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC .
ninja && ninja install
rm -fr /Volumes/RamDisk/compile/*

#_ opencore-amr
tput bold ; echo ; echo '📍 ' opencore-amr ; tput sgr0 ; sleep 2
cd ${CMPL}
curl -O http://freefr.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.5.tar.gz
tar -zxvf /Volumes/RamDisk/compile/opencore-amr-0.1.5.tar.gz
cd opencore-amr-0.1.5
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ opus - Replace speex
LastVersion=$(wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/opus/ -O- -q | grep -Eo 'opus-1.[0-9\.]+\.[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/opus/"$LastVersion"
tar -zxvf opus-*
cd opus-*/
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ ogg
LastVersion=$(wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/ogg/ -O- -q | grep -Eo 'libogg-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/ogg/"$LastVersion"
tar -zxvf libogg-*
cd libogg-*/
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-dependency-tracking
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ Theora git - Require nf automake libtool
tput bold ; echo ; echo '📍 ' theora git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/xiph/theora.git
cd theora
./autogen.sh
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --with-vorbis-libraries=${TARGET}/lib --with-vorbis-includes=${TARGET}/include/ --enable-static --disable-shared
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ vorbis
LastVersion=$(wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/vorbis/ -O- -q | grep -Eo 'libvorbis-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/vorbis/"$LastVersion"
tar -zxvf libvorbis-*
cd libvorbis-*/
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=/Volumes/RamDisk/sw/include/ --enable-static --disable-shared
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ lame git
tput bold ; echo ; echo '📍 ' lame git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/rbrito/lame.git
cd lam*/
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ TwoLame - optimised MPEG Audio Layer 2
LastVersion=$(wget --no-check-certificate 'http://www.twolame.org' -O- -q | grep -Eo 'twolame-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate 'http://downloads.sourceforge.net/twolame/'"$LastVersion"
tar -zxvf twolame-*
cd twolame-*/
./configure --prefix=${TARGET} --enable-static --enable-shared=no
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ fdk-aac
tput bold ; echo ; echo '📍 ' fdk-aac ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate "https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.1.tar.gz"
tar -zxvf fdk-aac-*
cd fdk*/
./configure --disable-dependency-tracking --prefix=${TARGET} --enable-static --enable-shared=no
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ gsm
tput bold ; echo ; echo '📍 ' libgsm 1.0.19 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate 'http://www.quut.com/gsm/gsm-1.0.19.tar.gz'
tar -zxvf gsm*
cd gsm*/
mkdir -p ${TARGET}/man/man3
mkdir -p ${TARGET}/man/man1
mkdir -p ${TARGET}/include/gsm
perl -p -i -e "s#^INSTALL_ROOT.*#INSTALL_ROOT = $TARGET#g" Makefile
perl -p -i -e "s#_ROOT\)/inc#_ROOT\)/include#g" Makefile
sed "/GSM_INSTALL_INC/s/include/include\/gsm/g" Makefile > Makefile.new
mv Makefile.new Makefile
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ speex
tput bold ; echo ; echo '📍 ' libspeex 1.2.0 ; tput sgr0 ; sleep 2
cd ${CMPL}
wget http://downloads.us.xiph.org/releases/speex/speex-1.2.0.tar.gz
tar xvf speex-1.2.0.tar.gz
cd speex-1.2.0
./configure --prefix=${TARGET} --enable-static --enable-shared=no
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*



#-> VIDEO
tput bold ; echo ; echo ; echo '⚙️  ' Video Builds ; tput sgr0

#_ libzimg
tput bold ; echo ; echo '📍 ' libzimg git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/sekrit-twc/zimg.git
cd zimg
./autogen.sh
./Configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ libvpx git
tput bold ; echo ; echo '📍 ' vpx git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/webmproject/libvpx.git
cd libvp*/
./configure --prefix=${TARGET} --enable-vp8 --enable-postproc --enable-vp9-postproc --enable-vp9-highbitdepth --disable-examples --disable-docs --enable-multi-res-encoding --disable-unit-tests --enable-pic --disable-shared
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ webp
tput bold ; echo ; echo '📍 ' webp git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://chromium.googlesource.com/webm/libwebp
cd libweb*/
./autogen.sh
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-gif --disable-gl --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ openjpeg
tput bold ; echo ; echo '📍 ' openjpeg git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/uclouvain/openjpeg.git
cd openjpeg
mkdir build && cd build
cmake -G "Ninja" .. -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC
ninja && ninja install
rm -fr /Volumes/RamDisk/compile/*

#_ av1 git
tput bold ; echo ; echo '📍 ' av1 git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://aomedia.googlesource.com/aom
cd aom
mkdir aom_build && cd aom_build
cmake -G "Ninja" /Volumes/RamDisk/compile/aom -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC
ninja && ninja install
rm -fr /Volumes/RamDisk/compile/*

#_ dav1d git - Require ninja, meson
tput bold ; echo ; echo '📍 ' dav1d git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://code.videolan.org/videolan/dav1d.git
cd dav1*/
meson --prefix=${TARGET} build --buildtype release --default-library static
ninja install -C build
rm -fr /Volumes/RamDisk/compile/*

#_ xvid
LastVersion=$(wget --no-check-certificate https://downloads.xvid.com/downloads/ -O- -q | grep -Eo 'xvidcore-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" ; tput sgr0 ; sleep 2
cd ${CMPL}
wget --no-check-certificate https://downloads.xvid.com/downloads/"$LastVersion"
tar -zxvf xvidcore*
cd xvidcore/build/generic/
./bootstrap.sh
./configure --prefix=${TARGET} --disable-assembly --enable-macosx_module
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ openh264
tput bold ; echo ; echo '📍 ' openH264 git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/cisco/openh264.git
cd openh264/
make -j "$THREADS" install-static PREFIX=${TARGET}
rm -fr /Volumes/RamDisk/compile/*

#_ x264 8-10bit git - Require nasm
tput bold ; echo ; echo '📍 ' x264 8-10bit git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://code.videolan.org/videolan/x264.git
cd x264/
./configure --prefix=${TARGET} --enable-static --bit-depth=all --chroma-format=all --enable-mp4-output
make -j "$THREADS" && make install
rm -fr /Volumes/RamDisk/compile/*

#_ x265 8-10-12bit - Require wget, cmake, yasm, nasm, libtool, ninja
tput bold ; echo ; echo '📍 ' x265 8-10-12bit git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://bitbucket.org/multicoreware/x265_git/src/master/ x265-master
cd x265*/source/
mkdir -p 8bit 10bit 12bit

tput bold ; echo ; echo '📍 ' x265 12bit Build ; tput sgr0 ; sleep 2
cd 12bit
cmake -G "Ninja" ../../../x265*/source -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DMAIN12=ON
ninja ${MAKEFLAGS}

tput bold ; echo ; echo '📍 ' x265 10bit Build ; tput sgr0 ; sleep 2
cd ../10bit
cmake -G "Ninja" ../../../x265*/source -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF
ninja ${MAKEFLAGS}

tput bold ; echo ; echo '📍 ' x265 10-12bit Link ; tput sgr0 ; sleep 2
cd ../8bit
ln -sf ../10bit/libx265.a libx265_main10.a
ln -sf ../12bit/libx265.a libx265_main12.a

tput bold ; echo ; echo '📍 ' x265 8-10-12bit Build ; tput sgr0
cmake -G "Ninja" ../../../x265*/source -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_SHARED=NO -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON -DLINKED_12BIT=ON
ninja ${MAKEFLAGS}

tput bold ; echo ; echo '📍 ' x265 Install ; tput sgr0
#_ rename the 8bit library, then combine all three into libx265.a
mv libx265.a libx265_main.a
#_ Mac/BSD libtool
libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a
ninja install
rm -fr /Volumes/RamDisk/compile/*

#_ AviSynth+
tput bold ; echo ; echo '📍 ' AviSynthPlus git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone https://github.com/AviSynth/AviSynthPlus.git
cd AviSynthPlus
mkdir avisynth-build && cd avisynth-build
cmake ../ -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DHEADERS_ONLY:bool=on
make install
rm -fr /Volumes/RamDisk/compile/*

#_ librtmp
tput bold ; echo ; echo '📍 ' librtmp 2.4 Copy ; tput sgr0 ; sleep 2
cp -v /usr/local/Cellar/rtmpdump/2.4+20151223_1/bin/* /Volumes/RamDisk/sw/bin/
cp -vr /usr/local/Cellar/rtmpdump/2.4+20151223_1/include/* /Volumes/RamDisk/sw/include/
cp -v /usr/local/Cellar/rtmpdump/2.4+20151223_1/lib/pkgconfig/librtmp.pc /Volumes/RamDisk/sw/lib/pkgconfig
cp -v /usr/local/Cellar/rtmpdump/2.4+20151223_1/lib/librtmp* /Volumes/RamDisk/sw/lib



#-> FFmpeg Check
tput bold ; echo ; echo ; echo '⚙️  ' FFmpeg Build ; tput sgr0

#_ Purge .dylib
tput bold ; echo ; echo '💢 ' Purge .dylib ; tput sgr0 ; sleep 2
rm -vfr $TARGET/lib/*.dylib

#_ Flags
tput bold ; echo ; echo '🚩 ' Define FLAGS ; tput sgr0 ; sleep 2
export LDFLAGS="-L${TARGET}/lib -Wl,-framework,OpenAL"
export CPPFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL"
export CFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL,-fno-stack-check"

#_ FFmpeg Build
tput bold ; echo ; echo '📍 ' FFmpeg git ; tput sgr0 ; sleep 2
cd ${CMPL}
git clone git://git.ffmpeg.org/ffmpeg.git
cd ffmpe*/
./configure --extra-version=adam-"$(date +"%Y-%m-%d")" --extra-cflags="-fno-stack-check" --arch=x86_64 --cc=/usr/bin/clang \
 --enable-pthreads --enable-postproc --enable-runtime-cpudetect \
 --pkg_config='pkg-config --static' --enable-nonfree --enable-gpl --enable-version3 --prefix=${TARGET} \
 --disable-ffplay --disable-ffprobe --disable-debug --disable-doc --enable-avfilter --enable-avisynth --enable-filters \
 --enable-libopus --enable-libvorbis --enable-libtheora --enable-libspeex --enable-libmp3lame --enable-libfdk-aac --enable-encoder=aac \
 --enable-libtwolame --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libopencore_amrwb --enable-libgsm \
 --enable-muxer=mp4 --enable-libxvid --enable-libopenh264 --enable-libx264 --enable-libx265 --enable-libvpx --enable-libaom --enable-libdav1d \
 --enable-fontconfig --enable-libfreetype --enable-libfribidi --enable-libass --enable-libsrt \
 --enable-libbluray --enable-bzlib --enable-zlib --enable-lzma --enable-libsnappy --enable-libwebp --enable-libopenjpeg \
 --enable-opengl --enable-opencl --enable-openal --enable-libzimg --enable-openssl --enable-librtmp

 make -j "$THREADS" && make install

#_ Check Static
tput bold ; echo ; echo '♻️  ' Check Static FFmpeg ; tput sgr0 ; sleep 2
if otool -L /Volumes/RamDisk/sw/bin/ffmpeg | grep /usr/local
then echo FFmpeg build Not Static, Please Report
open ~/Library/Logs/adam-FFmpeg-Static.log
else echo FFmpeg build Static, Have Fun
cp /Volumes/RamDisk/sw/bin/ffmpeg ~/Desktop/ffmpeg
fi

#_ End Time
Time="$(echo 'obase=60;'$SECONDS | bc | sed 's/ /:/g' | cut -c 2-)"
tput bold ; echo ; echo '⏱  ' End in "$Time"s ; tput sgr0
) 2>&1 | tee "$HOME/Library/Logs/adam-FFmpeg-Static.log"
