#!/usr/bin/env bash
# Sample CPU, MEM, and disk stats once per second while a job runs.

host=$(hostname)
dev=$(lsblk -ndo NAME,MOUNTPOINT | awk '$2=="/"{print $1;exit}')
logfile="/home/ubuntu/logging/output/mpilog_${host}.csv"
mkdir -p ~/logging/output

(
  while :; do
    ts=$(date +%s)
    cpu=$(mpstat 1 1 | awk '/all/ {print 100-$13}')
    mem=$(free | awk '/Mem:/ {printf "%.2f", ($3/$2)*100}')
    read util kbps <<<$(iostat -dx -k 1 1 | awk -v d="$dev" '$1==d {printf "%.2f %.2f", $12, $3+$4}')
    echo "$ts,$cpu,$mem,${util:-0},${kbps:-0}" > "$logfile"
  done
) &
mon_pid=$!

~/npbTests/cg.$1.x
rc=$?

kill "$mon_pid" 2>/dev/null
sleep 0.2

awk -F, -v h="$host" '
  {cpu+=$2; mem+=$3; util+=$4; kbps+=$5; n++}
  END {
    if(n>0) printf "%s %.2f %.2f %.2f %.2f\n", h, cpu/n, mem/n, util/n, kbps/n;
    else    printf "%s 0 0 0 0\n", h;
  }' "$logfile" > /home/ubuntu/logging/output/mpilog_summary.csv

exit $rc
