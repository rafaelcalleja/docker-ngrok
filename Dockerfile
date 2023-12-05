ARG BASE_IMAGE="ubuntu:20.04"
ARG BUILDER_IMAGE="golang:1.21-bullseye"
FROM $BUILDER_IMAGE as packer

RUN git clone https://github.com/89luca89/pakkero && \
    cd pakkero/ && sed -i 's/-i //g' Makefile && make && apt update && apt-get install -y xz-utils git make binutils coreutils unzip && \
    wget https://github.com/upx/upx/releases/download/v4.2.1/upx-4.2.1-amd64_linux.tar.xz && \
    tar xvf upx-4.2.1-amd64_linux.tar.xz && mv upx-4.2.1-amd64_linux/upx /usr/local/bin && \
    wget -O /tmp/ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip -o /tmp/ngrok.zip -d / && \
    dist/pakkero -file /ngrok -c -o /bin/ngrok -enable-stdout -register-dep /bin/bash;

SHELL ["/bin/bash", "-c"]
RUN /bin/ngrok --version

FROM $BASE_IMAGE

LABEL           maintainer="Dmitry Shkoliar @shkoliar"

COPY            --from=packer /bin/ngrok /bin/ngrok

COPY            start.sh /

RUN             chmod +x /start.sh

RUN useradd -m -u 1000 ngrok

USER            ngrok

EXPOSE          4551

ENTRYPOINT      ["/start.sh"]
SHELL ["/bin/bash", "-c"]
