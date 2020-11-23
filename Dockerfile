#
# GitLab CI: Ionic (Capacitor) v0.0.1
#
# https://hub.docker.com/r/khalilcharfi/gitlab-ci-ionic/
#

FROM ubuntu:20.04

ENV ANDROID_HOME /opt/android-sdk-linux

# Download Android SDK into $ANDROID_HOME
# You can find URL to the current version at: https://developer.android.com/studio/index.html

RUN apt update && \
    apt install wget && \
    mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O android_tools.zip && \
    unzip android_tools.zip && \
    rm android_tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Accept Android SDK licenses

RUN yes | sdkmanager --licenses

RUN touch /root/.android/repositories.cfg

# Platform tools
RUN sdkmanager "emulator" "tools" "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

RUN yes | sdkmanager --update --channel=3
# Please keep all sections in descending order!
RUN yes | sdkmanager \
    "platforms;android-30" \
    "platforms;android-29" \
    "platforms;android-28" \
    "build-tools;29.0.2" \
    "build-tools;29.0.1" \
    "build-tools;29.0.0" \
    "build-tools;28.0.3" \
    "build-tools;28.0.2" \
    "build-tools;28.0.1" \
    "build-tools;28.0.0" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    && touch /root/.android/repositories.cfg \
    && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update \
    && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --package_file=/sdk/packages.txt

ENV PATH "$PATH:/usr/bin/gcc"

RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash \
 && rbenv install 2.6.6 \
 && rbenv global 2.6.6 \
 && rbenv init -

ENV RUBYLIB "/root/.gem/ruby/2.6.0"

RUN mkdir -p /bundle-ruby/

ADD Gemfile /bundle-ruby/

RUN gem install bundler \
 && gem install builder -v 3.2.2 \
 && gem install tilt -v 2.0.10 \
 && gem install activesupport -v 6.0.3.3 \
 && gem install rubysl-pathname \
 && gem install activesupport-core-ext 

RUN cd /bundle-ruby \
 && bundle install \
 && bundle update --bundler \
 && cd /

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
&& apt-get install -y nodejs \
&& npm install -g --unsafe-perm=true --allow-root \
&& chmod +x -R /root/.npm \
&& npm install -g @angular/cli \
&& npm install -g @ionic/cli