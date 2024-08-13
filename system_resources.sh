#!/bin/bash

# CPU
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Memory
mem_usage=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')

# Storage
disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | sed 's/%//')

# thresholds to set limit on usage
cpu_threshold=70
mem_threshold=70
disk_threshold=70

# checks usage rates against the thresholds. result gets piped into `bc -l` which is a calculator that returns either 1 or 0 (True or False)
if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )) || 
   (( $(echo "$mem_usage > $mem_threshold" | bc -l) )) || 
   (( $(echo "$disk_usage > $disk_threshold" | bc -l) )); then
    echo "Resource usage exceeds threshold!"
    exit 1
else
    echo "Resource usage is within acceptable limits."
    exit 0
fi