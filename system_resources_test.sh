#!/bin/bash

# CPU
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Memory
# The following reads as: used memory - buffer/cache memory / total memory multiplied by a 100
mem_usage=$(free | awk '/Mem/{printf("%.2f", ($3-$6)/$2*100)}')

# Storage
disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | sed 's/%//')

# thresholds to set limit on usage
cpu_threshold=80
mem_threshold=80
disk_threshold=80

# initialize an array to store resources that exceed the threshold
exceeded_resources=()

# check cpu
if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
    exceeded_resources+=("CPU (${cpu_usage}%)")
fi

# check memory
if (( $(echo "$mem_usage > $mem_threshold" | bc -l) )); then
    exceeded_resources+=("Memory (${mem_usage}%)")
fi

# check storage
if (( $(echo "$disk_usage > $disk_threshold" | bc -l) )); then
    exceeded_resources+=("Disk (${disk_usage}%)")
fi

# check if any resources go out their threshold bounds
if [ ${#exceeded_resources[@]} -gt 0 ]; then
    echo "Resource usage exceeds threshold bound!"
    echo "Exceeded resources:"
    for resource in "${exceeded_resources[@]}"; do
        echo "- $resource"
    done
    exit 1
else
    echo "Resource usage is within acceptable limits."
    echo "Current usage:"
    echo "- CPU: ${cpu_usage}%"
    echo "- Memory: ${mem_usage}%"
    echo "- Disk: ${disk_usage}%"
    exit 0
fi

# Note: Exit codes are important in CI/CD pipelines because they signal whether a step has succeeded (exit code 0) or failed (non-zero exit code). This allows the pipeline to make decisions based on the outcome of each step.
