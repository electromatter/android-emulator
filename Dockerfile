FROM ubuntu:bionic

# TODO: consider not installing recommended/suggested packages
# cmake+build-essential for c
# java 8 because the android sdk requires it
# maven to build the java code
# unzip/zip for tools
# python for support scripts
# xvfb+ffmpeg to record screen to produce test artifacts
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential cmake git wget unzip zip openssh-client i3 \
	libxcomposite1 pulseaudio x11vnc \
        openjdk-8-jdk-headless maven \
        python python3 python-pip python3-pip \
        xvfb ffmpeg mariadb-server mariadb-client && \
    apt-get clean && \
    update-java-alternatives -s java-1.8.0-openjdk-amd64 && \
    groupadd android && useradd -g android -s /bin/bash -m android

# Ensure the X11 sockets directory exists
RUN mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Run as an unprivileged user
USER android
WORKDIR /home/android

# Bootstrap the sdk using maven
COPY --chown=android:android sdk/ /home/android/sdk
RUN cd /home/android/sdk && \
    mkdir -p /home/android/.android && \
    touch /home/android/.android/repositories.cfg && \
    mvn versions:resolve-ranges -B && \
    yes | mvn exec:java -B \
        -Dexec.args="--sdk_root=/home/android/.android --licenses" \
	> /dev/null && \
    mvn exec:java -B \
        -Dexec.args="--sdk_root=/home/android/.android --install tools" \
	| grep -v '^\[=*\s*\]' && \
    rm -r /home/android/sdk /home/android/.m2

# Install the parts of the sdk we need
RUN /home/android/.android/tools/bin/sdkmanager --install \
        emulator platform-tools \
        "platforms;android-24" \
        "system-images;android-24;default;armeabi-v7a" \
	| grep -v '^\[=*\s*\]'
