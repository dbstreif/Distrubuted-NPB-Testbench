#!/usr/bin/env bash
# Sample CPU, MEM, and disk stats while a job runs.

# Reject non-arg
if [ -z "$1" ]; then
    echo "Supply Arg!"
    exit 0
fi

DEST_DIR="/home/ubuntu/logging/output"

# Cleanup
mkdir -p "$DEST_DIR"
rm -f "$DEST_DIR"/*
echo "Cleaned Dirs"

host=$(hostname)
dev=$(lsblk -ndo NAME,MOUNTPOINT | awk '$2=="/"{print $1;exit}')
logfile="/home/ubuntu/logging/output/mpilog_${host}.csv"

# Start sampling
echo "Get proc"
until pgrep -f "cg.$1.x" >/dev/null; do
    sleep 0.3
done
echo "Proc got"

pid_exist=$(pgrep -n -f "cg.$1.x" || true)
count=0
echo "Exist PID: $pid_exist"
echo "Monitoring..."
while [ -n "$pid_exist" ]; do
    ts=$(date +%s)
    cpu=$(iostat | awk 'FNR == 4 {print $1}')
    mem=$(free | awk '/Mem:/ {printf "%.2f", ($3/$2)*100}')
    disk1r=$(iostat | awk '/xvda/ {print $3}')
    disk1w=$(iostat | awk '/xvda/ {print $4}')
    disk2r=$(iostat | awk '/xvdb/ {print $3}')
    disk2w=$(iostat | awk '/xvdb/ {print $4}')
    echo "$ts,$cpu,$mem,$disk1r,$disk1w,$disk2r,$disk2w" >> "$logfile"
    ((count++))
    sleep 0.3
    pid_exist=$(pgrep -n -f "cg.$1.x" || true)
done
echo "Stopped Monitoring"
echo "Sample Count: $count"

sleep 0.5

echo "Aggregating Results..."

# Aggregate Results
awk -F, -v h="$host" '
  {cpu+=$2; mem+=$3; disk1r+=$4; disk1w+=$5; disk2r+=$6; disk2w+=$7; n++}
  END {
    if(n>0) printf "%s %.2f %.2f %.2f %.2f %.2f %.2f\n", h, cpu/n, mem/n, disk1r/n, disk1w/n, disk2r/n, disk2w/n;
    else    printf "%s 0 0 0 0 0 0\n", h;
  }' "$logfile" > /home/ubuntu/logging/output/mpilog_summary.csv

echo "Done"
