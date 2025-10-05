# Power Usage Monitor Plugin

A Material Shell plugin that displays real-time power consumption from your device in the status bar.

## Features

- **System Power Monitoring**: Uses Intel RAPL (Running Average Power Limit) to track actual system power consumption
- **Battery Power Fallback**: Falls back to battery power monitoring if RAPL is unavailable
- **Configurable Refresh Rate**: Adjust update frequency from 1-30 seconds
- **Multiple Popout Options**: Choose between Battery Info or Process List when clicking the widget

## Installation

1. Copy this folder to your Material Shell plugins directory
2. Enable the plugin in Material Shell settings
3. **Important**: Grant permissions to read Intel RAPL power data (see below)

## Setting Up RAPL Permissions

The plugin requires read access to `/sys/class/powercap/intel-rapl/` to display system power consumption.

### One-time Setup

Run these commands in your terminal:

```bash
# Apply permissions immediately (temporary - resets on reboot)
sudo chmod 644 /sys/class/powercap/intel-rapl/intel-rapl:*/energy_uj

# Make permissions permanent across reboots
echo 'z /sys/class/powercap/intel-rapl/intel-rapl:*/energy_uj 0444 root root -' | sudo tee /etc/tmpfiles.d/rapl-permissions.conf
sudo systemd-tmpfiles --create /etc/tmpfiles.d/rapl-permissions.conf
```

### Verify It's Working

Test the script manually:

```bash
# First run initializes the measurement
bash power-usage.sh
# Output: ...

# Wait a second, then run again
sleep 1
bash power-usage.sh
# Output: 15.42W (or similar)
```

## Configuration

Access settings through the Material Shell plugin settings:

- **Refresh Interval**: How often to update power usage (1-30 seconds, default: 5)
- **Popup to Open when Clicked**: Choose between Battery Info or Process List

## How It Works

1. **Intel RAPL Mode** (preferred):
   - Reads energy consumption from `/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj`
   - Calculates power by measuring energy difference over time
   - Works on AC power and shows total system consumption
   - Stores state in `/tmp/power-usage-state`

2. **Battery Mode** (fallback):
   - Reads from `/sys/class/power_supply/BAT0/power_now`
   - Or calculates from `voltage_now × current_now`
   - Only shows power when battery is charging/discharging
   - Shows 0W when on AC power with full battery

## Troubleshooting

### Plugin shows "0.00W" constantly

**Cause**: RAPL permissions not set up, and battery is idle (on AC power).

**Solution**: Follow the "Setting Up RAPL Permissions" steps above.

### Plugin shows "N/A"

**Cause**: No power monitoring method available.

**Solution**:
1. Verify your system has Intel RAPL: `ls /sys/class/powercap/intel-rapl/`
2. Check battery exists: `ls /sys/class/power_supply/BAT0/`

### Plugin shows "..." constantly

**Cause**: Cannot read RAPL energy file, or script is only running once.

**Solution**:
1. Check permissions: `cat /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj`
2. If permission denied, run the setup commands above

### Values seem inaccurate

The plugin shows **package power** (CPU + integrated GPU + memory controller). It does not include:
- Discrete GPU power
- Display power
- Storage/peripheral power
- Other system components

For full system power, use a wattmeter or check your power adapter specs.

## Requirements

- Linux system with Intel CPU (for RAPL support)
- Material Shell / Quickshell environment
- `awk` and `bash` (standard on most Linux systems)

## License

This plugin is part of the DankBar Material Shell plugins collection.
