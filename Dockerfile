FROM alpine:3.21.0

COPY borginit /borginit/

RUN <<EOF
mkdir /host_keys
chown root:root /host_keys
chown -R root:root /borginit
chmod 700 /host_keys
chmod 700 /borginit/*

mkdir /config
chown -R root:root /config
chmod -R 700 /config

apk add openssh-server=9.9_p1-r2 borgbackup==1.4.0-r0
# Changing security concerning configuration for ssh process
sed -i 's|#HostKey /etc/ssh/ssh_host_rsa_key|HostKey /host_keys/ssh_host_rsa_key|' /etc/ssh/sshd_config
sed -i 's|#HostKey /etc/ssh/ssh_host_ecdsa_key|HostKey /host_keys/ssh_host_ecdsa_key|' /etc/ssh/sshd_config
sed -i 's|#HostKey /etc/ssh/ssh_host_ed25519_key|HostKey /host_keys/ssh_host_ed25519_key|' /etc/ssh/sshd_config
sed -i 's|#PermitRootLogin prohibit-password|PermitRootLogin no|' /etc/ssh/sshd_config
sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config
EOF

EXPOSE 22/tcp
ENTRYPOINT ["/borginit/start.sh"]
CMD ["-e"]