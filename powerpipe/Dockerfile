FROM debian:bookworm-slim

LABEL org.opencontainers.image.source https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes

ENV DEBIAN_FRONTEND="noninteractive"

ARG POWERPIPE_BINARY_DOWNLOAD_URL=""

# space separated list of plugins at build time
ARG PRE_INSTALL_MODS="github.com/turbot/steampipe-mod-kubernetes-insights github.com/turbot/steampipe-mod-kubernetes-compliance"
# space separated list of plugins to install at runtime
ENV INSTALL_MODS=""

ENV POWERPIPE_INSTALL_DIR="/home/powerpipe/.powerpipe"


RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y curl tar unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 11234 powerpipe \
    && useradd -m -u 11234 -g powerpipe powerpipe

USER powerpipe

WORKDIR /home/powerpipe

RUN curl -sL -o powerpipe.tar.gz ${POWERPIPE_BINARY_DOWNLOAD_URL} \
    && tar -xzvf powerpipe.tar.gz \
    && rm powerpipe.tar.gz \
    && yes | ./powerpipe mod init \
    && if [ -n "${PRE_INSTALL_MODS}" ]; then ./powerpipe mod install ${PRE_INSTALL_MODS} > /dev/null; fi

COPY *.sh .

EXPOSE 9033

ENTRYPOINT ["bash", "entrypoint.sh"]