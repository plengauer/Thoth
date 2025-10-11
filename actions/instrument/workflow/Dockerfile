FROM alpine:3.22.2
ARG repository
LABEL org.opencontainers.image.source=https://github.com/$repository
COPY ./package.apk /root/package.apk
RUN cd /root && apk add --allow-untrusted bash libeatmydata sudo curl jq busybox /root/package.apk && rm -rf /root/package.apk /usr/share/opentelemetry_shell/agent.instrumentation.*/*.xz /usr/share/opentelemetry_shell/agent.instrumentation.*/*/
CMD [ "sh", "-c", "exit 1" ]
