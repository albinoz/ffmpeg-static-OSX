# ffmpeg-static-OSX
### Build ffmpeg in static on OS X
###### --extra-cflags='-march=native' --as=yasm --enable-nonfree --enable-gpl --enable-version3 --enable-hardcoded-tables --enable-pthreads --enable-opengl --enable-opencl --enable-postproc --enable-runtime-cpudetect --arch=x86_64 --disable-ffplay --disable-ffserver --disable-ffprobe --disable-doc --enable-openal --enable-libmp3lame --enable-libfaac --enable-libfdk-aac --enable-libopus --enable-libvorbis --enable-libtheora --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libgsm --enable-libxvid --enable-libx264 --enable-libx265 --enable-libvpx --enable-avfilter --enable-filters --enable-libass --enable-fontconfig --enable-libfreetype --enable-libbluray --enable-bzlib --enable-zlib

### Try run OSX ffmpeg-static-OSX.command

#### Request Rootless from OS X 10.11
https://www.quora.com/How-do-I-turn-off-the-rootless-in-OS-X-El-Capitan-10-11

###### =-> Download & Install Apple Java for libbluray Build :
https://support.apple.com/kb/DL1572?locale=fr_FR&viewlocale=fr_FR

###### =-> Open /Applications/Utilities/Terminal.app
chmod 755 '~/Path to/ffmpeg-static-OSX.command'

###### =-> Build Lastest ffmpeg by double click on ffmpeg-static-OSX.command

###### =-> Build Result will be copied on Desktop
