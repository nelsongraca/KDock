FROM alpine:latest

ARG REPO=https://github.com/Arksine/moonraker

RUN apk add  --no-cache python3 python3-dev py3-pip \
    musl-dev libffi-dev newlib \
    iproute2 libsodium ffmpeg wget socat \
    git bash tini shadow && \
    addgroup -g 1000 kdock && \
    adduser -s '/bin/bash' -G kdock -u 1000 -h '/opt/kdock' -D kdock

WORKDIR /opt/kdock

ADD --chown=kdock:kdock --chmod=550 start.sh start.sh
ADD --chown=kdock:kdock --chmod=550 supervisor/supervisorctl /usr/bin/supervisorctl

USER kdock

RUN <<EOT bash
  git clone $REPO moonraker
  pushd moonraker
  git checkout master
  rm -rf .git
  popd
  python -m venv .venv
  .venv/bin/pip install --upgrade setuptools pip
  .venv/bin/pip install -r moonraker/scripts/moonraker-requirements.txt
  .venv/bin/pip install -r moonraker/scripts/moonraker-speedups.txt
  mkdir -p /opt/kdock/data
EOT

VOLUME "/opt/kdock/data"

EXPOSE 7125

ENTRYPOINT ["/sbin/tini", "--"]


CMD ["bash", "/opt/kdock/start.sh"]
