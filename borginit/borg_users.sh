#!/bin/sh
set -e

create_user() {
    local USERNAME="$1"
    local USERID="$2"

    adduser -D -u $USERID $USERNAME
    sed -i "/^$USERNAME:!/{s/!/*/;}" /etc/shadow
    mkdir -p /home/$USERNAME/.ssh
    touch /home/$USERNAME/.ssh/authorized_keys
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh
    chmod 600 /home/$USERNAME/.ssh/authorized_keys
}

handle_file() {
    TARGET_USER=""
    while IFS= read -r line; do
        if [ -z "$line" ]; then
            TARGET_USER=""
            continue
        fi
        if [ -z "$TARGET_USER" ]; then
            TARGET_USER=$(echo "$line" | cut -d':' -f1)
            USERID=$(echo "$line" | cut -d':' -f2)
            echo "Creating user $line"
            create_user "$TARGET_USER" "$USERID"        
            continue
        fi

        echo "Updating $TARGET_USER authorized_keys"
        echo "$line" >> /home/$TARGET_USER/.ssh/authorized_keys

    done < "$1"
}

# Exit if at least one user is already present
# Needed for container restart
if [ -n "$(ls -A /home)" ]; then
    exit 0
fi

for file in /config/*.borgusers; do
    if [ -f "$file" ]; then
        echo "Handling users file $file"
        handle_file "$file"
    fi
done
