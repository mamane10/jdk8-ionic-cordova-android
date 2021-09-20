FROM rtfpessoa/ubuntu-jdk8
LABEL El Marchani Abderrahmane <abderrahmaneelmarchani@gmail.com>

ENV NPM_VERSION=6.12.0 \
    CORDOVA_VERSION=10.0.0 \
    GRADLE_VERSION=7.2 \
    JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    ANDROID_HOME=/opt/android-sdk-linux 

# Install basics
RUN apt-get update &&  \
    apt-get install -y git wget curl unzip build-essential && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update &&  \
    apt-get install -y nodejs && \
    npm install -g npm@"$NPM_VERSION" cordova@"$CORDOVA_VERSION" @ionic/cli && \
    npm cache clear --force && \
    apt-get install -y pulseaudio && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg --unpack google-chrome-stable_current_amd64.deb && \
    apt-get install -f -y && \
    apt-get clean && \
    rm google-chrome-stable_current_amd64.deb

# Install Gradle
RUN mkdir  /opt/gradle && cd /opt/gradle && \
    wget --output-document=gradle.zip --quiet https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    unzip -q gradle.zip && \
    rm -f gradle.zip && \
    chown -R root. /opt

# Install Android Tools
RUN mkdir  /opt/android-sdk-linux && cd /opt/android-sdk-linux && \
    wget --output-document=android-tools-sdk.zip --quiet https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip -q android-tools-sdk.zip && \
    rm -f android-tools-sdk.zip

# Setup environment
ENV PATH ${PATH}:${JAVA_HOME}/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install Android SDK
RUN (yes | ${ANDROID_HOME}/tools/bin/sdkmanager "platforms;android-27" >/dev/null) && \
    (yes | ${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" >/dev/null) && \
    (yes | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;27.0.3" >/dev/null) && \
    (yes | ${ANDROID_HOME}/tools/bin/sdkmanager "system-images;android-27;google_apis;x86") && \
    (yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses)

# Create New Virtual Device
RUN (echo 'no' | ${ANDROID_HOME}/tools/bin/avdmanager create avd -n pixel2xl -k 'system-images;android-27;google_apis;x86' --force)

expose 5555
