FROM debian:13.0-slim
ARG repository
LABEL org.opencontainers.image.source https://github.com/$repository
COPY ./package.deb /root/package.deb
COPY ./package.json /root/package.json
RUN cd /root && apt-get update && apt-get -y install sed unzip curl wget jq nodejs npm /root/package.deb && npm install && rm -rf /root/package.deb /usr/share/opentelemetry_shell/*/xz package.json node_modules
CMD [ "bash", "-c", "exit 1" ]
