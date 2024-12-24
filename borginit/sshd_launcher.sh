#!/bin/sh
stop() {
    echo "Received SIGINT or SIGTERM. Shutting down sshd process"
    pid=$(cat /run/sshd.pid)
    kill -SIGTERM "${pid}"
}

wait_process() {
    PID="$1"
    echo "Waiting for pid $PID"
    while true; do
        (kill -0 "$PID" 2>/dev/null && sleep 1) || break
    done
}

wait_processes() {
    PIDS="$1"
    for pid in $PIDS; do
        wait_process $pid
    done
}

trap stop SIGINT SIGTERM
/usr/sbin/sshd -D "$@" 2>&1 &
SSH_DAEMON_PID=$!
echo "Ssh daemon had PID: $SSH_DAEMON_PID"
wait "$SSH_DAEMON_PID"
CHILD_PROCESSES=$(pstree -p "$SSH_DAEMON_PID" | grep -o '([0-9]\+)' | tr -d '()' | xargs)
echo "Currently are open this child sshd processes: $CHILD_PROCESSES"
echo "Waiting"
wait_processes "$CHILD_PROCESSES"