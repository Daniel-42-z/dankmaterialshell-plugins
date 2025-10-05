#!/bin/bash

# Temporary file to store previous energy reading
state_file="/tmp/power-usage-state"
rapl_path="/sys/class/powercap/intel-rapl/intel-rapl:0"

# Try Intel RAPL for system power consumption (more accurate and works on AC)
if [ -r "${rapl_path}/energy_uj" ]; then
	current_energy=$(cat "${rapl_path}/energy_uj" 2>/dev/null)
	current_time=$(date +%s%N)

	if [ -f "$state_file" ] && [ -n "$current_energy" ]; then
		# Read previous measurement
		IFS=',' read -r prev_energy prev_time < "$state_file"

		# Calculate power: (energy_diff / time_diff)
		# energy_uj is in microjoules, time is in nanoseconds
		energy_diff=$((current_energy - prev_energy))
		time_diff=$((current_time - prev_time))

		# Handle counter wrap-around
		if [ $energy_diff -lt 0 ]; then
			max_range=$(cat "${rapl_path}/max_energy_range_uj" 2>/dev/null || echo "0")
			if [ "$max_range" -gt 0 ]; then
				energy_diff=$((max_range + energy_diff))
			fi
		fi

		if [ $time_diff -gt 0 ] && [ $energy_diff -ge 0 ]; then
			# Power (W) = Energy (μJ) / Time (ns) = (μJ / ns) = (J/s) / 1000 = mW / 1000
			power_watts=$(awk "BEGIN {printf \"%.2f\", ($energy_diff / $time_diff) * 1000}")
			echo "${current_energy},${current_time}" > "$state_file"
			echo "${power_watts}W"
			exit 0
		fi
	fi

	# First run or invalid data - store current state
	echo "${current_energy},${current_time}" > "$state_file"
	echo "..."
	exit 0
fi

# Fallback to battery power monitoring
bat_info_path="/sys/class/power_supply/BAT0"

# Check if the direct power reading is available
if [ -f "${bat_info_path}/power_now" ]; then
	# Direct power reading exists, so read and convert it
	# The value is in microwatts, so divide by 1,000,000 to get watts
	power_microwatts=$(cat "${bat_info_path}/power_now" | xargs)
	power_watts=$(echo "${power_microwatts}" | awk '{printf "%.2f", $1/1e6}')
	echo "${power_watts}W"
	exit 0
fi

# Direct power reading not available, check for voltage file
if [ -f "${bat_info_path}/voltage_now" ]; then
	# Voltage file exists, now check for current file
	if [ -f "${bat_info_path}/current_now" ]; then
		# Both voltage and current files exist
		# Read voltage in microvolts and convert to volts
		voltage_microvolts=$(cat "${bat_info_path}/voltage_now" | xargs)
		voltage_volts=$(echo "${voltage_microvolts}" | awk '{print $1/1e6}')

		# Read current in microamps and convert to amps
		current_microamps=$(cat "${bat_info_path}/current_now" | xargs)
		current_amps=$(echo "${current_microamps}" | awk '{print $1/1e6}')

		# Calculate power: Power (watts) = Voltage (volts) × Current (amps)
		power_watts=$(echo "${voltage_volts} ${current_amps}" | awk '{printf "%.2f", $1 * $2}')
		echo "${power_watts}W"
		exit 0
	fi
fi

# Neither direct power nor voltage/current combination is available
echo "N/A"
exit 1
