FROM ubuntu:20.04

RUN apt-get update -y && apt-get install -y software-properties-common gnupg2 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
    add-apt-repository ppa:rmescandon/yq && \
    apt-get update -y && \
    apt-get install --yes bzip2 wget libxext6 libllvm6.0 mesa-utils python3-pip yq jq
RUN pip3 install renconstruct

COPY build.sh /build.sh

ENTRYPOINT ["/build.sh"]
