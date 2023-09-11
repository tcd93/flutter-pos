FROM debian:stable

WORKDIR /usr/vscode

ENV ANDROID_HOME="/usr/lib/android-sdk"
# install Android sdk & cmdline tools without Android Studio
RUN apt-get update && \
    apt-get install -y wget tar xz-utils unzip git && \
    apt-get install -y android-sdk && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip commandlinetools-linux-10406996_latest.zip && \
    mkdir -p "${ANDROID_HOME}/cmdline-tools/latest" && \
    mv cmdline-tools/* "${ANDROID_HOME}/cmdline-tools/latest" && \
    rm -rf cmdline-tools

ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"
RUN yes | sdkmanager --licenses && sdkmanager --install "platforms;android-33"

# download and extract to "flutter" folder
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.3-stable.tar.xz && \
    tar vxfo flutter_linux_3.13.3-stable.tar.xz

ENV PATH="${PATH}:/usr/vscode/flutter/bin"
