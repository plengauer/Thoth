FROM debian:13.1-slim
ARG repository
LABEL org.opencontainers.image.source https://github.com/$repository
COPY ./package.deb /root/package.deb
RUN cd /root && apt-get update && apt-get -y install eatmydata sudo sed unzip curl wget jq grep /root/package.deb && rm -rf /root/package.deb /usr/share/opentelemetry_shell/agent.instrumentation.*/*.xz /usr/share/opentelemetry_shell/agent.instrumentation.*/*/ && apt-get remove -y npm && apt-get -y autoremove && apt-get -y autoclean && rm -rf /var/cache/apt/archives/* /var/lib/dpkg/info/*
CMD [ "bash", "-c", "exit 1" ]
