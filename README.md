# GNOME Keyboard Shortcut Manager

A simple bash script for creating and managing custom keyboard shortcuts in GNOME desktop environments.

## Overview

This utility makes it easy to register and update custom keyboard shortcuts through the command line, without having to navigate through the GNOME Settings GUI. It's particularly useful for:

- Setting up consistent shortcuts across multiple machines
- Automating shortcut configuration in scripts
- Quickly adding new shortcuts for frequently used applications

## Requirements

- GNOME desktop environment (tested on GNOME 3.36+)
- `gsettings` command-line tool (usually pre-installed with GNOME)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/koad/register-keyboard-shortcut.git
   cd register-keyboard-shortcut
   ```

2. Make the script executable:
   ```bash
   chmod +x command.sh
   ```

3. Optional: Move to a directory in your PATH for easier access:
   ```bash
   sudo mv command.sh /usr/local/bin/register-shortcut
   ```

## Usage

```bash
./command.sh "<Name>" "<Command>" "<Binding>"
```

Or if you installed it to your PATH:

```bash
register-shortcut "<Name>" "<Command>" "<Binding>"
```

### Parameters:

- **Name**: A descriptive name for the shortcut (e.g., "Open Terminal")
- **Command**: The command to execute (e.g., "gnome-terminal")
- **Binding**: The key combination to use (e.g., "<Super>t")

### Examples:

```bash
# Open terminal with Super+T
./command.sh "Open Terminal" "gnome-terminal" "<Super>t"

# Open Firefox with Super+F
./command.sh "Open Firefox" "firefox" "<Super>f"

# Open system monitor with Ctrl+Alt+Delete
./command.sh "System Monitor" "gnome-system-monitor" "<Control><Alt>Delete"
```

### Key Binding Syntax:

- Modifiers: `<Control>`, `<Shift>`, `<Alt>`, `<Super>`
- Combine modifiers: `<Control><Alt>a`
- Function keys: `F1`, `F2`, etc.

## How It Works

The script uses the GNOME `gsettings` command-line tool to:

1. Create a unique schema name based on the shortcut name
2. Add the shortcut to the list of custom shortcuts if not already present
3. Set the name, command, and binding values for the shortcut

## Troubleshooting

If your shortcut doesn't work:

1. Check if the binding conflicts with an existing system shortcut
2. Verify that the command is valid and executable
3. Try running the command directly in a terminal to ensure it works

## License

MIT License

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.