## FFmpeg Static Builder
####  macOS 10.12 < 10.15

#### Include Last Versions of x264 | x265 | AV1 | FFmpeg…


```
./configure --extra-version=adam-"$(date +"%Y-%m-%d")" --extra-cflags="-fno-stack-check" --arch=x86_64 --cc=/usr/bin/clang \
 --enable-hardcoded-tables --enable-pthreads --enable-postproc --enable-runtime-cpudetect \
 --pkg_config='pkg-config --static' --enable-nonfree --enable-gpl --enable-version3 --prefix=${TARGET} \
 --disable-ffplay --disable-ffprobe --disable-debug --disable-doc --enable-avfilter --enable-avisynth --enable-filters \
 --enable-libopus --enable-libvorbis --enable-libtheora --enable-libmp3lame --enable-libfdk-aac --enable-encoder=aac \
 --enable-libtwolame --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libopencore_amrwb --enable-libgsm \
 --enable-muxer=mp4 --enable-libxvid --enable-libopenh264 --enable-libx264 --enable-libx265 --enable-libvpx --enable-libaom --enable-libdav1d \
 --enable-fontconfig --enable-libfreetype --enable-libfribidi --enable-libass --enable-libsrt \
 --enable-libbluray --enable-bzlib --enable-zlib --enable-lzma --enable-libsnappy --enable-libwebp --enable-libopenjpeg \
 --enable-opengl --enable-opencl --enable-openal --enable-openssl --enable-librtmp
```

#### How Use :

##### =-> Download & Build :
```
cd ~/Desktop && git clone https://github.com/albinoz/ffmpeg-static-OSX.git && \
chmod 755 ~/Desktop/ffmpeg-static-OSX/ffmpeg-static-OSX.command  && \
~/Desktop/ffmpeg-static-OSX/ffmpeg-static-OSX.command
```

#### Result :

##### =-> On Successfully Build :
`ffmpeg static binary must be copied on Desktop`

##### x-> On Error Build :
`Please Report with log to`
https://github.com/albinoz/ffmpeg-static-OSX/issues

