#
# GitLab CI: Ionic (Capacitor) v0.0.1
#
# https://hub.docker.com/r/khalilcharfi/gitlab-ci-ionic/
#

FROM ubuntu:20.04

ENV VERSION_TOOLS "6609375"

ENV ANDROID_SDK_ROOT "/sdk"
# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/tools"
ENV DEBIAN_FRONTEND noninteractive

ENV SONAR_SCANNER_VERSION 3.3.0.1492

RUN apt-get -qq update \
 && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-11-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses6 \
      lib32z1 \
      unzip \
      locales \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /tools.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
 && unzip /tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && rm -v /tools.zip

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
 && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
 && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
 && yes | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses >/dev/null

ADD packages.txt /sdk
RUN mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt \
 && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} ${PACKAGES}

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