FROM alpine:3.23.2
ARG repository
LABEL org.opencontainers.image.source=https://github.com/$repository
COPY ./package.apk /root/package.apk
# need bash for exported functions
# need jq and curl because its not a busybox built-in
# need unzip because builtin doesnt support listing files in short form
# need findutils because xargs builtin doesnt support -d parameter
# need coretuls because date builtin doesnt recognize date format of GitHub logs
RUN cd /root && apk add bash jq curl parallel unzip findutils coreutils /root/package.apk && rm -rf /root/package.apk /usr/share/opentelemetry_shell/agent.instrumentation.*/*.xz /usr/share/opentelemetry_shell/agent.instrumentation.*/*/
CMD [ "sh", "-c", "exit 1" ]
