#!/opt/homebrew/bin/bash

# -- Config -- 
CSV_FILE="device_info.csv"

# Ensure the CSV file has headers if it's newly created
if [[ ! -f "$CSV_FILE" ]]; then
  echo "CSV file not found, creating file with header."
  echo "Product, Board, Serial" > "$CSV_FILE"
fi

# -- Helpers --
# Function to get Fastboot device info
function get_fastboot_info(){
  local serial=""
  local product=""
  local board=""

  # Get serial number
  serial=$(fastboot devices | head -n 1 | awk '{print $1}')

  # if serial is length of 0, then no fastboot device found
  if [[ -z "$serial" ]]; then
    echo "No fastboot device found, please connect one."
    return 1
  fi

  echo "Unlocking bootloader..."
  fastboot flashing unlock
  echo "Unlocking oem..."
  fastboot oem unlock

  # Get product and board info
  product=$(fastboot getvar product 2>&1 | head -n 1 | awk '{print $2}')
  board=$(fastboot getvar board 2>&1 | head -n 1 | awk '{print $2}')

  product=${product#"fastboot: "}
  board=${board#"fastboot: "}

  echo "${product}, ${board}, ${serial}"
  return 0
}

echo "Listening for new Fastboot devices. Press 'q' to quit."
echo "-------------------------------------------------------"

# Initialize a temp variable to track previous device for new device logic
previous_device_info=""
pending=false # Flag to know if we detected a device and waiting for enter

# -- Main Loop --
while true; do
  current_device_info=$(get_fastboot_info)

  if [[ $? -eq 0 ]]; then # Check if a device was successfully found
    if [[ "$current_device_info" != "$previous_device_info" ]]; then # If the currently detected device info is different from the last one,
      if ! $pending; then # Only prompt if we're not already waiting
        echo -e "\nNew device detected: $current_device_info"
        echo "Press 'Enter' to append to CSV, or 'q' to quit monitoring."
        pending=true
      fi
    fi
  else
    # If no device is found, reset previous_device_info and pending flag
    if [[ "$previous_device_info" != "" || "$pending" == true ]]; then
      echo "Device disconnected. Resetting."
    fi
    previous_device_info=""
    pending=false
  fi

  # This makes read non-blocking, allowing the loop to continue checking for devices
  read -t 1 -n 1 key

  if $pending; then
    if [[ -z "$key" ]]; then # If Enter key is pressed 
      echo "$current_device_info" >> "$CSV_FILE" # Append to the CSV file
      echo "Device info logged to $CSV_FILE."
      previous_device_info="$current_device_info" # Update last detected device info
      pending=false # Reset flag
    elif [[ "$key" == "q" ]]; then
      echo -e "\nQuitting..."
      break # Exit the while loop
    else
      # User pressed another key, not Enter or q, while a device was pending
      echo "Invalid input while device pending. Press Enter to log or 'q' to quit."
    fi
  else # No device is detected or no pending action
    if [[ "$key" == "q" ]]; then
      echo -e "\nQuitting..."
      break # Exit the while loop
    elif [[ -n "$key" ]]; then # User pressed a key other than q or Enter
      echo "No device detected, connect a device to save info or press 'q' to quit."
    fi
  fi

  sleep 0.1
done

echo "Script finished. Device information saved to $CSV_FILE"