FROM debian:bookworm-slim

ARG POWERPIPE_BINARY_DOWNLOAD_URL="https://github.com/turbot/powerpipe/releases/download/v0.4.4/powerpipe.linux.arm64.tar.gz"

# space separated list of plugins at build time
ARG PRE_INSTALL_MODS="github.com/turbot/steampipe-mod-kubernetes-insights github.com/turbot/steampipe-mod-kubernetes-compliance"
# space separated list of plugins to install at runtime
ENV INSTALL_MODS=""
ENV PIPES_INSTALL_DIR="/app/.pipes"
ENV POWERPIPE_INSTALL_DIR="/app/.powerpipe"

WORKDIR /app

RUN apt update -y && apt upgrade -y && apt install curl tar unzip -y

RUN groupadd -g 1234 powerpipe && \
    useradd -m -u 1234 -g powerpipe powerpipe && \
    chown -R powerpipe:powerpipe /app

USER powerpipe

RUN curl -sL -o powerpipe.tar.gz ${POWERPIPE_BINARY_DOWNLOAD_URL} \
    && tar -xzvf powerpipe.tar.gz \
    && rm powerpipe.tar.gz \
    && ./powerpipe mod init
    

RUN if [ -n "${PRE_INSTALL_MODS}" ]; then ./powerpipe mod install ${PRE_INSTALL_MODS} > /dev/null; fi

COPY *.sh .

EXPOSE 9033

ENTRYPOINT ["bash", "entrypoint.sh"]