#!/bin/sh
set -e
/borginit/host_keys.sh
/borginit/borg_users.sh
exec /borginit/sshd_launcher.sh "$@"