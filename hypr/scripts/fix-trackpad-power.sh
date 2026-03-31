#!/bin/bash
# Fix for I2C trackpad wake-up latency on Asus laptops
# This disables aggressive power management for I2C HID devices

# Find I2C HID devices
for device in /sys/bus/i2c/drivers/i2c_hid_acpi/*:*; do
    if [ -d "$device" ]; then
        echo "Disabling autosuspend for $device"
        echo "on" > "$device/power/control" 2>/dev/null
    fi
done

# Also handle generic HID devices
for device in /sys/bus/usb/drivers/usbhid/*:*; do
    if [ -d "$device" ]; then
        echo "Disabling autosuspend for $device"
        echo "on" > "$device/power/control" 2>/dev/null
    fi
done

# Set autosuspend delay to -1 (disabled) for input devices
for device in /sys/bus/i2c/devices/*; do
    if [ -d "$device/power" ]; then
        echo "-1" > "$device/power/autosuspend_delay_ms" 2>/dev/null
    fi
done

echo "Trackpad power management fixes applied"
