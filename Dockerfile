FROM artifactory.algol60.net/docker.io/library/python:3-alpine

WORKDIR /usr/src
COPY requirements.txt ./

RUN set -ex \
    && apk -U upgrade --no-cache \
    && pip3 install --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir -r requirements.txt

COPY bin/chart-metadata /usr/local/bin/
RUN chmod +x /usr/local/bin/chart-metadata

VOLUME /chart
WORKDIR /chart

ENTRYPOINT [ "/usr/local/bin/chart-metadata" ]
