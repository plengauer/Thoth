FROM alpine:3.22.1
ARG repository
LABEL org.opencontainers.image.source https://github.com/$repository
COPY ./package.apk /root/package.apk
RUN cd /root && apk add --allow-untrusted sudo sed unzip curl wget jq grep /root/package.deb && rm -rf /root/package.deb /usr/share/opentelemetry_shell/agent.instrumentation.*/*.xz /usr/share/opentelemetry_shell/agent.instrumentation.*/*/
CMD [ "sh", "-c", "exit 1" ]
