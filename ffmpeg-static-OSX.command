#!/bin/bash
clear
( exec &> >(while read -r line; do echo "$(date +"[%Y-%m-%d %H:%M:%S]") $line"; done;) #_Date to Every Line

# Variables
LANG=$(defaults read -g AppleLocale | cut -d'_' -f1)
Uptime=$(system_profiler SPSoftwareDataType | grep "Time since boot:" | cut -d ':' -f2 | cut -d ' ' -f2-9)
SytemVersion=$(system_profiler SPSoftwareDataType | grep "System Version:" | cut -d ':' -f2 | cut -d ' ' -f2-9)
OSXMajor=$(sw_vers -productVersion | cut -d'.' -f1)

# About
tput bold ; echo "adam | 2014 < 2023-12-02" ; tput sgr0
tput bold ; echo "Download & Build Last Static FFmpeg" ; tput sgr0

# Infos
echo; echo "Date:" `date +"%Y/%m/%d %T"`
echo "User:" "$(hostname -s)" - "$(whoami)" - "$LANG"

echo "Uptime:" "$Uptime"
echo "Hardware:" "$(system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d ':' -f2 | tr -d ' ') | $SytemVersion\
 |$(system_profiler SPHardwareDataType | grep Memory | cut -d ':' -f2)\
 |$(system_profiler SPHardwareDataType | grep "Number of Processors" | cut -d ':' -f2)x\
$(system_profiler SPHardwareDataType | grep Cores | cut -d ':' -f2 | tr -d ' ') \
$(system_profiler SPHardwareDataType | grep Speed | cut -d ':' -f2 | tr -d ' ')"

# Check Processor & macOS Version Support
tput bold ; echo ; echo '♻️  ' 'Check Processor & macOS Version Support' ; tput sgr0
Processor=$(system_profiler SPHardwareDataType | grep Intel | cut -d ':' -f2 |  cut -d ' ' -f2-10)
if echo "$Processor" | grep Intel >/dev/null 2>&1 ; then echo "$Processor" Processor Supported ; else echo "$Processor" Processor not Supported \
; echo Only Intel Processor Supported for this Build \
; exit ; fi
if [ "$OSXMajor" -ge 11 ] ; then echo "$SytemVersion" Supported ; else echo "$SytemVersion" not Supported \
; echo "Only 3 Last macOS is Supported ( By Apple and HomeBrew )" \
; exit ; fi

#_ Check Xcode CLI Install
tput bold ; echo ; echo '♻️  ' Check Xcode CLI Install ; tput sgr0
if ls /Library/Developer/CommandLineTools >/dev/null 2>&1 ; then echo "Xcode CLI AllReady Installed" ; else echo "Xcode CLI Install" ; xcode-select --install
while pgrep 'Install Command Line Developer Tools' >/dev/null ; do sleep 2 ; done
if ls /Library/Developer/CommandLineTools >/dev/null 2>&1 ; then echo "Xcode CLI Was SucessFully Installed" ; else echo "Xcode CLI Was NOT Installed" ; exit ; fi ; fi

#_ Check Homebrew Install
tput bold ; echo ; echo '♻️  ' Check Homebrew Install ; tput sgr0
if ls /*/*/*/brew >/dev/null ; then tput sgr0 ; echo "HomeBrew AllReady Installed" ; else tput bold ; echo "Installing HomeBrew" ; tput sgr0 ; export HOMEBREW_NO_INSTALL_FROM_API=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" ; fi

#_ Check Homebrew Update
tput bold ; echo ; echo '♻️  ' Check Homebrew Update ; tput sgr0
/*/*/*/brew cleanup ; /*/*/*/brew doctor ; /*/*/*/brew update ; /*/*/*/brew upgrade

#_ Check Homebrew Config
tput bold ; echo ; echo '♻️  ' Check Homebrew Config ; tput sgr0
/*/*/*/brew install git wget cmake autoconf automake nasm libtool ninja meson pkg-config rtmpdump rust cargo-c jpeg libtiff python3

#_ Check Miminum Requirement Build Time
Time="$(echo 'obase=60;'$SECONDS | bc | sed 's/ /:/g' | cut -c 2-)"
tput bold ; echo ; echo '⏳  ' Minimum Requirement Build in "$Time"s ; tput sgr0

#_ Made RamDisk
if diskutil list | grep RamDisk ; then
echo RamDisk Exist
else
# Minimum RamDisk
tput bold ; echo ; echo '💾 ' Made 2Go RamDisk ; tput sgr0
diskutil erasevolume HFS+ 'RamDisk' $(hdiutil attach -nomount ram://4000000)
fi

#_ CPU & PATHS & ERROR
THREADS=$(sysctl -n hw.ncpu)
TARGET="/Volumes/RamDisk/sw"
CMPL="/Volumes/RamDisk/compile"
export PATH="${TARGET}"/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/include:/usr/local/opt:/usr/local/Cellar:/usr/local/lib:/usr/local/share:/usr/local/etc
mdutil -i off /Volumes/RamDisk

#_ Make RamDisk Directories
mkdir ${TARGET}
mkdir ${CMPL}
rm -fr /Volumes/RamDisk/compile/*

#-> BASE
tput bold ; echo ; echo ; echo '⚙️  ' Base Builds ; tput sgr0

#_ xz
tput bold ; echo ; echo '📍 ' xz git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "xz" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://git.tukaani.org/xz.git
cd xz
./autogen.sh
./configure --prefix=${TARGET} --enable-static --disable-shared --disable-docs --disable-examples
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "xz" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ libexpat
tput bold ; echo ; echo '📍 ' libexpat git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "expat" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/libexpat/libexpat.git libexpat
cd libexpat/expat
./buildconf.sh
./configure --prefix=${TARGET} CPPFLAGS=-DXML_LARGE_SIZE --enable-static
make -j "$THREADS" && make install DESTDIR=/
if find /Volumes/RamDisk/sw/ | grep "expat" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ libiconv
LastVersion=$(wget --no-check-certificate 'https://ftp.gnu.org/pub/gnu/libiconv/' -O- -q | grep -Eo 'libiconv-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "iconv" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://ftp.gnu.org/pub/gnu/libiconv/'"$LastVersion"
tar -zxvf libiconv*
cd libiconv*/
./configure --prefix=${TARGET} --with-iconv=${TARGET} --enable-static --enable-extra-encodings
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "iconv" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ pkg-config
LastVersion=$(wget --no-check-certificate 'https://pkg-config.freedesktop.org/releases/' -O- -q | grep -Eo 'pkg-config-0.29[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "pkg-config" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://pkg-config.freedesktop.org/releases/'"$LastVersion"
tar -zxvf pkg-config-*
cd pkg-config-*/
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-debug --disable-host-tool --with-internal-glib
make -j "$THREADS" && make check && make install
if find /Volumes/RamDisk/sw/ | grep "pkg-config" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ libpng * Required from freetype & webp
tput bold ; echo ; echo '📍 ' libpng git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "libpng" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/glennrp/libpng.git
cd libpn*/
./configure --prefix=${TARGET} --enable-static --disable-dependency-tracking --disable-silent-rules
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "libpng" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ openjpeg
tput bold ; echo ; echo '📍 ' openjpeg git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "openjpeg" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/uclouvain/openjpeg.git
cd openjpeg
mkdir build && cd build
cmake -G "Ninja" .. -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC
ninja && ninja install
if find /Volumes/RamDisk/sw/ | grep "openjpeg" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ gettext - Requirement for fontconfig, fribidi
LastVersion=$(wget --no-check-certificate 'https://ftp.gnu.org/pub/gnu/gettext/' -O- -q | grep -Eo 'gettext-[0-500\.]+\.[0-500\.]+\.[0-500\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "gettext" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://ftp.gnu.org/pub/gnu/gettext/'"$LastVersion"
tar -zxvf gettex*
cd gettext-*/
./configure --prefix=${TARGET} --disable-silent-rules --with-included-glib \
 --with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --disable-java --disable-csharp \
 --disable-shared --enable-static --without-git --without-cvs --without-xz --with-included-gettext
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "gettext" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ Yasm
LastVersion=$(wget --no-check-certificate 'https://www.tortall.net/projects/yasm/releases/' -O- -q | grep -Eo 'yasm-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "yasm" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://www.tortall.net/projects/yasm/releases/'"$LastVersion"
tar -zxvf /Volumes/RamDisk/compile/yasm-*
cd yasm-*/
./configure --prefix=${TARGET} && make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "yasm" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ bzip2
tput bold ; echo ; echo '📍 ' bzip2 git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "bzip" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone git://sourceware.org/git/bzip2.git bzip2
cd bzip2
make -j "$THREADS" && make install PREFIX=${TARGET}
if find /Volumes/RamDisk/sw/ | grep "bzip" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ libsdl2
LastVersion=$(wget --no-check-certificate 'https://www.libsdl.org/release/' -O- -q | grep -Eo 'SDL2-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "SDL2" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://www.libsdl.org/release/'"$LastVersion"
tar xvf SDL2-*.tar.gz
cd SDL2*/
./autogen.sh
./configure --prefix=${TARGET} --enable-static --without-x --enable-hidapi
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "SDL2" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ libudfread git
tput bold ; echo ; echo '📍 ' libudfread git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "fread" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://code.videolan.org/videolan/libudfread.git
cd libud*/
./bootstrap
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "fread" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
fi

#_ bluray git
tput bold ; echo ; echo '📍 ' libbluray git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "libbluray" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://code.videolan.org/videolan/libbluray.git
cd libblura*/
./bootstrap
./configure --prefix=${TARGET} --disable-shared --disable-dependency-tracking --disable-silent-rules --without-libxml2 --without-freetype --disable-doxygen-doc --disable-bdjava-jar
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "libbluray" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi


#-> SUBTITLES
tput bold ; echo ; echo ; echo '⚙️  ' Subtitles Builds ; tput sgr0

#_ freetype
LastVersion=$(wget --no-check-certificate 'https://download.savannah.gnu.org/releases/freetype/' -O- -q | grep -Eo 'freetype-[0-500\.]+\.[0-500\.]+\.[0-500\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "freetype" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://download.savannah.gnu.org/releases/freetype/'"$LastVersion"
tar xzpf freetype-*
cd freetype-*/
pip3 install docwriter
./configure --prefix=${TARGET} --disable-shared --enable-static --enable-freetype-config
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "freetype" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ fribidi
tput bold ; echo ; echo '📍 ' fribidi 1.0.13 ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "fribidi" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate https://github.com/fribidi/fribidi/releases/download/v1.0.13/fribidi-1.0.13.tar.xz
tar -xJf fribid*
cd fribid*/
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-silent-rules --disable-debug --disable-dependency-tracking
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "fribidi" >/dev/null ; then  tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ fontconfig
LastVersion=$(wget --no-check-certificate 'https://www.freedesktop.org/software/fontconfig/release/' -O- -q | grep -Eo 'fontconfig-[0-500\.]+.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "fontconfig" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://www.freedesktop.org/software/fontconfig/release/'"$LastVersion"
tar xzpf fontconfig-*
cd fontconfig-*/
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-silent-rules --with-add-fonts="/System/Library/Fonts,/Library/Fonts" --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "fontconfig" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ harfbuzz git
tput bold ; echo ; echo '📍 ' harfbuzz git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "harfbuzz" >/dev/null ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/harfbuzz/harfbuzz.git
cd harfbuzz
./autogen.sh
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "harfbuzz" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ libass git ( require harfbuzz )
tput bold ; echo ; echo '📍 ' libass git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "libass" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/libass/libass.git
cd libas*/
./autogen.sh
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "libass" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ openssl
LastVersion=$(wget --no-check-certificate 'https://www.openssl.org/source/' -O- -q | grep -Eo 'openssl-[0-9\.]+\.[0-9\.]+\.[0-9\.].tar.gz' | sort | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find find /Volumes/RamDisk/sw/bin | grep "openssl" | grep "openssl" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate https://www.openssl.org/source/"$LastVersion"
tar -zxvf openssl*
cd openssl-*/
./Configure --prefix=${TARGET} -openssldir=${TARGET}/usr/local/etc/openssl no-ssl3 no-zlib enable-cms
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/bin | grep "openssl" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ srt ( Require openssl )
tput bold ; echo ; echo '📍 ' srt git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "srt-ffplay" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone --depth 1 https://github.com/Haivision/srt.git
cd srt/
mkdir build && cd build
cmake -G "Ninja" .. -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_C_DEPS=ON -DENABLE_SHARED=OFF -DENABLE_STATIC=ON
ninja && ninja install
if find /Volumes/RamDisk/sw/ | grep "srt-ffplay" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ snappy
tput bold ; echo ; echo '📍 ' snappy git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "snappy" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/google/snappy.git
cd snappy
mkdir build && cd build
cmake -G "Ninja" ../ -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DENABLE_SHARED="OFF" -DENABLE_C_DEPS="ON" -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF
ninja && ninja install
if find /Volumes/RamDisk/sw/ | grep "snappy" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#-> AUDIO
tput bold ; echo ; echo ; echo '⚙️  ' Audio Builds ; tput sgr0

#_ openal-soft
tput bold ; echo ; echo '📍 ' openal-soft git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "openal" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/kcat/openal-soft
cd openal-soft*/
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC -DALSOFT_BACKEND_PORTAUDIO=OFF -DALSOFT_BACKEND_PULSEAUDIO=OFF -DALSOFT_EXAMPLES=OFF -DALSOFT_MIDI_FLUIDSYNTH=OFF
ninja && ninja install
if find /Volumes/RamDisk/sw/ | grep "openal" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ opencore-amr
tput bold ; echo ; echo '📍 ' opencore-amr 0.1.6 ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "amr" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
curl -O https://freefr.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.6.tar.gz
tar -zxvf opencore-amr-*.tar.gz
cd opencore-amr-*/
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "amr" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ opus - Replace speex
LastVersion=$(wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/opus/ -O- -q | grep -Eo 'opus-1.[0-9\.]+\.[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "opus" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/opus/"$LastVersion"
tar -zxvf opus-*
cd opus-*/
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "opus" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ ogg
LastVersion=$(wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/ogg/ -O- -q | grep -Eo 'libogg-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "ogg.pc" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/ogg/"$LastVersion"
tar -zxvf libogg-*
cd libogg-*/
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-dependency-tracking
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "ogg.pc" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ Theora git - Require nf automake libtool
tput bold ; echo ; echo '📍 ' theora git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "theora" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/xiph/theora.git
cd theora
./autogen.sh
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --with-vorbis-libraries=${TARGET}/lib --with-vorbis-includes=${TARGET}/include/ --enable-static --disable-shared
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "theora" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ vorbis
LastVersion=$(wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/vorbis/ -O- -q | grep -Eo 'libvorbis-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "vorbisfile.pc" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate https://ftp.osuosl.org/pub/xiph/releases/vorbis/"$LastVersion"
tar -zxvf libvorbis-*
cd libvorbis-*/
# Patch
sed 's/-force_cpusubtype_ALL//g' configure.ac > configure.ac2
rm configure.ac ; mv configure.ac2 configure.ac
./autogen.sh
./configure --prefix=${TARGET} --disable-dependency-tracking --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=/Volumes/RamDisk/sw/include/ --enable-static --disable-shared
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "vorbisfile.pc" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ lame git
tput bold ; echo ; echo '📍 ' lame git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "lame" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/rbrito/lame.git
cd lam*/
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "lame" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ TwoLame - optimised MPEG Audio Layer 2
LastVersion=$(wget --no-check-certificate 'https://www.twolame.org' -O- -q | grep -Eo 'twolame-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "twolame" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://downloads.sourceforge.net/twolame/'"$LastVersion"
tar -zxvf twolame-*
cd twolame-*/
./configure --prefix=${TARGET} --enable-static --enable-shared=no
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "twolame" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ fdk-aac
tput bold ; echo ; echo '📍 ' fdk-aac git ; tput sgr0
cd ${CMPL} ; sleep 2
if find /Volumes/RamDisk/sw/ | grep "fdk-aac" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
git clone https://github.com/mstorsjo/fdk-aac.git
cd fdk*/
./autogen.sh
./configure --disable-dependency-tracking --prefix=${TARGET} --enable-static --enable-shared=no
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "fdk-aac" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ gsm
LastVersion=$(wget --no-check-certificate 'https://www.quut.com/gsm/' -O- -q | grep -Eo 'gsm-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "gsm" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate 'https://www.quut.com/gsm/'"$LastVersion"
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
if find /Volumes/RamDisk/sw/ | grep "gsm" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ speex
LastVersion=$(wget --no-check-certificate 'https://downloads.us.xiph.org/releases/speex/' -O- -q | grep -Eo 'speex-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "speex" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget https://downloads.us.xiph.org/releases/speex/"$LastVersion"
tar xvf speex-*.tar.gz
cd speex-*/
./configure --prefix=${TARGET} --enable-static --enable-shared=no
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "speex" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi


#-> VIDEO
tput bold ; echo ; echo ; echo '⚙️  ' Video Builds ; tput sgr0

#_ libzimg
tput bold ; echo ; echo '📍 ' libzimg 3.0.5 ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "zimg.pc" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate https://github.com/sekrit-twc/zimg/archive/refs/tags/release-3.0.5.tar.gz
tar xvf release-*.tar.gz
cd zimg-*/
./autogen.sh
./Configure --prefix=${TARGET} --disable-shared --enable-static
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "zimg.pc" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ libvpx git
tput bold ; echo ; echo '📍 ' vpx git ; tput sgr0
cd ${CMPL} ; sleep 2
if find /Volumes/RamDisk/sw/ | grep "vpx" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
git clone https://github.com/webmproject/libvpx.git
cd libvp*/
./configure --prefix=${TARGET} --enable-vp8 --enable-postproc --enable-vp9-postproc --enable-vp9-highbitdepth --disable-examples --disable-docs --enable-multi-res-encoding --disable-unit-tests --enable-pic --disable-shared
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "vpx" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ webp
tput bold ; echo ; echo '📍 ' webp git ; tput sgr0
cd ${CMPL} ; sleep 2
if find /Volumes/RamDisk/sw/ | grep "webp" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
git clone https://chromium.googlesource.com/webm/libwebp
cd libweb*/
./autogen.sh
./configure --prefix=${TARGET} --disable-dependency-tracking --disable-shared --enable-static --disable-gif --disable-gl --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "webp" >/dev/null 2>&1 ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ aom-av1 git
tput bold ; echo ; echo '📍 ' aom-av1 git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "aom" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://aomedia.googlesource.com/aom
cd aom
mkdir aom_build && cd aom_build
cmake -G "Ninja" /Volumes/RamDisk/compile/aom -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DLIBTYPE=STATIC
ninja && ninja install
if find /Volumes/RamDisk/sw/ | grep "aom" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ svt-av1 git
#tput bold ; echo ; echo '📍 ' svt-av1 git ; tput sgr0
#if find /Volumes/RamDisk/sw/ | grep "SvtAv1" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
#cd ${CMPL} ; sleep 2
#git clone --depth=1 https://gitlab.com/AOMediaCodec/SVT-AV1.git
#cd SVT-AV1/Build/
#cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=${TARGET}
#make -j "$THREADS" && make install
#if find /Volumes/RamDisk/sw/ | grep "SvtAv1" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
#rm -fr /Volumes/RamDisk/compile/*
#fi

#_ dav1d git - Require ninja, meson
tput bold ; echo ; echo '📍 ' dav1d git ; tput sgr0
cd ${CMPL} ; sleep 2
if find /Volumes/RamDisk/sw/ | grep "dav1d" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
git clone https://code.videolan.org/videolan/dav1d.git
cd dav1*/
meson --prefix=${TARGET} build --buildtype release --default-library static
ninja install -C build
if find /Volumes/RamDisk/sw/ | grep "dav1d" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ rav1e git - Require rust & cargo
tput bold ; echo ; echo '📍 ' rav1e git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "rav1e" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/xiph/rav1e.git
cd rav1e
cargo cinstall --release --prefix=${TARGET} --libdir=${TARGET}/lib --includedir=${TARGET}/include
if find /Volumes/RamDisk/sw/ | grep "rav1e" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ xvid
LastVersion=$(wget --no-check-certificate https://downloads.xvid.com/downloads/ -O- -q | grep -Eo 'xvidcore-[0-9\.]+\.tar.gz' | tail -1)
tput bold ; echo ; echo '📍 ' "$LastVersion" Last ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "xvid" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
wget --no-check-certificate https://downloads.xvid.com/downloads/"$LastVersion"
tar -zxvf xvidcore*
cd xvidcore/build/generic/
./bootstrap.sh
./configure --prefix=${TARGET} --disable-assembly --enable-macosx_module
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "xvid" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ openh264
tput bold ; echo ; echo '📍 ' openH264 git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "openh264" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/cisco/openh264.git
cd openh264/
make -j "$THREADS" install-static PREFIX=${TARGET}
if find /Volumes/RamDisk/sw/ | grep "openh264" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ x264 8-10bit git - Require nasm
tput bold ; echo ; echo '📍 ' x264 8-10bit git ; tput sgr0
cd ${CMPL} ; sleep 2
if find /Volumes/RamDisk/sw/ | grep "x264" >/dev/null ; then echo Build All Ready Done ; else
git clone https://code.videolan.org/videolan/x264.git
cd x264/
./configure --prefix=${TARGET} --enable-static --bit-depth=all --chroma-format=all
make -j "$THREADS" && make install
if find /Volumes/RamDisk/sw/ | grep "x264" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ x265 8-10-12bit - Require wget, cmake, yasm, nasm, libtool, ninja
tput bold ; echo ; echo '📍 ' x265 8-10-12bit git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "x265" >/dev/null ; then echo Build All Ready Done ; else
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
if find /Volumes/RamDisk/sw/ | grep "x265" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
fi

#_ AviSynth+
tput bold ; echo ; echo '📍 ' AviSynthPlus git ; tput sgr0
if find /Volumes/RamDisk/sw/ | grep "avisynth" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cd ${CMPL} ; sleep 2
git clone https://github.com/AviSynth/AviSynthPlus.git
cd AviSynthPlus
mkdir avisynth-build && cd avisynth-build
cmake ../ -DCMAKE_INSTALL_PREFIX:PATH=${TARGET} -DHEADERS_ONLY:bool=on
make VersionGen install
if find /Volumes/RamDisk/sw/ | grep "avisynth" >/dev/null ; then tput bold ; echo Build OK ; else echo Build Fail ; tput sgr0 ; exit ; fi
rm -fr /Volumes/RamDisk/compile/*
fi

#_ librtmp
tput bold ; echo ; echo '📍 ' librtmp Copy ; tput sgr0 ; sleep 2
if find /Volumes/RamDisk/sw/ | grep "rtmp" >/dev/null 2>&1 ; then echo Build All Ready Done ; else
cp -v /usr/local/Cellar/rtmpdump/*/bin/* /Volumes/RamDisk/sw/bin/
cp -vr /usr/local/Cellar/rtmpdump/*/include/* /Volumes/RamDisk/sw/include/
cp -v /usr/local/Cellar/rtmpdump/*/lib/pkgconfig/librtmp.pc /Volumes/RamDisk/sw/lib/pkgconfig
cp -v /usr/local/Cellar/rtmpdump/*/lib/librtmp* /Volumes/RamDisk/sw/lib
fi

#-> FFmpeg Check
tput bold ; echo ; echo ; echo '⚙️  ' FFmpeg Build ; tput sgr0

#_ Purge .dylib
tput bold ; echo ; echo '💢 ' Purge .dylib ; tput sgr0 ; sleep 2
rm -vfr $TARGET/lib/*.dylib
rm -vfr /usr/local/opt/libx11/lib/libX11.6.dylib

#_ Flags
tput bold ; echo ; echo '🚩 ' Define FLAGS ; tput sgr0 ; sleep 2
export LDFLAGS="-L${TARGET}/lib -Wl,-framework,OpenAL"
export CPPFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL"
export CFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL,-fno-stack-check"

#_ FFmpeg Build
tput bold ; echo ; echo '📍 ' FFmpeg git ; tput sgr0
cd ${CMPL} ; sleep 2
git clone git://git.ffmpeg.org/ffmpeg.git
cd ffmpe*/
./configure --extra-version=adam-"$(date +"%Y-%m-%d")" --extra-cflags="-fno-stack-check" --cc=/usr/bin/clang \
 --enable-pthreads --enable-postproc --enable-runtime-cpudetect \
 --pkg_config='pkg-config --static' --enable-nonfree --enable-gpl --enable-version3 --prefix=${TARGET} \
 --disable-ffplay --disable-ffprobe --disable-debug --disable-doc --enable-avfilter --enable-avisynth --enable-filters \
 --enable-libopus --enable-libtheora --enable-libvorbis --enable-libspeex --enable-libmp3lame --enable-libfdk-aac --enable-encoder=aac \
 --enable-libtwolame --enable-libopencore_amrnb --enable-libopencore_amrwb --enable-libgsm \
 --enable-libxvid --enable-libopenh264 --enable-libx264 --enable-libx265 --enable-libvpx  --enable-libaom --enable-libdav1d --enable-librav1e \
 --enable-libfreetype --enable-libfribidi --enable-libass --enable-libsrt --enable-libfontconfig \
 --enable-libbluray --enable-bzlib --enable-zlib --enable-lzma --enable-libsnappy --enable-libopenjpeg --enable-libwebp \
 --enable-opengl --enable-opencl --enable-openal --enable-libzimg --enable-openssl --enable-librtmp  --enable-muxer=mp4

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
tput bold ; echo ; echo '⏳  ' End in "$Time"s ; tput sgr0
echo ) 2>&1 | tee "$HOME/Library/Logs/adam-FFmpeg-Static.log"
