# SSHD Container

A SSHD container image for use as a SFTP server or for limited shell access.

# Example Usage

Start a temporary server that shares the `data` subdirectory of the current directory with the password `TempSFTPpass1!`:
```sh
docker run --rm -i -v ./data:/srv -e SSH_USER_PASS='TempSFTPpass1!' -p 2022:22 ghcr.io/computator/sshd
```

To access the temporary server from above:
```sh
# SFTP
sftp -P 2022 ssh@CONTAINER_HOST_IP:/srv/
# SSH
ssh -p 2022 ssh@CONTAINER_HOST_IP
```

# Configuration

The image is configured to only allow SSH access using the `ssh` user. It is assumed any content to share will be mounted on `/srv`. The container has `/srv` set as the default working directory, and will `cd` to there on interactive SSH login.

## Authentication

No authentication is configured by default. The image supports configuration of password and public key authentication.

### Public Key

This is the preferred mode of authentication, and if configured it will (by default) disable password authentication. Public keys are configured via the usual method for SSH of adding public keys to an authorized keys file. The authorized keys can be set using one of two environment variables:

#### `SSH_AUTHORIZED_KEYS_FILE`

This can be set to the path of a file containing authorized keys to accept. The contents of this file will be written to the `/etc/ssh/authorized_keys` file. Note that if this variable is set `SSH_AUTHORIZED_KEYS` will be ignored.

Example usage:
```sh
docker run ... -v ./my_authkeys.txt:/run/my_authkeys.txt:ro -e SSH_AUTHORIZED_KEYS_FILE=/run/my_authkeys.txt ...
```

#### `SSH_AUTHORIZED_KEYS`

This can be set to a direct string of the authorized key(s) to accept. The contents of this variable will be written to the `/etc/ssh/authorized_keys` file. Note that `SSH_AUTHORIZED_KEYS_FILE` overrides this, and if it is set `SSH_AUTHORIZED_KEYS` will be ignored.

Example usage:
```sh
docker run ... -e SSH_AUTHORIZED_KEYS='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCYUpcEw93WLYDYXOAcrYx4qObXECdS0n0NrwnXnotO' ...
```

### Password

Password authentication is the fallback method if public key authentication is not configured. It is disabled by default if `SSH_AUTHORIZED_KEYS_FILE|SSH_AUTHORIZED_KEYS` is set, however it can be manually enabled to use password and public key authentication at the same time.

#### `SSH_PASS_AUTH`

This variable can be set to enable password authentication as well as to enable configuation using the below environment variables. This variable is automatically set if neither of `SSH_AUTHORIZED_KEYS_FILE|SSH_AUTHORIZED_KEYS` are configured, but can also be set manually to enable both password and public key authentication.

Example usage:
```sh
docker run ... -e SSH_PASS_AUTH=1 ...
```

#### `SSH_USER_PASS_FILE`

This can be set to the path of a file containing the plaintext password to set for the `ssh` user. Note that if this variable is set `SSH_USER_PASS` will be ignored.

Example usage:
```sh
docker run ... -v ./ssh_password.txt:/run/ssh_password.txt:ro -e SSH_USER_PASS_FILE=/run/ssh_password.txt ...
```

#### `SSH_USER_PASS`

This can be set to the plaintext password to set for the `ssh` user. Note that depending on the method used to set `SSH_USER_PASS` that other users or processes on the system may be able to discover the password. In particular it may be visible in `ps`, `docker ps` or `docker inspect`. For this reason it is preferable to use `SSH_USER_PASS_FILE`, which when set will cause `SSH_USER_PASS` to be ignored.

Example usage:
```sh
docker run ... -e SSH_USER_PASS=sshpass123 ...
```

## Host Keys

This image does not contain any hostkeys. When the container starts or is replaced it will generate new hostkeys using `ssh-keygen -A`. To preserve hostkeys across container runs you can mount a volume on the `/etc/ssh` directory.

```sh
docker run ... -v my-ssh-confdata:/etc/ssh ...
```
