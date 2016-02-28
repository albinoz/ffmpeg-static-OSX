## ffmpeg-static-OSX
##### - Build OS X static ffmpeg
##### - Simple Double-Click to Build
##### - Check Last Version of Sources

## Request :

##### =-> Apple Xcode (For Link Some OS X binaries)
https://developer.apple.com/xcode/download/

##### =-> Rootless from OS X 10.11 (For HomeBrew Install)
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

##### =-> Include :
```
./configure --extra-version=adam-`date +"%m-%d-%y"` \
--pkg_config='pkg-config --static' --prefix=${TARGET} --extra-cflags=-march=native --as=yasm --enable-nonfree --enable-gpl --enable-version3 \
--enable-hardcoded-tables --enable-pthreads --enable-opengl --enable-opencl --enable-postproc --enable-runtime-cpudetect --arch=x86_64 \
--disable-ffplay --disable-ffserver --disable-ffprobe --disable-doc \
--enable-openal --enable-libmp3lame --enable-libfaac --enable-libfdk-aac \
--enable-libopus --enable-libvorbis --enable-libtheora \
--enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libgsm \
--enable-libxvid --enable-libx264 --enable-libx265 --enable-libvpx \
--enable-avfilter --enable-filters --enable-libass --enable-fontconfig --enable-libfreetype \
--enable-libbluray --enable-bzlib --enable-zlib
```

##### =-> Statics Links :
```
/System/Library/Frameworks/OpenAL.framework/Versions/A/OpenAL (compatibility version 1.0.0, current version 1.0.0)
/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 1256.14.0)
/System/Library/Frameworks/Carbon.framework/Versions/A/Carbon (compatibility version 2.0.0, current version 157.0.0)
/System/Library/Frameworks/QTKit.framework/Versions/A/QTKit (compatibility version 1.0.0, current version 1.0.0)
/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation (compatibility version 300.0.0, current version 1256.1.0)
/System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore (compatibility version 1.2.0, current version 1.11.0)
/System/Library/Frameworks/CoreVideo.framework/Versions/A/CoreVideo (compatibility version 1.2.0, current version 1.5.0)
/System/Library/Frameworks/AVFoundation.framework/Versions/A/AVFoundation (compatibility version 1.0.0, current version 2.0.0)
/System/Library/Frameworks/CoreMedia.framework/Versions/A/CoreMedia (compatibility version 1.0.0, current version 1.0.0)
/System/Library/Frameworks/VideoToolbox.framework/Versions/A/VideoToolbox (compatibility version 1.0.0, current version 1.0.0)
/System/Library/Frameworks/VideoDecodeAcceleration.framework/Versions/A/VideoDecodeAcceleration (compatibility version 1.0.0, current version 1.0.0)
/System/Library/Frameworks/Security.framework/Versions/A/Security (compatibility version 1.0.0, current version 57337.20.44)
/System/Library/Frameworks/OpenGL.framework/Versions/A/OpenGL (compatibility version 1.0.0, current version 1.0.0)
/System/Library/Frameworks/OpenCL.framework/Versions/A/OpenCL (compatibility version 1.0.0, current version 1.0.0)
/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 120.1.0)
/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1226.10.1)
/usr/lib/libexpat.1.dylib (compatibility version 7.0.0, current version 8.0.0)
/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
/System/Library/Frameworks/CoreGraphics.framework/Versions/A/CoreGraphics (compatibility version 64.0.0, current version 600.0.0)
/usr/lib/liblzma.5.dylib (compatibility version 6.0.0, current version 6.3.0)
/System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices (compatibility version 1.0.0, current version 728.6.0)	/System/Library/Frameworks/CoreText.framework/Versions/A/CoreText (compatibility version 1.0.0, current version 1.0.0)
/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
```
