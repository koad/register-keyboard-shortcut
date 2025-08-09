#!/bin/bash

# GNOME Keyboard Shortcut Manager
# This script creates or updates custom keyboard shortcuts in GNOME desktop environments
#
# Usage: ./command.sh "<Name>" "<Command>" "<Binding>"
# Example: ./command.sh "Open Terminal" "gnome-terminal" "<Super>t>"
#
# Key binding examples:
#  - Simple keys: <Super>t, <Control>a, <Alt>p
#  - Multiple modifiers: <Control><Alt>t, <Control><Shift>v
#  - Function keys: <Super>F1, <Alt>F4

# Exit immediately if any command fails
set -e

# Validate input parameters
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <Name> <Command> <Binding>"
  echo "Example: $0 'Open Terminal' 'gnome-terminal' '<Super>t'"
  exit 1
fi

# Store the input parameters
NAME="$1"      # Descriptive name for the shortcut
COMMAND="$2"   # Command to execute when shortcut is triggered
BINDING="$3"   # Key combination to use as the shortcut

# Create a valid schema name: Convert name to lowercase, replace spaces with dashes
SCHEMA_NAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Define the base path for GNOME custom keybindings
BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
# Create the full path for this specific shortcut
NEW_PATH="$BASE_PATH/$SCHEMA_NAME/"

# Retrieve the current list of custom shortcuts from gsettings
CURRENT_LIST=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

# Process the list string by removing brackets for easier manipulation
CURRENT_LIST="${CURRENT_LIST#[}"
CURRENT_LIST="${CURRENT_LIST%]}"

# Check if this shortcut is already registered in the system
if [[ "$CURRENT_LIST" == *"'$NEW_PATH'"* ]]; then
  echo "Shortcut $NAME already exists. Updating..."
else
  # If the shortcut doesn't exist, add it to the list of custom shortcuts
  # Handle the special case where there are no existing shortcuts
  if [ -z "$CURRENT_LIST" ]; then
    UPDATED_LIST="['$NEW_PATH']"  # Create a new list with just our shortcut
  else
    UPDATED_LIST="[$CURRENT_LIST, '$NEW_PATH']"  # Append our shortcut to the existing list
  fi

  # Update the system-wide list of custom shortcuts
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$UPDATED_LIST"
fi

# Configure the shortcut with the provided details
# Each shortcut needs three pieces of information: name, command, and key binding
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH" name "$NAME"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH" command "$COMMAND"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH" binding "$BINDING"

# Provide feedback to the user
echo "Shortcut '$NAME' set with binding $BINDING"
echo "You can now use $BINDING to run: $COMMAND"
