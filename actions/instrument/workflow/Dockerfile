FROM debian-slim:13.0-slim
COPY ./package.deb /root/package.deb
RUN apt-get update && apt-get -y install sed curl wget jq nodejs /root/package.deb
CMD [ "bash", "-c", "exit 1" ]
