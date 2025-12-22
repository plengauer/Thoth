FROM alpine:3.23.2
ARG repository
LABEL org.opencontainers.image.source=https://github.com/$repository
COPY ./package.apk /root/package.apk
RUN cd /root && apk add eatmydata sudo sed unzip curl wget jq grep parallel /root/package.apk && rm -rf /root/package.apk /usr/share/opentelemetry_shell/agent.instrumentation.*/*.xz /usr/share/opentelemetry_shell/agent.instrumentation.*/*/
CMD [ "sh", "-c", "exit 1" ]
