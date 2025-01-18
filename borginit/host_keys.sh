#!/bin/sh
set -e

if [ -z "$(ls -A /host_keys)" ]; then
    ssh-keygen -b 4096 -t rsa -f "/host_keys/ssh_host_rsa_key" -C "borgbackup_server" -N "" > /dev/null 2>&1;
    ssh-keygen -b 521 -t ecdsa -f "/host_keys/ssh_host_ecdsa_key" -C "borgbackup_server" -N "" > /dev/null 2>&1;
    ssh-keygen -b 521 -t ed25519 -f "/host_keys/ssh_host_ed25519_key" -C "borgbackup_server" -N "" > /dev/null 2>&1;
    
    echo "Host key creation correctly executed"
fi