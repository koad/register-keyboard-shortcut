#!/bin/bash

# Exit immediately if any command fails
set -e

add() {
  # Store the input parameters
  NAME="$1"    # Descriptive name for the shortcut
  COMMAND="$2" # Command to execute when shortcut is triggered
  BINDING="$3" # Key combination to use as the shortcut

  # Create the full path for this specific shortcut
  NEW_PATH=$(keybinding-path "$NAME")

  # Retrieve the current list of custom shortcuts from gsettings
  CURRENT_LIST=$(current-keybindings)

  # Check if this shortcut is already registered in the system
  if [[ "$CURRENT_LIST" == *"'$NEW_PATH'"* ]]; then
    echo "Shortcut $NAME already exists. Updating..."
  else
    # If the shortcut doesn't exist, add it to the list of custom shortcuts
    # Handle the special case where there are no existing shortcuts
    if [ -z "$CURRENT_LIST" ]; then
      UPDATED_LIST="['$NEW_PATH']" # Create a new list with just our shortcut
    else
      UPDATED_LIST="[$CURRENT_LIST, '$NEW_PATH']" # Append our shortcut to the existing list
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
}

remove() {
  NAME=$1
  NEW_PATH=$(keybinding-path "$NAME")
  CURRENT_LIST=$(current-keybindings)

  if [[ "$CURRENT_LIST" == *"'$NEW_PATH'"* ]]; then
    echo "Removing '$NAME' shortcut..."
    gsettings reset "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH" name
    gsettings reset "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH" command
    gsettings reset "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH" binding
    NEW_LIST=$(remove-value-from-list "$CURRENT_LIST" "'$NEW_PATH'")
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$NEW_LIST]"
    echo "Shortcut '$NAME' successfully removed"
  else
    echo "Shortcut '$NAME' not found. Nothing to remove."
  fi
}

keybinding-path() {
  # Create a valid schema name: Convert name to lowercase, replace spaces with dashes
  SCHEMA_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

  # Define the base path for GNOME custom keybindings
  BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
  # Create the full path for this specific shortcut
  echo "$BASE_PATH/$SCHEMA_NAME/"
}

current-keybindings() {
  local result
  # Retrieve the current list of custom shortcuts from gsettings
  result=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | sed 's/^@as //')

  # Process the list string by removing brackets for easier manipulation
  result="${result#[}"
  result="${result%]}"

  echo "$result"
}

remove-value-from-list() {
  local list="$1"   # e.g. "<value>, <value-1>, <value-2>"
  local target="$2" # e.g. "<value-1>"

  # pad with commas so we can match whole elements reliably
  local result=", ${list}, "

  # remove exact element (with surrounding ", " delimiters)
  result="${result//, ${target}, /, }"

  # trim leading/trailing delimiter padding
  result="${result#, }"
  result="${result%, }"

  echo "$result"
}

usage() {
  SELF=$(basename "$0")
  cat <<USAGE
GNOME Keyboard Shortcut Manager
This script creates, updates, or removes custom keyboard shortcuts in GNOME desktop environments

Usage:
  $SELF add    <Name> <Command> <Binding>
  $SELF remove <Name>
  $SELF        <Name> <Command> <Binding>    (defaults to add)

Examples:
  $SELF add "Open Terminal" "gnome-terminal" "<Super>t"
  $SELF remove "Open Terminal"
  $SELF "Open Terminal" "gnome-terminal" "<Super>t"

Key binding examples:
  - Simple keys: <Super>t, <Control>a, <Alt>p
  - Multiple modifiers: <Control><Alt>t, <Control><Shift>v
  - Function keys: <Super>F1, <Alt>F4

USAGE
}

die() {
  echo "Error: $*" >&2
  usage >&2
  exit 2
}

# Parse arguments
if [[ $# -eq 0 ]]; then
  die "no arguments"
fi

case "${1:-}" in
add)
  [[ $# -eq 4 ]] || die "add expects 3 args: <Name> <Command> <Binding>"
  shift
  add "$@"
  ;;
remove)
  [[ $# -eq 2 ]] || die "remove expects 1 arg: <Name>"
  shift
  remove "$@"
  ;;
-h | --help | help)
  usage
  ;;
*)
  # default command: add <0> <1> <2>
  [[ $# -eq 3 ]] || die "add expects 3 args: <Name> <Command> <Binding>"
  add "$@"
  ;;
esac
