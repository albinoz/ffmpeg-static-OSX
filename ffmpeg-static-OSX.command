#!/bin/sh

clear
tput bold ; echo "adam | 2014 < 2018-12-02" ; tput sgr0
tput bold ; echo "OS X | 10.10 < 10.14" ; tput sgr0
tput bold ; echo "Auto ! Download && Build Last Static FFmpeg 64bits" ; tput sgr0

# Check Xcode CLI Install
tput bold ; echo "" ; echo "=-> Check Xcode CLI Install" ; tput sgr0
if pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version  ; then tput bold ; echo "Xcode CLI AllReady Installed" ; else tput bold ; echo "Xcode CLI Install" ; tput sgr0 ; xcode-select --install
sleep 1
while ps -ax | grep -v grep | grep 'Install Command Line Developer Tools' >/dev/null ; do sleep 5 ; done
if pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version  ; then tput bold ; echo "Xcode CLI Was SucessFully Installed" ; else tput bold ; echo "Xcode CLI Was NOT Installed" ; tput sgr0 ; exit ; fi ; fi

# Check Homebrew Install
tput bold ; echo "" ; echo "=-> Check Homebrew Install" ; sleep 3
if ls /usr/local/bin/brew >/dev/null ; then tput bold ; echo "HomeBrew AllReady Installed" ; else tput bold ; echo "Installing HomeBrew" ; /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ; fi

# Check Homebrew Update
tput bold ; echo "" ; echo "=-> Check Homebrew Update" ; tput sgr0 ; sleep 3
brew update ; brew upgrade ; brew cleanup ; brew prune

# Check Homebrew Config ( ant Require java )
tput bold ; echo "" ; echo "=-> Check Homebrew Config" ; tput sgr0 ; sleep 3
brew install git wget cmake autoconf automake nasm libtool #ant
brew uninstall ffmpeg
brew uninstall lame
brew uninstall x264
brew uninstall x265
brew uninstall xvid
brew uninstall vpx
brew uninstall faac
brew uninstall yasm
#brew uninstall pcre

#-> Ramdisk, Paths, Flags, CPU(s) & Exit on Error & Fix JAVA PopUp
# Eject Ramdisk
if df | grep Ramdisk ; then tput bold ; echo "" ; echo "=-> Eject Ramdisk" ; tput sgr0  ; fi
if df | grep Ramdisk ; then diskutil eject Ramdisk ; sleep 3 ; fi

# Made Ramdisk
tput bold ; echo "" ; echo "=-> Made Ramdisk" ; tput sgr0 
DISK_ID=$(hdid -nomount ram://5000000)
newfs_hfs -v Ramdisk ${DISK_ID}
diskutil mount ${DISK_ID}
sleep 3

# CPU(s)
THREADS=`sysctl -n hw.ncpu`

# Paths
TARGET="/Volumes/Ramdisk/sw"
CMPL="/Volumes/Ramdisk/compile"
mkdir ${TARGET}
mkdir ${CMPL}
export PATH=${TARGET}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/include:/usr/local/opt:/usr/local/Cellar:/usr/local/lib:/usr/local/share:/usr/local/etc

# Exit on Error
set -o errexit



#-> BASE

# Apple Java Install - Fix PopUp
tput bold ; echo "" ; echo "Check Java Install - Fix PopUp" ; tput sgr0 ; sleep 3
if ls /Library/Java/JavaVirtualMachines/ | grep jdk ; then tput bold ; echo "Java is Installed"
else tput bold ; echo "Apple Java Install - Fix PopUp" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget http://supportdownload.apple.com/download.info.apple.com/Apple_Support_Area/Apple_Software_Updates/Mac_OS_X/downloads/031-33898-20171026-7a797e9e-b8de-11e7-b1fe-c14fbda7e146/javaforosx.dmg
hdiutil attach -nobrowse ${CMPL}/javaforosx.dmg ; sleep 3
sudo installer -pkg /Volumes/Java\ for\ macOS\ 2017-001/JavaForOSX.pkg -target /
hdiutil detach /Volumes/Java\ for\ macOS\ 2017-001/ ; sleep 3
fi

## gettext
## Requirement for fontconfig, fribidi
tput bold ; echo "" ; echo "=-> gettext 0.19.8.1" ; tput sgr0 ; sleep 3
cd ${CMPL}
#wget --no-check-certificate "ftp://ftp.gnu.org/gnu/gettext/gettext-0.19.8.1.tar.gz"
wget --no-check-certificate "http://ftp.igh.cnrs.fr/pub/gnu/gettext/gettext-0.19.8.1.tar.gz"
tar -zxvf gettex*
cd gettex*
# edit the file stpncpy.c to add #undef stpncpy just before #ifndef weak_alias
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-silent-rules --disable-debug --with-included-gettext --with-included-glib \
 --with-included-libcroco --with-included-libunistring --with-emacs --disable-java --disable-native-java --disable-csharp --with-lispdir=#{elisp} \
 --disable-shared --enable-static --without-git --without-cvs --without-xz --disable-docs
make -j $THREADS && make install

## libpng git
## Requirement for freetype
tput bold ; echo "" ; echo "=-> libpng git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://github.com/glennrp/libpng.git
cd libpng
autoreconf -f -i
./configure --prefix=${TARGET}  --disable-dependency-tracking --disable-silent-rules --enable-static --disable-shared
make -j $THREADS && make install

## pkg-config
LastVersion=`wget  --no-check-certificate 'https://pkg-config.freedesktop.org/releases/' -O- -q | egrep -o 'pkg-config-0.29[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'https://pkg-config.freedesktop.org/releases/'${LastVersion}
tar -zxvf pkg-config-*
cd pkg-config-*
./configure --prefix=${TARGET} --disable-debug --disable-host-tool --with-internal-glib && make -j $THREADS && make install

## Yasm
LastVersion=`wget --no-check-certificate 'http://www.tortall.net/projects/yasm/releases/' -O- -q | egrep -o 'yasm-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'http://www.tortall.net/projects/yasm/releases/'${LastVersion}
tar -zxvf /Volumes/Ramdisk/compile/yasm-*
cd yasm-*
./configure --prefix=${TARGET} && make -j $THREADS && make install

## bzip
tput bold ; echo "" ; echo "=-> bzip" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://github.com/enthought/bzip2-1.0.6
cd bzip2-1.0.6
make -j $THREADS && make install PREFIX=${TARGET}

## libudfread git
tput bold ; echo "" ; echo "=-> libudfread git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://github.com/vlc-mirror/libudfread.git
cd libud*
./bootstrap
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

## bluray git
JAVAV=`ls /Library/Java/JavaVirtualMachines/ | tail -1`
export JAVA_HOME="/Library/Java/JavaVirtualMachines/$JAVAV/Contents/Home"
tput bold ; echo "" ; echo "=-> libbluray git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone http://git.videolan.org/git/libbluray.git
cd libblura*
cp -r /Volumes/Ramdisk/compile/libudfread/src /Volumes/Ramdisk/compile/libbluray/contrib/libudfread/src
./bootstrap
./configure --prefix=${TARGET} --disable-shared --disable-dependency-tracking --build x86_64 --disable-doxygen-dot --without-libxml2 --without-freetype --disable-udf --disable-bdjava-jar
cp -vpfr /Volumes/Ramdisk/compile/libblura*/jni/darwin/jni_md.h /Volumes/Ramdisk/compile/libblura*/jni
make -j $THREADS && make install



#-> SUBTITLES

## freetype
LastVersion=`wget --no-check-certificate 'http://download.savannah.gnu.org/releases/freetype/' -O- -q | egrep -o 'freetype-[0-9\.]+\.[0-9\.]+\.[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'http://download.savannah.gnu.org/releases/freetype/'${LastVersion}
tar xzpf freetype-*
cd freetype-*
./configure --prefix=${TARGET}  --disable-shared --enable-static  && make -j $THREADS && make install

## fribidi
tput bold ; echo "" ; echo "=-> fribidi 1.0.5" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate https://github.com/fribidi/fribidi/releases/download/v1.0.5/fribidi-1.0.5.tar.bz2
tar xzpf fribid*
cd fribid*/
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-silent-rules --disable-debug --disable-dependency-tracking
make -j $THREADS && make install

## fontconfig fixed ( Last Version 2.13.0 Build Error )
tput bold ; echo "" ; echo "=-> fontconfig 2.12.6 " ; tput sgr0 ; sleep 3
cd ${CMPL}
#wget --no-check-certificate https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.1.tar.bz2
wget --no-check-certificate https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.6.tar.bz2
tar xzpf fontconfig-*
cd fontconfig-*
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-silent-rules --with-add-fonts="/System/Library/Fonts,/Library/Fonts" --disable-shared --enable-static && make && make install

## libass
LastVersion=`wget --no-check-certificate 'https://github.com/libass/libass/releases/' -O- -q | egrep -o -m1 'libass-[0-9\.]+\.tar.gz'`
Number=`echo  $LastVersion | cut -d'-' -f2 | cut -d'.' -f1-3`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate "https://github.com/libass/libass/releases/download/"${Number}/${LastVersion}
tar -zxvf libas*
cd libas*
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## openssl
tput bold ; echo "" ; echo "=-> openssl 1.1.1a " ; tput sgr0 ; sleep 3
cd ${CMPL}
#wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.2p.tar.gz
wget --no-check-certificate https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.1.1a.tar.gz
tar -zxvf openssl*
cd openssl-*/
./Configure --prefix=${TARGET} darwin64-x86_64-cc shared enable-ec_nistp_64_gcc_128 no-ssl2 no-ssl3 no-comp
make depend
make install

## str ( Require openssl )
tput bold ; echo "" ; echo "=-> str git " ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone --depth 1 https://github.com/Haivision/srt.git
cd srt/
cmake -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_SHARED="OFF" -DENABLE_C_DEPS="ON"
make -j $THREADS && make install

## snappy
tput bold ; echo ; echo "=-> snappy git " ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://github.com/google/snappy
cd snappy
mkdir build && cd build
cmake ../ -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_SHARED="OFF" -DENABLE_C_DEPS="ON"
make -j $THREADS && make install



#-> AUDIO

## openal-soft
tput bold ; echo "" ; echo "=-> openal-soft git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://github.com/kcat/openal-soft
cd openal-soft*
cmake -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC .
make -j $THREADS && make install

# opencore-amr
tput bold ; echo "" ; echo "=-> opencore-amr" ; tput sgr0 ; sleep 3
cd ${CMPL}
curl -O http://freefr.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.3.tar.gz
tar -zxvf /Volumes/Ramdisk/compile/opencore-amr-0.1.3.tar.gz
cd opencore-amr-0.1.3
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## opus - Replace speex
LastVersion=`wget --no-check-certificate 'http://downloads.xiph.org/releases/opus/' -O- -q | egrep -o 'opus-1.[0-9\.]+\.[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'http://downloads.xiph.org/releases/opus/'${LastVersion}
tar -zxvf opus-*
cd opus-*
./configure --prefix=${TARGET} --disable-shared --enable-static 
make -j $THREADS && make install

## ogg
LastVersion=`wget --no-check-certificate 'http://downloads.xiph.org/releases/ogg/' -O- -q | egrep -o 'libogg-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'http://downloads.xiph.org/releases/ogg/'${LastVersion}
tar -zxvf libogg-*
cd libogg-*
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## Theora git - Require autoconf automake libtool
tput bold ; echo "" ; echo "=-> theora git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://git.xiph.org/theora.git
cd theora
./autogen.sh
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --with-vorbis-libraries=${TARGET}/lib --with-vorbis-includes=${TARGET}/include/ --enable-static --disable-shared
make -j $THREADS && make install

## vorbis
LastVersion=`wget --no-check-certificate 'http://downloads.xiph.org/releases/vorbis/' -O- -q | egrep -o 'libvorbis-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'http://downloads.xiph.org/releases/vorbis/'${LastVersion}
tar -zxvf libvorbis-*
cd libvorbis-*
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=/Volumes/Ramdisk/sw/include/ --enable-static --disable-shared && make -j $THREADS && make install

## lame git
tput bold ; echo "" ; echo "=-> lame git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://github.com/rbrito/lame.git
cd lam*
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## TwoLame - optimised MPEG Audio Layer 2
LastVersion=`wget --no-check-certificate 'http://www.twolame.org' -O- -q | egrep -o 'twolame-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'http://downloads.sourceforge.net/twolame/'${LastVersion}
tar -zxvf twolame-*
cd twolame-*
./configure --prefix=${TARGET} --enable-static --enable-shared=no && make -j $THREADS && make install

##+ fdk-aac
#LastVersion=`wget --no-check-certificate 'https://kent.dl.sourceforge.net/project/opencore-amr/fdk-aac/' -O- -q | egrep -o 'fdk-aac-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> fdk-aac" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate "https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-0.1.6.tar.gz"
tar -zxvf fdk-aac-*
cd fdk*
./configure --disable-dependency-tracking --prefix=${TARGET} --enable-static --enable-shared=no && make -j $THREADS && make install

## flac
sleep 3 ; LastVersion=`wget --no-check-certificate 'http://downloads.xiph.org/releases/flac/' -O- -q | egrep -o 'flac-[0-9\.]+\.tar.xz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget --no-check-certificate 'http://downloads.xiph.org/releases/flac/'${LastVersion}
tar -xJf flac-*
cd flac-*
./configure --prefix=${TARGET} --disable-asm-optimizations --disable-xmms-plugin --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --enable-static --disable-shared
make -j $THREADS && make install

## gsm
tput bold ; echo "" ; echo "=-> libgsm 1.0.18" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate 'http://www.quut.com/gsm/gsm-1.0.18.tar.gz'
tar -zxvf gsm*
cd gsm*
mkdir -p ${TARGET}/man/man3
mkdir -p ${TARGET}/man/man1
mkdir -p ${TARGET}/include/gsm
perl -p -i -e "s#^INSTALL_ROOT.*#INSTALL_ROOT = $TARGET#g" Makefile
perl -p -i -e "s#_ROOT\)/inc#_ROOT\)/include#g" Makefile
sed "/GSM_INSTALL_INC/s/include/include\/gsm/g" Makefile > Makefile.new
mv Makefile.new Makefile
make -j $THREADS && make install




#-> VIDEO

## libvpx git
tput bold ; echo "" ; echo "=-> vpx git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://github.com/webmproject/libvpx.git
cd libvp*
./configure --prefix=${TARGET} --enable-vp8 --enable-postproc --enable-vp9-postproc --enable-vp9-highbitdepth --disable-examples --disable-docs --enable-multi-res-encoding --enable-unit-tests --disable-shared
make -j $THREADS && make install

## webp
tput bold ; echo "" ; echo "=-> webp 1.0.1" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.0.1.tar.gz
tar -zxvf libweb*
cd libweb*
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-gif --disable-gl --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux && make -j $THREADS && make install

## openjpeg
tput bold ; echo "" ; echo "=-> openjpeg 2.3.0" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate https://github.com/uclouvain/openjpeg/archive/v2.3.0.tar.gz
tar -zxvf v.2.3.0*
cd openjpeg*/
cmake /Volumes/Ramdisk/compile/aom -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC
make -j $THREADS && make install

## av1 git
tput bold ; echo "" ; echo "=-> av1 git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://aomedia.googlesource.com/aom
cd aom
mkdir aom_build
cd aom_build
cmake /Volumes/Ramdisk/compile/aom -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC
make -j $THREADS && make install

## xvid
tput bold ; echo "" ; echo "=-> XviD 1.3.5" ; tput sgr0 ; sleep 3
cd ${CMPL}
curl -O http://downloads.xvid.org/downloads/xvidcore-1.3.5.tar.gz
tar -zxvf xvidcore-*
cd xvidcore
cd build/generic
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-assembly && make -j $THREADS && make install

## openh264
tput bold ; echo ; echo "=-> openH264 1.8.0" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate https://github.com/cisco/openh264/archive/v1.8.0.tar.gz 
tar -zxvf v1.8.0.tar.gz
cd openh264-1.8.0
make -j $THREADS install-static PREFIX=${TARGET}

## x264 8-10bit git - Require nasm
tput bold ; echo "" ; echo "=-> x264 8-10bit git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix=${TARGET} --enable-static --bit-depth=all --chroma-format=all && make -j $THREADS && make install && make install

## x265 8-10-12bit - Require wget, cmake, yasm, nasm, libtool
LastVersion=`wget --no-check-certificate 'https://bitbucket.org/multicoreware/x265/downloads/' -O- -q | egrep -o 'x265_[0-9\.]+\.[0-9\.]+\.tar.gz' | head -1`
tput bold ; echo "" ; echo "=-> "${LastVersion}" 8-10-12bit" ; tput sgr0 ; sleep 3
cd ${CMPL}
wget --no-check-certificate https://bitbucket.org/multicoreware/x265/downloads/${LastVersion}
tar -zxvf x265*
cd x265*/source/
mkdir -p 8bit 10bit 12bit

cd 12bit
cmake ../../../x265*/source -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DMAIN12=ON
make -j $THREADS ${MAKEFLAGS}

cd ../10bit
cmake ../../../x265*/source -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF
make -j $THREADS ${MAKEFLAGS}

cd ../8bit
ln -sf ../10bit/libx265.a libx265_main10.a
ln -sf ../12bit/libx265.a libx265_main12.a
cmake ../../../x265*/source -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_SHARED=NO -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON -DLINKED_12BIT=ON
make -j $THREADS ${MAKEFLAGS}

# rename the 8bit library, then combine all three into libx265.a
mv libx265.a libx265_main.a
# Mac/BSD libtool
libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a
make install

# Flags OSX
export LDFLAGS="-L${TARGET}/lib -Wl,-framework,OpenAL"
export CPPFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL"
export CFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL"

# Purge .dylib
tput bold ; echo "" ; echo "=-> Purge .dylib" ; tput sgr0 ; sleep 3
rm -vfr $TARGET/lib/*.dylib

## FFmpeg
tput bold ; echo "" ; echo "=-> FFmpeg git" ; tput sgr0 ; sleep 3
cd ${CMPL}
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpe*/
./configure --extra-version=adam-`date +"%m-%d-%y"` --arch=x86_64 --cc=/usr/bin/clang \
 --enable-hardcoded-tables --enable-pthreads --enable-postproc --enable-runtime-cpudetect \
 --pkg_config='pkg-config --static' --enable-nonfree --enable-gpl --enable-version3 --prefix=${TARGET} \
 --disable-ffplay --disable-ffprobe --disable-debug --disable-doc --enable-avfilter --enable-avisynth --enable-filters \
 --enable-libopus --enable-libvorbis --enable-libtheora --enable-libmp3lame --enable-libfdk-aac \
 --enable-libtwolame --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libgsm \
 --enable-libxvid --enable-libopenh264 --enable-libx264 --enable-libx265 --enable-libvpx --enable-libaom \
 --enable-fontconfig --enable-libfreetype --enable-libfribidi --enable-libass --enable-libsrt \
 --enable-libbluray --enable-bzlib --enable-zlib --enable-libsnappy --enable-libwebp --enable-libopenjpeg \
 --enable-opengl --enable-opencl --enable-openal --enable-openssl

## Fix Illegall Instruction 4 By Remove "--extra-cflags=-march=native" on Core2Duo
## Fix CLOCK_GETTIME on OS Before 10.12 & iOS 10
 sed -i -- 's/HAVE_CLOCK_GETTIME 1/HAVE_CLOCK_GETTIME 0/g' config.h

 make -j $THREADS && make install

## Check Static
tput bold ; echo "" ; echo "=-> Check Static FFmpeg" ; tput sgr0 ; sleep 3
otool -L /Volumes/Ramdisk/sw/bin/ffmpeg
cp /Volumes/Ramdisk/sw/bin/ffmpeg ~/Desktop/ffmpeg

## End Time
Time="$(echo 'obase=60;'$SECONDS | bc | sed 's/ /:/g' | cut -c 2-)"
tput bold ; echo "" ; echo "=-> End in $Time" ; tput sgr0
