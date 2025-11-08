#!/bin/sh

mpirun --hostfile ../hosts -np 8 --oversubscribe --map-by node --rank-by node ~/npbTests/cg.S.x
