#!/bin/sh

[ "$1" = "sshd" ] && shift
[ -n "$1" ] && [ "${1#-}" = "${1}" ] && exec "$@"

set -eu

# generate any missing host keys
ssh-keygen -A

# set authorized keys
if [ -n "${SSH_AUTHORIZED_KEYS_FILE:-}" ]; then
	if [ ! -f "$SSH_AUTHORIZED_KEYS_FILE" ]; then
		echo "ERROR: file specified by SSH_AUTHORIZED_KEYS_FILE does not exist!" >&2
		exit 1
	fi
	echo "Setting authorized keys from file SSH_AUTHORIZED_KEYS_FILE"
	install -m 444 "$SSH_AUTHORIZED_KEYS_FILE" /etc/ssh/authorized_keys
elif [ -n "${SSH_AUTHORIZED_KEYS+1}" ]; then  # evaluates to '' if unset or '1' if set
	echo "Setting authorized keys from SSH_AUTHORIZED_KEYS"
	printenv SSH_AUTHORIZED_KEYS > /etc/ssh/authorized_keys
	chmod 444 /etc/ssh/authorized_keys
else
	no_ssh_keys=1
	# enable password auth since no keys
	export SSH_PASS_AUTH=1
fi

# log any authorized keys
if [ -f /etc/ssh/authorized_keys ]; then
	echo "Configured authorized keys:"
	cat /etc/ssh/authorized_keys
fi

if [ -z "${SSH_PASS_AUTH:-}" ]; then
	# disable password auth
	echo "AuthenticationMethods publickey" >> /etc/ssh/sshd_config
else
	# set password
	if [ -n "${SSH_USER_PASS_FILE:-}" ]; then
		if [ ! -f "$SSH_USER_PASS_FILE" ]; then
			echo "ERROR: file specified by SSH_USER_PASS_FILE does not exist!" >&2
			exit 1
		fi
		echo "Setting password for ssh user from file SSH_USER_PASS_FILE"
		{ echo -n "ssh:"; cat "$SSH_USER_PASS_FILE"; } | chpasswd
	elif [ -n "${SSH_USER_PASS+1}" ]; then  # evaluates to '' if unset or '1' if set
		echo "Setting password for ssh user from SSH_USER_PASS"
		{ echo -n "ssh:"; printenv SSH_USER_PASS; } | chpasswd
	elif [ -n "${no_ssh_keys:-}" ]; then
		echo "WARNING: No password is set for the ssh user! Use Public Key" \
			"Authentication (with SSH_AUTHORIZED_KEYS|SSH_AUTHORIZED_KEYS_FILE) or set a password" \
			"with SSH_USER_PASS_FILE|SSH_USER_PASS" >&2
	fi
fi

exec tini -- /usr/sbin/sshd -D -e "$@"
