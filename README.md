# CPD Conversion (PYTHON VERSION)

This script processes a daily file based on its creation date.

### Important Note
You must be on the company VPN for this to do anything useful. 

## Usage

Normally you would run this daily with no arguments. 

    python main.py

However there exists functionality if needed. 

    python main.py [days_ago] [--file /absolute/path/to/file.txt]
    
- `days_ago` (optional): Number of days ago the target file was created.
  - `0` = today (default)
  - `1` = yesterday
  - and so on...

The script will throw an error if multiple files exist for a specified day. In that scenerio use this argument:

- `--file` (optional): Absolute path to a specific file.
  Use this if multiple files exist for the specified day, as the script will throw an error in that case.

## Examples

    python cpd_conversion.py                             # Uses today’s file
    python cpd_conversion.py 1                           # Uses yesterday’s file
    python cpd_conversion.py --file "/path/to/file.txt"  # Explicit file path

# CPD Conversion Bash Script

This script processes a daily file based on its creation date.

### Important Note
You must be on the company VPN for this to do anything useful. 

## Usage

This takes no arguments, and has variables defined in config.sh


