#!/bin/sh
set -e

if [ -z "$(ls -A /ssh_certs)" ]; then
    ssh-keygen -b 4096 -t rsa -f "/ssh_certs/ssh_host_rsa_key" -C "borgbackup_server" -N "" > /dev/null 2>&1;
    ssh-keygen -b 521 -t ecdsa -f "/ssh_certs/ssh_host_ecdsa_key" -C "borgbackup_server" -N "" > /dev/null 2>&1;
    ssh-keygen -b 521 -t ed25519 -f "/ssh_certs/ssh_host_ed25519_key" -C "borgbackup_server" -N "" > /dev/null 2>&1;
fi

echo "Host key creation correctly executed"