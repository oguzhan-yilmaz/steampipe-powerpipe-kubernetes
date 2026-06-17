FROM debian:bookworm-slim

ARG TARGETOS=linux
ARG TARGETARCH
ARG POWERPIPE_VERSION=v1.5.2
ARG PRE_INSTALL_MODS="github.com/turbot/steampipe-mod-kubernetes-insights github.com/turbot/steampipe-mod-kubernetes-compliance"

# OCI image version/title labels are set by docker/metadata-action in CI.
LABEL org.opencontainers.image.description="Powerpipe dashboard server for Kubernetes"
LABEL dev.turbot.powerpipe.version="${POWERPIPE_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    INSTALL_MODS="" \
    POWERPIPE_INSTALL_DIR="/home/powerpipe/.powerpipe" \
    POWERPIPE_MOD_LOCATION="/home/powerpipe/mod"
ENV PATH="${PATH}:/home/powerpipe"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        curl \
        tar \
        unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 11234 powerpipe \
    && useradd -m -u 11234 -g powerpipe powerpipe

USER powerpipe
WORKDIR /home/powerpipe

# Re-declare build-args so CI --build-arg values apply to subsequent RUN steps.
ARG POWERPIPE_VERSION
ARG PRE_INSTALL_MODS
RUN set -eux; \
    curl -fsSL -o powerpipe.tar.gz \
      "https://github.com/turbot/powerpipe/releases/download/${POWERPIPE_VERSION}/powerpipe.${TARGETOS}.${TARGETARCH}.tar.gz"; \
    tar -xzf powerpipe.tar.gz; \
    rm powerpipe.tar.gz; \
    mkdir -p mod; \
    cd mod; \
    yes | powerpipe mod init; \
    if [ -n "${PRE_INSTALL_MODS}" ]; then \
      powerpipe mod install ${PRE_INSTALL_MODS}; \
    fi

COPY --chmod=755 *.sh .

EXPOSE 9033

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=5 \
    CMD ["bash", "./healthcheck.sh"]

ENTRYPOINT ["bash", "entrypoint.sh"]
