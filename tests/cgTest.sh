#!/bin/sh

# Non-arg/usage msg
if [ -z "$1" ]; then
    echo "usage: ./cgTest.sh suite"
    echo "Available suites: A, B, C, D, E, S, W"
    echo "Warning, suite parameter is not validated, make sure suite input matches available options!"
    exit 0
fi

for host in $(awk '{print $1}' ../hosts); do
    echo "Init Monitoring for node: $host"
    ssh "ubuntu@$host" "~/logging/monitor_node.sh $1 > ~/logging/output/monitor-node_${host}.log 2>&1 &"
done

# Wait for Monitoring Proc to start...
echo "Wait for Mon proc to start on nodes..."
sleep 5

# Start
mpirun --hostfile ../hosts -np 8 --oversubscribe --map-by node --rank-by node ~/npbTests/"cg.$1.x"

# Wait for Monitoring Proc to finish...
echo "Wait for Mon proc to finish on nodes..."
sleep 5

# Collect from nodes
~/logging/collect.sh
echo "Done"
