FROM debian:bookworm-slim

# space separated list of plugins at build time
ARG PRE_INSTALL_PLUGINS="steampipe kubernetes"
ARG STEAMPIPE_BINARY_DOWNLOAD_URL="https://github.com/turbot/steampipe/releases/download/v0.24.2/steampipe_linux_arm64.tar.gz"
# space separated list of plugins to install at runtime
ENV INSTALL_PLUGINS=""
ENV STEAMPIPE_INSTALL_DIR="/app/.steampipe"
WORKDIR /app

RUN apt update -y && apt upgrade -y && apt install curl tar unzip -y

RUN curl -sL -o steampipe.tar.gz ${STEAMPIPE_BINARY_DOWNLOAD_URL} \
    && tar -xzvf steampipe.tar.gz \
    && rm steampipe.tar.gz
    
RUN groupadd -g 1234 steampipe && \
    useradd -m -u 1234 -g steampipe steampipe && \
    chown -R steampipe:steampipe /app

USER steampipe

# # start the service beforehand for faster startup time
# RUN ./steampipe service start \
#     && ./steampipe service stop

RUN if [ -n "${PRE_INSTALL_PLUGINS}" ]; then ./steampipe plugin install ${PRE_INSTALL_PLUGINS} > /dev/null; fi

COPY *.sh .

EXPOSE 9193

ENTRYPOINT ["bash", "entrypoint.sh"]