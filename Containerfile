FROM docker.io/library/alpine

LABEL org.opencontainers.image.source=https://github.com/computator/sshd-container

RUN apk add --no-cache openssh tini
RUN set -eux; \
	adduser -D ssh; \
	passwd -u ssh; \
	sed -i '/^AuthorizedKeysFile/ d' /etc/ssh/sshd_config; \
	echo "AllowUsers ssh" >> /etc/ssh/sshd_config; \
	echo "AuthorizedKeysFile /etc/ssh/authorized_keys .ssh/authorized_keys" >> /etc/ssh/sshd_config; \
	echo "Logged in to sshd container shell. Use a SFTP client to access content remotely" > /etc/motd; \
	echo '[ -n "$SSH_CONNECTION" ] && [ "$(whoami)" = "ssh" ] && cd /srv' > /etc/profile.d/ssh_chdir.sh
COPY entrypoint.sh /

WORKDIR /srv
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22
