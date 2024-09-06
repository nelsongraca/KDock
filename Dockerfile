FROM alpine:latest AS kdock

RUN apk add  --no-cache python3 python3-dev py3-pip \
    make gcc musl-dev libffi-dev newlib \
    avrdude dfu-util \
    iproute2 libsodium ffmpeg wget socat \
    git bash tini shadow && \
    addgroup -g 1000 kdock && \
    adduser -s '/bin/bash' -G kdock -u 1000 -h '/opt/kdock' -D kdock && \
    python -m venv /opt/kdock/.venv && \
    chown -R kdock:kdock /opt/kdock/.venv

WORKDIR /opt/kdock

ENTRYPOINT ["/sbin/tini", "--"]

VOLUME "/opt/kdock/data"

CMD ["bash", "/opt/kdock/start.sh"]

USER kdock

FROM kdock AS klipper

ADD --chown=kdock:kdock --chmod=550 ./klipper/start.sh start.sh

ADD --chown=kdock:kdock --keep-git-dir=false "https://github.com/DangerKlippers/danger-klipper.git#master" klipper

RUN <<EOT bash
  source .venv/bin/activate
  pip install --upgrade setuptools pip
  sed -i 's/numpy==.*/numpy==1.26.4/' klipper/scripts/klippy-requirements.txt
  pip install -r klipper/scripts/klippy-requirements.txt
  python -m compileall klipper/klippy
  python klipper/klippy/chelper/__init__.py
  mkdir -p /opt/kdock/data
EOT

FROM kdock AS moonraker

ADD --chown=kdock:kdock --chmod=550 moonraker/start.sh start.sh
ADD --chown=kdock:kdock --chmod=550 moonraker/supervisor/supervisorctl /usr/bin/supervisorctl

ADD --chown=kdock:kdock --keep-git-dir=false "https://github.com/Arksine/moonraker.git#master" moonraker

RUN <<EOT bash
  source .venv/bin/activate
  pip install --upgrade setuptools pip
  pip install -r moonraker/scripts/moonraker-requirements.txt
  pip install -r moonraker/scripts/moonraker-speedups.txt
  mkdir -p /opt/kdock/data
EOT

EXPOSE 7125