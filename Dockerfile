FROM python:3.14 AS builder

RUN python3 -m venv /opt/virtualenv \
    && apt-get update \
    && apt-get install build-essential

COPY requirements.txt ./
RUN /opt/virtualenv/bin/pip3 install --no-cache-dir -r requirements.txt

COPY patch .

RUN cd /opt/virtualenv/lib/python3.14/site-packages/ && \
    patch -p1 < /patch

FROM python:3.14-slim

RUN useradd -r -m sungather

COPY --from=builder /opt/virtualenv /opt/virtualenv

USER sungather

WORKDIR /opt/sungather

COPY --chown=sungather SunGather/ .

VOLUME /logs
VOLUME /config
COPY --chown=sungather SunGather/config-example.yaml /config/config.yaml

CMD [ "/opt/virtualenv/bin/python", "sungather.py", "-c", "/config/config.yaml", "-l", "/logs/" ]
