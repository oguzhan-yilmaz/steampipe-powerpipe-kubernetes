FROM debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes

ENV DEBIAN_FRONTEND="noninteractive"
# space separated list of plugins at build time
ARG TARGETOS=linux
ARG TARGETARCH
ARG STEAMPIPE_VERSION=v2.2.0

ARG PRE_INSTALL_PLUGINS="kubernetes"

# space separated list of plugins to install at runtime
ENV INSTALL_PLUGINS=""

ENV STEAMPIPE_INSTALL_DIR="/home/steampipe/.steampipe"
ENV PATH="$PATH:/home/steampipe"

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y curl wget tar unzip postgresql-client coreutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 11234 steampipe \
    && useradd -m -u 11234 -g steampipe steampipe
    
USER steampipe

WORKDIR /home/steampipe

RUN export STEAMPIPE_BINARY_DOWNLOAD_URL="https://github.com/turbot/steampipe/releases/download/${STEAMPIPE_VERSION}/steampipe_linux_${TARGETARCH}.tar.gz" \
    && echo "STEAMPIPE_BINARY_DOWNLOAD_URL=$STEAMPIPE_BINARY_DOWNLOAD_URL" \
    && curl -sL -o steampipe.tar.gz "${STEAMPIPE_BINARY_DOWNLOAD_URL}" \
    && tar -xzvf steampipe.tar.gz -C /home/steampipe \
    && rm steampipe.tar.gz \
    && mkdir /home/steampipe/initdb-sql-scripts
    

# ENTRYPOINT [ "sleep",  "infinity" ]

# start the service beforehand for faster startup time
# and pre install selected plugins

# RUN steampipe service start 
RUN stdbuf -oL -eL steampipe service start 
RUN steampipe service stop 
RUN if [ -n "${PRE_INSTALL_PLUGINS}" ]; then steampipe plugin install ${PRE_INSTALL_PLUGINS} > /dev/null; fi

COPY *.sh .

EXPOSE 9193
ENTRYPOINT ["bash", "entrypoint.sh"]
