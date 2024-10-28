VeraCrypt Volume Mounting Automation Script

Overview:

This Bash script automates the process of mounting VeraCrypt encrypted volumes from external drives using their PARTUUIDs. It dynamically detects connected devices, checks their mount status, and facilitates the mounting of unmounted volumes with user-provided passwords. This script is particularly useful for users who frequently work with encrypted data on external drives, streamlining their workflow while ensuring security.

Key Features:

    Dynamic Device Detection: The script employs the lsblk command to identify devices based on their PARTUUIDs, ensuring flexibility in handling different device names (such as /dev/sdb or /dev/sdc).

    Automatic Mount Point Creation: It automatically creates mount points in the /media directory based on the number of specified PARTUUIDs. If a mount point already exists, the script will skip its creation, preventing errors.

    Mount Status Verification: Before attempting to mount a VeraCrypt volume, the script checks if the volume is already mounted using the veracrypt --text --list command. This prevents unnecessary mount attempts and provides clear feedback to the user.

    User Interaction for Passwords: The script prompts the user for the password needed to mount each VeraCrypt volume. Password input is handled silently for security, ensuring sensitive information is not displayed on the screen.

    Error Handling: If any mounting operation fails, the script provides clear output and allows for continued processing of other devices, thereby enhancing reliability.

Usage Instructions:

    Prerequisites:
        Ensure that VeraCrypt is installed on your system and accessible via the command line.
        The script must be executed in an environment where the user has sufficient permissions to create directories in /media and mount devices.

    Configuration:
        Define the variable TARGET_PARTUUIDS at the top of the script with a comma-separated list of the PARTUUIDs corresponding to the VeraCrypt volumes you wish to mount. For example:

        bash

    TARGET_PARTUUIDS="1,2"


How to Find PARTUUIDs

    Open a Terminal: You can do this by searching for "Terminal" in your applications or using the shortcut Ctrl + Alt + T.

    Run the lsblk Command:

    bash

    lsblk -o PARTUUID,NAME

    This command lists all block devices along with their PARTUUIDs.

    Identify Your Device: Look for your external drive in the output. The PARTUUID will be listed next to the device name (e.g., /dev/sdc1).

    Note the PARTUUIDs: Copy the PARTUUIDs for the partitions you want to mount using VeraCrypt.


Running the Script:

    Execute the script from the terminal:

    bash

        ./automount_veracrypt.sh

        The script will detect connected devices, verify their mount status, prompt for passwords, and attempt to mount any unmounted volumes.

Example Output:

bash

Connected PARTUUID: sdc3
Target drive detected for PARTUUID: 1
Enter the password for device /dev/sdc3: 
Mounting device /dev/sdc3 at /media/vc1...
Successfully mounted /dev/sdc3 at /media/vc1.
Connected PARTUUID: sdc4
Target drive detected for PARTUUID: 2
Enter the password for device /dev/sdc4: 
Mounting device /dev/sdc4 at /media/vc2...
Successfully mounted /dev/sdc4 at /media/vc2.

