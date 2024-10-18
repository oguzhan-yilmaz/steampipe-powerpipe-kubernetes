FROM debian:bookworm-slim

LABEL org.opencontainers.image.source https://github.com/oguzhan-yilmaz/steampipe-powerpipe-kubernetes

ENV DEBIAN_FRONTEND=noninteractive
# space separated list of plugins at build time
ARG PRE_INSTALL_PLUGINS="steampipe kubernetes"
ARG STEAMPIPE_BINARY_DOWNLOAD_URL="https://github.com/turbot/steampipe/releases/download/v0.24.2/steampipe_linux_arm64.tar.gz"
# space separated list of plugins to install at runtime
ENV INSTALL_PLUGINS=""
ENV STEAMPIPE_INSTALL_DIR="/home/steampipe/.steampipe"


RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y curl tar unzip postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 11234 steampipe \
    && useradd -m -u 11234 -g steampipe steampipe

USER steampipe

WORKDIR /home/steampipe

RUN curl -sL -o steampipe.tar.gz ${STEAMPIPE_BINARY_DOWNLOAD_URL} \
    && tar -xzvf steampipe.tar.gz \
    && rm steampipe.tar.gz \
    && mkdir /home/steampipe/init-db-sql
    
# start the service beforehand for faster startup time
# and pre install selected plugins
RUN ./steampipe service start \
    && ./steampipe service stop \
    && if [ -n "${PRE_INSTALL_PLUGINS}" ]; then ./steampipe plugin install ${PRE_INSTALL_PLUGINS} > /dev/null; fi

COPY *.sh .

EXPOSE 9193

ENTRYPOINT ["bash", "entrypoint.sh"]