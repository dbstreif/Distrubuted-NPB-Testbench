#!/usr/bin/env bash
# Collect monitoring summaries from all nodes and compute cluster averages.

HOSTFILE="../hosts"
DEST_DIR="/home/ubuntu/logging/collected_logs"
rm -f "$DEST_DIR"/mpilog_summary_*.csv "$DEST_DIR"/mpilog_summary_all.csv 2>/dev/null
mkdir -p "$DEST_DIR"

echo "[*] Collecting logs from all nodes..."

# 1. Copy each node's summary file
for node in $(awk '{print $1}' "$HOSTFILE"); do
  echo "  -> $node"
  scp -q ubuntu@"$node":/home/ubuntu/logging/output/mpilog_summary.csv "$DEST_DIR/mpilog_summary_${node}.csv" 2>/dev/null \
    || echo "     (warning: failed to fetch from $node)"
done

# 2. Merge into one
cat "$DEST_DIR"/mpilog_summary_*.csv > "$DEST_DIR/mpilog_summary_all.csv"

# 3. Show per-node summaries
echo
echo "=== Per-node averages ==="
cat "$DEST_DIR"/mpilog_summary_*.csv

# 4. Compute cluster-wide averages
echo
echo "=== Cluster-wide average ==="
awk '{cpu+=$2; mem+=$3; util+=$4; kbps+=$5; n++}
     END {
       if (n>0)
         printf "CPU=%.2f%%  MEM=%.2f%%  DISK_UTIL=%.2f%%  KB/s=%.2f\n",
                cpu/n, mem/n, util/n, kbps/n;
       else
         print "No data found."
     }' "$DEST_DIR/mpilog_summary_all.csv"
