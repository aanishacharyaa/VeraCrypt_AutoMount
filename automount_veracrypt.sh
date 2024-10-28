#!/bin/bash
 
# Specify the PARTUUIDs of the external drives as a comma-separated string
TARGET_PARTUUIDS="1,2"  # Replace with the actual PARTUUIDs

# Function to find the device associated with a given PARTUUID
find_device_by_partuuid() {
    local partuuid=$1
    # Use lsblk to find the device name based on PARTUUID
    lsblk -o PARTUUID,NAME | grep "$partuuid" | awk '{print $2}' | tr -d '─' | tr -d '├' | tr -d ' '  # Remove unwanted characters
}

# Function to get a list of currently mounted VeraCrypt volumes
get_mounted_veracrypt_volumes() {
    veracrypt --text --list | awk '{print $2}' | grep '/dev/sd' | tr -d ' '  # Adjust as needed for your environment
}

# Function to mount VeraCrypt volumes
mount_veracrypt() {
    local device=$1
    local mount_point=$2
    local password=$3
    local slot=$4

    echo "Mounting device $device at $mount_point..."
    if veracrypt --text --mount "/dev/$device" "$mount_point" --password "$password" --pim 0 --keyfiles "" --protect-hidden no --slot "$slot" --verbose; then
        echo "Successfully mounted $device at $mount_point."
    else
        echo "Failed to mount $device at $mount_point."
        return 1  # Indicate failure without exiting the script
    fi
}

# Split TARGET_PARTUUIDS into an array
IFS=',' read -r -a PARTUUID_ARRAY <<< "$TARGET_PARTUUIDS"

# Create directories for mounting dynamically based on the number of PARTUUIDs
for i in "${!PARTUUID_ARRAY[@]}"; do
    MOUNT_POINT="/media/vc$((i + 1))"
    
    # Create mount directory only if it doesn't already exist
    sudo mkdir -p "$MOUNT_POINT" || { echo "Failed to create $MOUNT_POINT"; exit 1; }
done

# Get a list of currently mounted VeraCrypt volumes
MOUNTED_VOLUMES=$(get_mounted_veracrypt_volumes)

# Iterate over each PARTUUID to check for connected devices and mount them
for i in "${!PARTUUID_ARRAY[@]}"; do
    PARTUUID="${PARTUUID_ARRAY[$i]}"
    CONNECTED_DEVICE_PARTUUID=$(find_device_by_partuuid "$PARTUUID")
    
    # Debug output
    echo "Connected PARTUUID: $CONNECTED_DEVICE_PARTUUID"

    # Check if the target PARTUUID matches the connected device
    if [ -n "$CONNECTED_DEVICE_PARTUUID" ]; then
        echo "Target drive detected for PARTUUID: $PARTUUID"
        
        # Determine the mount point based on the index
        MOUNT_POINT="/media/vc$((i + 1))"

        # Check if the device is already mounted
        if echo "$MOUNTED_VOLUMES" | grep -q "/dev/$CONNECTED_DEVICE_PARTUUID"; then
            echo "Device $CONNECTED_DEVICE_PARTUUID is already mounted. Skipping mounting."
            continue  # Skip to the next iteration if already mounted
        fi

        # Prompt for the password for VeraCrypt
        echo -n "Enter the password for device $CONNECTED_DEVICE_PARTUUID: "
        read -s PASSWORD  # Silent input
        echo  # Print a new line for better formatting

        # Attempt to mount the device
        mount_veracrypt "$CONNECTED_DEVICE_PARTUUID" "$MOUNT_POINT" "$PASSWORD" "$((i + 1))"
    else
        echo "No connected device for PARTUUID: $PARTUUID."
    fi
done