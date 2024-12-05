FROM alpine:latest AS kdock

RUN apk add  --no-cache python3 python3-dev py3-pip \
    make gcc g++ gfortran openblas-dev musl-dev libffi-dev newlib \
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

RUN <<EOT bash
  source /opt/kdock/.venv/bin/activate
  pip install --upgrade setuptools pip
  pip install matplotlib numpy scipy
  deactivate
EOT

FROM kdock AS kalico

ADD --chown=kdock:kdock --chmod=550 kalico/start.sh start.sh

ADD --chown=kdock:kdock --keep-git-dir=false "https://github.com/KalicoCrew/kalico.git#main" kalico

RUN <<EOT bash
  source .venv/bin/activate
  sed -i 's/numpy==.*/numpy==1.26.4/' kalico/scripts/klippy-requirements.txt
  pip install -r kalico/scripts/klippy-requirements.txt
  python -m compileall kalico/klippy
  python kalico/klippy/chelper/__init__.py
  mkdir -p /opt/kdock/data
EOT

FROM kdock AS moonraker

ADD --chown=kdock:kdock --chmod=550 moonraker/start.sh start.sh
ADD --chown=kdock:kdock --chmod=550 moonraker/supervisor/supervisorctl /usr/bin/supervisorctl

ADD --chown=kdock:kdock --keep-git-dir=false "https://github.com/Arksine/moonraker.git#master" moonraker

RUN <<EOT bash
  source .venv/bin/activate
  pip install -r moonraker/scripts/moonraker-requirements.txt
  mkdir -p /opt/kdock/data
EOT

EXPOSE 7125
