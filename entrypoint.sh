#!/bin/sh
ssh-keygen -A
if [ -n "$SSH_USER_PASS_FILE" ]; then
	if [ ! -f "$SSH_USER_PASS_FILE" ]; then
		echo "ERROR: file specified by SSH_USER_PASS_FILE does not exist!" >&2
		exit 1
	fi
	echo "Setting password for ssh user from file SSH_USER_PASS_FILE"
	sed 's/^/ssh:/' "$SSH_USER_PASS_FILE" | chpasswd
elif [ -n "${SSH_USER_PASS+1}" ]; then  # evaluates to '' if unset or '1' if set
	echo "Setting password for ssh user from SSH_USER_PASS"
	printenv SSH_USER_PASS | sed 's/^/ssh:/' | chpasswd
else
	echo "WARNING: No password is set for the ssh user! Set one with SSH_USER_PASS_FILE|SSH_USER_PASS or use Public Key Authentication" >&2
fi
exec tini -- /usr/sbin/sshd -D -e
