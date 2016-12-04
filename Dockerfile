FROM ubirch/java
MAINTAINER Falko Zurell <falko.zurell@ubirch.com>

ENV SBT_VERSION 0.13.13
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin
ENV VCS_REF $VCS_REF
ENV BUILD_DATE $BUILD_DATE
ENV sbt.ivy.home /build/.ivy2


# Install sbt
# https://dl.bintray.com/sbt/native-packages/sbt/0.13.13/sbt-0.13.13.tgz
RUN mkdir -p $SBT_HOME
RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xvz --strip-components 1 -C $SBT_HOME && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built
RUN echo "-ivy /build/.ivy2" >> $SBT_HOME/conf/sbtopts

RUN mkdir -p /build
VOLUME /build
WORKDIR /build
ENTRYPOINT [ "/usr/bin/java","-jar","/usr/local/sbt/bin/sbt-launch.jar", "-Dsbt.ivy.home=/build/.ivy2" ]