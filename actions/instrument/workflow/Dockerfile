FROM debian:13.0-slim
ARG repository
LABEL org.opencontainers.image.source https://github.com/$repository
COPY ./package.deb /root/package.deb
COPY ./package.json /root/package.json
RUN cd /root && apt-get update && apt-get -y install sudo sed unzip curl wget jq /root/package.deb npm && npm install && rm -rf /root/package.deb /usr/share/opentelemetry_shell/*/xz package.json node_modules && apt-get remove -y npm && apt-get -y autoremove && apt-get -y autoclean && rm -rf /var/cache/apt/archives/* /var/lib/dpkg/info/*
CMD [ "bash", "-c", "exit 1" ]
