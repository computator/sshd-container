#!/bin/sh
ssh-keygen -A
if [ -n "${SSH_ACCOUNT_PASS+1}" ]; then  # evaluates to '' if unset or '1' if set
	echo "Setting password for ssh user from SSH_ACCOUNT_PASS"
	printenv SSH_ACCOUNT_PASS | sed 's/^/ssh:/' | chpasswd
else
	echo "WARNING: No password is set for the ssh user! Set one with SSH_ACCOUNT_PASS or use Public Key Authentication" >&2
fi
exec tini -- /usr/sbin/sshd -D -e
