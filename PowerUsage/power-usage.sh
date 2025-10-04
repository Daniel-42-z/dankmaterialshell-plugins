#!/bin/bash
# Fetch power usage in watts
power_usage=$(cat /sys/class/power_supply/BAT0/power_now | xargs | awk '{print $1/1e6 }')
rounded_power_usage=$(printf "%.2f" "$power_usage")
echo "${rounded_power_usage}W"
