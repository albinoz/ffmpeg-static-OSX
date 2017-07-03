# adam | 2014-17
# Download && Build Last Static ffmpeg
# 10.9 < 10.12

clear
tput bold ; echo "adam | 2014-16" ; tput sgr0
tput bold ; echo "Download && Build Last FFmpeg Static" ; tput sgr0

# Check Xcode
tput bold ; echo "" ; echo "=-> Xcode Check" ; tput sgr0
if ls /Applications/ | grep 'Xcode' ; then echo "Xcode is Installed" ; else echo "Please Install Xcode" ; /usr/bin/open https://developer.apple.com/xcode/download/ ; exit ; fi

# Check Xcode CLI (10.9 minimum)
tput bold ; echo "" ; echo "=-> Xcode CLI Check" ; tput sgr0
if pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version ; then echo "Xcode-CLI is Installed" ; else echo "Please Install Xcode-CLI" ; xcode-select --install ; exit ; fi

# Homebrew Check
tput bold ; echo "" ; echo "=-> Homebrew Check" ; tput sgr0
if ls /usr/local/bin/brew ; then echo "HomeBrew is Installed" ; else echo "Installing HomeBrew" ; /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ; fi

# Homebrew Update
tput bold ; echo "" ; echo "=-> Homebrew Update" ; tput sgr0
brew update ; brew upgrade ; brew cleanup ; brew prune ; brew doctor

# Homebrew Static Config
tput bold ; echo "" ; echo "=-> Homebrew Static Config" ; tput sgr0
brew install git wget cmake hg autoconf automake libtool ant nasm
brew uninstall ffmpeg
brew uninstall lame
brew uninstall x264
brew uninstall x265
brew uninstall xvid
brew uninstall vpx
brew uninstall faac
brew uninstall yasm
brew uninstall pkg-config
#brew uninstall libpng
brew uninstall --ignore-dependencies libpng

# JAVA Check
#tput bold ; echo "" ; echo "=-> JAVA Check" ; tput sgr0
#if ls /Library/Java/JavaVirtualMachines/jdk1.8* ; then echo "Java is Installed" ; else brew tap caskroom/cask ; brew install brew-cask ;  brew cask install --force java ; fi

# Eject Ramdisk
tput bold ; echo "" ; echo "=-> eject Ramdisk" ; tput sgr0
if Ramdisk=`df | grep /Volumes/ | grep Ramdisk | cut -d' ' -f1` ; then diskutil eject $Ramdisk ; fi

# Made Ramdisk
tput bold ; echo "" ; echo "=-> made Ramdisk" ; tput sgr0
DISK_ID=$(hdid -nomount ram://3000000)
newfs_hfs -v Ramdisk ${DISK_ID}
diskutil mount ${DISK_ID}

# Builder
export CC=clang
# Paths
TARGET="/Volumes/Ramdisk/sw"
CMPL="/Volumes/Ramdisk/compile"
export PATH=${TARGET}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
# Flags
export LDFLAGS="-L${TARGET}/lib -Wl,-framework,OpenAL -framework CoreFoundation -framework Carbon"
export CPPFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL"
export CFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL -framework CoreFoundation -framework Carbon"
# CPU(s)
THREADS=`sysctl -n hw.ncpu`

mkdir ${TARGET}
mkdir ${CMPL}

# Exit on Error
set -o errexit

## pkg-config
LastVersion=`wget 'https://pkg-config.freedesktop.org/releases/' -O- -q | egrep -o 'pkg-config-0.29[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL} || exit 1
wget 'https://pkg-config.freedesktop.org/releases/'${LastVersion}
tar -zxvf pkg-config-*
cd pkg-config-*
./configure --prefix=${TARGET} --with-pc-path=${TARGET}/lib/pkgconfig --with-internal-glib && make -j $THREADS && make install

## Yasm
LastVersion=`wget 'http://www.tortall.net/projects/yasm/releases/' -O- -q | egrep -o 'yasm-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'http://www.tortall.net/projects/yasm/releases/'${LastVersion}
tar -zxvf /Volumes/Ramdisk/compile/yasm-*
cd yasm-*
./configure --prefix=${TARGET} && make -j $THREADS && make install

# opencore-amr
tput bold ; echo "" ; echo "=-> opencore-amr" ; tput sgr0
cd ${CMPL}
curl -O http://freefr.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.3.tar.gz
tar -zxvf /Volumes/Ramdisk/compile/opencore-amr-0.1.3.tar.gz
cd opencore-amr-0.1.3
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## openal-soft
LastVersion=`wget 'http://kcat.strangesoft.net/openal-releases/' -O- -q | egrep -o 'openal-soft-[0-9\.]+\.tar.bz2' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'http://kcat.strangesoft.net/openal-releases/'${LastVersion}
tar xjpf openal-soft-*
cd openal-soft*
cmake -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC .
make -j $THREADS && make install

## faad
tput bold ; echo "" ; echo "=-> faad" ; tput sgr0
cd ${CMPL}
wget "http://downloads.sourceforge.net/faac/faad2-2.7.tar.gz"
tar -zxvf faad2-2.7.tar.gz
cd faad2-2.7
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

## opus - Replace speex
LastVersion=`wget 'http://downloads.xiph.org/releases/opus/' -O- -q | egrep -o 'opus-1.1[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'http://downloads.xiph.org/releases/opus/'${LastVersion}
tar -zxvf opus-*
cd opus-*
./configure --prefix=${TARGET} --disable-shared --enable-static 
make -j $THREADS && make install

## ogg
LastVersion=`wget 'http://downloads.xiph.org/releases/ogg/' -O- -q | egrep -o 'libogg-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'http://downloads.xiph.org/releases/ogg/'${LastVersion}
tar -zxvf libogg-*
cd libogg-*
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## Theora - Require autoconf automake libtool
tput bold ; echo "" ; echo "=-> theora git" ; tput sgr0
cd ${CMPL}
git clone https://git.xiph.org/theora.git
cd theora
./autogen.sh
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --with-vorbis-libraries=${TARGET}/lib --with-vorbis-includes=${TARGET}/include/ --enable-static --disable-shared
make -j $THREADS && make install

## vorbis
LastVersion=`wget 'http://downloads.xiph.org/releases/vorbis/' -O- -q | egrep -o 'libvorbis-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'http://downloads.xiph.org/releases/vorbis/'${LastVersion}
tar -zxvf libvorbis-*
cd libvorbis-*
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=/Volumes/Ramdisk/sw/include/ --enable-static --disable-shared && make -j $THREADS && make install

## lame
tput bold ; echo "" ; echo "=-> lame git" ; tput sgr0
cd ${CMPL}
git clone https://github.com/rbrito/lame.git
cd lam*
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

##+ faac
tput bold ; echo "" ; echo "=-> faac" ; tput sgr0
cd ${CMPL}
curl -O http://freefr.dl.sourceforge.net/project/faac/faac-src/faac-1.28/faac-1.28.tar.gz
tar -zxvf faac-1.28.tar.gz
cd faac*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

##+ fdk-aac
LastVersion=`wget 'https://kent.dl.sourceforge.net/project/opencore-amr/fdk-aac/' -O- -q | egrep -o 'fdk-aac-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget https://sourceforge.net/projects/opencore-amr/files/fdk-aac/${LastVersion}/download/ -O ${LastVersion}
tar -zxvf fdk-aac-*
cd fdk*
./configure --prefix=${TARGET} --enable-static --enable-shared=no && make -j $THREADS && make install

## flac
LastVersion=`wget 'http://downloads.xiph.org/releases/flac/' -O- -q | egrep -o 'flac-[0-9\.]+\.tar.xz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'http://downloads.xiph.org/releases/flac/'${LastVersion}
tar -xJf flac-*
cd flac-*
./configure --prefix=${TARGET} --disable-asm-optimizations --disable-xmms-plugin --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --enable-static --disable-shared
make -j $THREADS && make install

## libvpx
tput bold ; echo "" ; echo "=-> vpx git" ; tput sgr0
cd ${CMPL}
git clone https://github.com/webmproject/libvpx.git
cd libvp*
./configure --prefix=${TARGET} --enable-postproc --enable-vp9-postproc --enable-multi-res-encoding --enable-unit-tests --disable-shared && make -j $THREADS && make install

## xvid
tput bold ; echo "" ; echo "=-> xvid" ; tput sgr0
cd ${CMPL}
curl -O http://downloads.xvid.org/downloads/xvidcore-1.3.4.tar.gz
tar -zxvf xvidcore-1.3.4.tar.gz
cd xvidcore
cd build/generic
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install
rm ${TARGET}/lib/libxvidcore.4.dylib

## x264
tput bold ; echo "" ; echo "=-> x264 git" ; tput sgr0
cd ${CMPL}
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix=${TARGET} --enable-static && make -j $THREADS && make install && make install

## x265 - require hg & cmake
tput bold ; echo "" ; echo "=-> x265 hg" ; tput sgr0
cd ${CMPL}
hg clone https://bitbucket.org/multicoreware/x265
cd x265
cd source
cmake -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_SHARED=NO .
make -j $THREADS && make install

## gsm
tput bold ; echo "" ; echo "=-> gsm" ; tput sgr0
cd ${CMPL}
curl -O http://libgsm.sourcearchive.com/downloads/1.0.13-4/libgsm_1.0.13.orig.tar.gz
tar -zxvf libgsm_1.0.13.orig.tar.gz
cd gsm-*
mkdir -p ${TARGET}/man/man3
mkdir -p ${TARGET}/man/man1
mkdir -p ${TARGET}/include/gsm
perl -p -i -e "s#^INSTALL_ROOT.*#INSTALL_ROOT = $TARGET#g" Makefile
perl -p -i -e "s#_ROOT\)/inc#_ROOT\)/include#g" Makefile
sed "/GSM_INSTALL_INC/s/include/include\/gsm/g" Makefile > Makefile.new
mv Makefile.new Makefile
make -j $THREADS && make install

## freetype
LastVersion=`wget 'http://download.savannah.gnu.org/releases/freetype/' -O- -q | egrep -o 'freetype-2.6.[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'http://download.savannah.gnu.org/releases/freetype/'${LastVersion}
tar xzpf freetype-*
cd freetype-*
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## fribidi
LastVersion=`wget 'http://fribidi.org/download/' -O- -q | egrep -o 'fribidi-[0-9\.]+\.tar.bz2' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL} 
wget 'http://fribidi.org/download/'${LastVersion}
tar xjpf fribidi-*
cd fribidi-*
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install
 
## fontconfig
LastVersion=`wget 'https://www.freedesktop.org/software/fontconfig/release/' -O- -q | egrep -o 'fontconfig-[0-9\.]+\.tar.gz' | tail -1`
tput bold ; echo "" ; echo "=-> "${LastVersion} ; tput sgr0
cd ${CMPL}
wget 'https://www.freedesktop.org/software/fontconfig/release/'${LastVersion}
tar xzpf fontconfig-*
cd fontconfig-*
./configure --prefix=${TARGET} --with-add-fonts=/Library/Fonts,~/Library/Fonts --disable-shared --enable-static && make -j $THREADS && make install

## libass
tput bold ; echo "" ; echo "=-> libass git" ; tput sgr0
cd ${CMPL}
#git clone https://github.com/libass/libass.git
wget "https://github.com/libass/libass/releases/download/0.13.7/libass-0.13.7.tar.gz"
tar -zxvf libas*
cd libas*
#./autogen.sh
./configure --prefix=${TARGET} --disable-shared --enable-static && make -j $THREADS && make install

## libpng git
tput bold ; echo "" ; echo "=-> libpng git" ; tput sgr0
cd ${CMPL}
git clone https://github.com/glennrp/libpng.git
cd libpng
./autogen.sh
./configure --prefix=${TARGET} --enable-static --disable-shared
make -j $THREADS && make install

## bzip
tput bold ; echo "" ; echo "=-> bzip" ; tput sgr0
cd ${CMPL}
wget "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
tar xzpf bzip2*
cd bzip2-1.0.6
make -j $THREADS && make install PREFIX=${TARGET}

## libudfread - bluray required ?
#tput bold ; echo "" ; echo "=-> libudfread git" ; tput sgr0
#cd ${CMPL}
#git clone https://github.com/vlc-mirror/libudfread.git
#cd libud*
#./bootstrap
#./configure --prefix=${TARGET} --disable-shared
#make -j $THREADS && make install

## bluray - Require JAVA-SDK & ANT & libudfread
#JAVAV=`ls /Library/Java/JavaVirtualMachines/ | tail -1`
#export JAVA_HOME="/Library/Java/JavaVirtualMachines/$JAVAV/Contents/Home"
#tput bold ; echo "" ; echo "=-> libbluray git" ; tput sgr0
#cd ${CMPL}
#git clone http://git.videolan.org/git/libbluray.git
#cd libblura*
#./bootstrap
#./configure --prefix=${TARGET} --disable-shared --disable-dependency-tracking --build x86_64 --disable-doxygen-dot --without-libxml2 --without-fontconfig --without-freetype --disable-udf
#cp -vpfr /Volumes/Ramdisk/compile/libblura*/jni/darwin/jni_md.h /Volumes/Ramdisk/compile/libblura*/jni
#make -j $THREADS && make install

## ffmpeg
tput bold ; echo "" ; echo "=-> ffmpeg" ; tput sgr0
cd ${CMPL}
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --extra-version=adam-`date +"%m-%d-%y"` \
 --pkg_config='pkg-config --static' --prefix=${TARGET} \
 --extra-cflags=-march=native --as=yasm --enable-nonfree --enable-gpl --enable-version3 \
 --enable-hardcoded-tables --enable-pthreads --enable-postproc --enable-runtime-cpudetect --arch=x86_64 \
 --enable-opengl --enable-opencl --disable-ffplay --disable-ffserver --disable-ffprobe --disable-doc \
 --enable-openal --enable-libmp3lame --enable-libfdk-aac \
 --enable-libopus --enable-libvorbis --enable-libtheora \
 --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libgsm \
 --enable-libxvid --enable-libx264 --enable-libx265 --enable-libvpx \
 --enable-avfilter --enable-filters --enable-libass --enable-fontconfig --enable-libfreetype \
 --enable-bzlib --enable-zlib --disable-sdl
 make -j $THREADS && make install

## mplayer
#tput bold ; echo "" ; echo "=-> mplayer" ; tput sgr0
#cd ${CMPL}
#svn checkout svn://svn.mplayerhq.hu/mplayer/trunk mplayer
#mv /Volumes/Ramdisk/compile/ffmpeg /Volumes/Ramdisk/compile/mplayer/ffmpeg
#cd mplayer
#./configure --prefix=${TARGET} --extra-cflags="-I${TARGET}/include/" --extra-ldflags="-L${TARGET}/lib"
#make -j $THREADS && make install

## Check Static and Report Error
tput bold ; echo "" ; echo "=-> Check Static ffmpeg" ; tput sgr0
otool -L /Volumes/Ramdisk/sw/bin/ffmpeg | grep -v : > /tmp/Static
if cat /tmp/Static | grep  "opt" | grep  "usr/local" ;  then tput bold ; echo "" ; echo "x-> Error Bad Link Found " ; tput sgr0 ; else otool -L /Volumes/Ramdisk/sw/bin/ffmpeg ; tput bold ; echo "" ; echo "=-> Static ffmpeg Builded Succefully" ; tput sgr0 ; cp /Volumes/Ramdisk/sw/bin/ffmpeg ~/Desktop/ffmpeg  ; fi
#tput bold ; echo "" ; echo "=-> Check Static mplayer" ; tput sgr0
#otool -L /Volumes/Ramdisk/sw/bin/mplayer

## End Time
Time="$(echo 'obase=60;'$SECONDS | bc | sed 's/ /:/g' | cut -c 2-)"
tput bold ; echo "" ; echo "=-> End in $Time" ; tput sgr0
