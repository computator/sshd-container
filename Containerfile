FROM docker.io/library/alpine

LABEL org.opencontainers.image.source=https://github.com/computator/sshd-container

RUN apk add --no-cache openssh tini
RUN set -eux; \
	adduser -D ssh; \
	passwd -u ssh; \
	echo "AllowUsers ssh" >> /etc/ssh/sshd_config; \
	echo "Logged in to sshd container shell. Use a SFTP client to access content remotely" > /etc/motd
COPY entrypoint.sh /

WORKDIR /srv
CMD ["/entrypoint.sh"]
EXPOSE 22
