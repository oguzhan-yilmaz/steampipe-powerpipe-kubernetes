FROM debian:bookworm-slim

ARG TARGETOS=linux
ARG TARGETARCH
ARG STEAMPIPE_VERSION=v2.4.4
ARG PRE_INSTALL_PLUGINS="kubernetes"

# OCI image version/title labels are set by docker/metadata-action in CI.
LABEL org.opencontainers.image.description="Steampipe database service for Kubernetes"
LABEL dev.turbot.steampipe.version="${STEAMPIPE_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    INSTALL_PLUGINS="" \
    STEAMPIPE_INSTALL_DIR="/home/steampipe/.steampipe"
ENV PATH="${PATH}:/home/steampipe"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        curl \
        postgresql-client \
        tar \
        unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 11234 steampipe \
    && useradd -m -u 11234 -g steampipe steampipe

USER steampipe
WORKDIR /home/steampipe

# Re-declare build-args so CI --build-arg values apply to subsequent RUN steps.
ARG STEAMPIPE_VERSION
ARG PRE_INSTALL_PLUGINS
RUN set -eux; \
    curl -fsSL -o steampipe.tar.gz \
      "https://github.com/turbot/steampipe/releases/download/${STEAMPIPE_VERSION}/steampipe_linux_${TARGETARCH}.tar.gz"; \
    tar -xzf steampipe.tar.gz -C /home/steampipe; \
    rm steampipe.tar.gz; \
    mkdir -p /home/steampipe/initdb-sql-scripts

# Warm up the embedded database and pre-install plugins in separate layers so
# GHA build cache (cache-to: type=gha,mode=max) can reuse them independently.
ARG STEAMPIPE_VERSION
ARG PRE_INSTALL_PLUGINS
RUN set -eux; \
    stdbuf -oL -eL steampipe service start; \
    steampipe service stop; \
    if [ -n "${PRE_INSTALL_PLUGINS}" ]; then \
      steampipe plugin install ${PRE_INSTALL_PLUGINS}; \
    fi

COPY --chmod=755 *.sh .

EXPOSE 9193

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=10 \
    CMD ["bash", "./healthcheck.sh"]

ENTRYPOINT ["bash", "entrypoint.sh"]
