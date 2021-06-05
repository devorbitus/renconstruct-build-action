FROM ubuntu:20.04

RUN apt-get update -y && apt-get install -y software-properties-common gnupg2 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
    add-apt-repository ppa:rmescandon/yq && add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update -y && \
    apt-get install --yes bzip2 wget libxext6 libllvm6.0 mesa-utils python3-pip yq && \
    jq openjdk-8-jdk
RUN pip3 install renconstruct

ENV SDL_AUDIODRIVER=dummy
ENV SDL_VIDEODRIVER=dummy
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

COPY build.sh /build.sh

ENTRYPOINT ["/build.sh"]
