#!/usr/bin/env bash
# Collect monitoring summaries from all nodes and compute cluster averages.

HOSTFILE="../hosts"
DEST_DIR="/home/ubuntu/logging/collected_logs"

# Cleanup
mkdir -p "$DEST_DIR"
rm -f "$DEST_DIR"/*

echo "[*] Collecting logs from all nodes..."

# 1. Copy each node's summary file
for node in $(awk '{print $1}' "$HOSTFILE"); do
  echo "  -> $node"
  scp -q ubuntu@"$node":/home/ubuntu/logging/output/mpilog_summary.csv "$DEST_DIR/mpilog_summary_node_${node}.csv" 2>/dev/null \
    || echo "     (warning: failed to fetch from $node)"
done

# 2. Merge into one
cat "$DEST_DIR"/mpilog_summary_node_*.csv >> "$DEST_DIR/mpilog_summary_all.csv"

# 3. Show per-node summaries
echo
echo "=== Per-node averages ==="
cat "$DEST_DIR"/mpilog_summary_node_*.csv

# 4. Compute cluster-wide averages
echo
echo "=== Cluster-wide average ==="
awk '{cpu+=$2; mem+=$3; disk1r+=$4; disk1w+=$5; disk2r+=$6; disk2w+=$7; n++}
     END {
       if (n>0)
         printf "CPU=%.2f%%  MEM=%.2f%%  DISK1_READ=%.2fKB/s  DISK1_WRITE=%.2fKB/s  DISK2_READ=%.2fKB/s  DISK2_WRITE=%.2fKB/s\n",
                cpu/n, mem/n, disk1r/n, disk1w/n, disk2r/n, disk2w/n;
       else
         print "No data found."
     }' "$DEST_DIR/mpilog_summary_all.csv"
