

FROM debian:bookworm-slim

LABEL org.opencontainers.image.source https://github.com/oguzhan-yilmaz/argocd-backup-s3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y curl tar unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 11234 argocdbackup \
    && useradd -m -u 11234 -g argocdbackup argocdbackup

USER argocdbackup

WORKDIR /home/argocdbackup

# Print all binaries in PATH
# CMD find $(echo $PATH | tr ':' ' ') -type f -executable -exec basename {} \; | sort
COPY *.sh .

EXPOSE 9033

ENTRYPOINT ["bash", "entrypoint.sh"]