#!/bin/sh
mpirun --hostfile ../hosts -np 8 --oversubscribe --map-by node --rank-by node \
  bash -c '
    if [ "${OMPI_COMM_WORLD_LOCAL_RANK:-0}" = 0 ]; then
      ~/logging/monitor_node.sh C
    else
      ~/npbTests/cg.C.x
    fi
  '
~/logging/collect.sh
