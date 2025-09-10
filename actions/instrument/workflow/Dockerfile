FROM debian:13.1-slim
ARG repository
LABEL org.opencontainers.image.source https://github.com/$repository
COPY ./package.deb /root/package.deb
COPY ./package.json /root/package.json
RUN cd /root && apt-get update && apt-get -y install eatmydata sudo sed unzip curl wget jq grep /root/package.deb npm && npm install && rm -rf /root/package.deb /usr/share/opentelemetry_shell/agent.instrumentation.*/*.xz /usr/share/opentelemetry_shell/agent.instrumentation.*/*/ package.json package-lock.json node_modules && apt-get remove -y npm && apt-get -y autoremove && apt-get -y autoclean && rm -rf /var/cache/apt/archives/* /var/lib/dpkg/info/*
CMD [ "bash", "-c", "exit 1" ]
