#!/bin/bash

# function to get CPU usage using /proc/stat for better accuracy
get_cpu_usage() {
    awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print int(($2+$4-u1) * 100 / (t-t1))}' \
        <(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat)
}

# Memory
mem_usage=$(free | awk '/Mem/{printf("%.2f", $3/$2*100)}')

# Storage
disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | sed 's/%//')

# Thresholds to set limit on usage
cpu_threshold=80
mem_threshold=80
disk_threshold=80

# Initialize an array to store resources that exceed the threshold
exceeded_resources=()

# Check CPU (using the new function)
cpu_usage=$(get_cpu_usage)
if (( cpu_usage > cpu_threshold )); then
    exceeded_resources+=("CPU (${cpu_usage}%)")
fi

# Check memory
mem_usage_int=${mem_usage%.*}
if (( mem_usage_int > mem_threshold )); then
    exceeded_resources+=("Memory (${mem_usage}%)")
fi

# Check storage
if (( disk_usage > disk_threshold )); then
    exceeded_resources+=("Disk (${disk_usage}%)")
fi

# Function to log results
log_results() {
    echo "$(date): $1" >> /tmp/system_resources_test.log
}

# Check if any resources go out their threshold bounds
if [ ${#exceeded_resources[@]} -gt 0 ]; then
    message="Resource usage exceeds threshold bound! Exceeded resources:"
    for resource in "${exceeded_resources[@]}"; do
        message+="\n- $resource"
    done
    log_results "$message"
    echo -e "$message"
    exit 1
else
    message="Resource usage is within acceptable limits. Current usage:"
    message+="\n- CPU: ${cpu_usage}%"
    message+="\n- Memory: ${mem_usage}%"
    message+="\n- Disk: ${disk_usage}%"
    log_results "$message"
    echo -e "$message"
    exit 0
fi