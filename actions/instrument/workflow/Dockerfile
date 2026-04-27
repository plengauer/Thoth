FROM alpine:3.23.4
ARG repository
LABEL org.opencontainers.image.source=https://github.com/$repository
COPY ./*.apk /root/
# need bash for exported functions
# need jq and curl because its not a busybox built-in
# need unzip because builtin doesnt support listing files in short form
# need findutils because xargs builtin doesnt support -d parameter
# need coretuls because date builtin doesnt recognize date format of GitHub logs
RUN cd /root && apk add --allow-untrusted bash jq curl parallel unzip findutils coreutils /root/*.apk && rm -rf /root/*.apk /usr/share/opentelemetry_shell/agent.instrumentation.*/*.xz /usr/share/opentelemetry_shell/agent.instrumentation.*/*/
CMD [ "sh", "-c", "exit 1" ]
