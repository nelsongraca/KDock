FROM alpine:latest

ARG REPO=https://github.com/DangerKlippers/danger-klipper.git

RUN apk add  --no-cache python3 python3-dev py3-pip \
    make gcc musl-dev libffi-dev newlib \
    avrdude dfu-util \
    git bash tini shadow && \
    addgroup -g 1000 kdock && \
    adduser -s '/bin/bash' -G kdock -u 1000 -h '/opt/kdock' -D kdock

WORKDIR /opt/kdock

ADD --chown=kdock:kdock --chmod=550 start.sh start.sh

USER kdock

RUN <<EOT bash
  git clone $REPO klipper
  pushd klipper
  git checkout master
  rm -rf .git
  popd
  python -m venv .venv
  source .venv/bin/activate
  pip install --upgrade setuptools pip
  sed -i 's/numpy==.*/numpy==1.26.4/' klipper/scripts/klippy-requirements.txt
  pip install -r klipper/scripts/klippy-requirements.txt
  python -m compileall klipper/klippy
  python klipper/klippy/chelper/__init__.py
  mkdir -p /opt/kdock/data
EOT

VOLUME "/opt/kdock/data"

ENTRYPOINT ["/sbin/tini", "--"]

#user root

CMD ["bash", "/opt/kdock/start.sh"]
