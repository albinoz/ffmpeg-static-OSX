## ffmpeg-static-OSX
##### - Build OS X static ffmpeg
##### - Simple Double-Click to Build
##### - Check Last Version of Sources

## Request :

##### =-> Apple Xcode
###### For Link Some OS X binaries
https://developer.apple.com/xcode/download/

##### =-> Rootless from OS X 10.11
###### For HomeBrew Installs
https://www.quora.com/How-do-I-turn-off-the-rootless-in-OS-X-El-Capitan-10-11

## How Use :

##### =-> Download :
```
git clone https://github.com/albinoz/ffmpeg-static-OSX.git ~/Desktop/ffmpeg-static-OSX-master
```
##### =-> Make Executable :
```
chmod +x ~/Desktop/ffmpeg-static-OSX-master/ffmpeg-static-OSX.command
```

##### =-> Build :
```
~/Desktop/ffmpeg-static-OSX-master/ffmpeg-static-OSX.command
```
## Result :

##### =-> On Successfully Build :
`ffmpeg static binary be copied on Desktop`

##### =-> Include :
```
./configure --extra-version=adam-`date +"%m-%d-%y"` \
 --pkg_config='pkg-config --static' --prefix=${TARGET} \
 --extra-cflags=-march=native --as=yasm --enable-nonfree --enable-gpl --enable-version3 \
 --enable-hardcoded-tables --enable-pthreads --enable-postproc --enable-runtime-cpudetect --arch=x86_64 \
 --enable-opengl --enable-opencl --disable-ffplay --disable-ffserver --disable-ffprobe --disable-doc \
 --enable-openal --enable-libmp3lame --enable-libfaac --enable-libfdk-aac \
 --enable-libopus --enable-libvorbis --enable-libtheora \
 --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libgsm \
 --enable-libxvid --enable-libx264 --enable-libx265 --enable-libvpx \
 --enable-avfilter --enable-filters --enable-libass --enable-fontconfig --enable-libfreetype \
 --enable-libbluray --enable-bzlib --enable-zlib
```

