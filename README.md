# 📋 README

## 🌟 Overview
This repository provides a tool to manage and compare installed applications on Windows. It generates a list of installed apps and checks their availability in Chocolatey.

## 🛠 Features
- **List Installed Apps**: Collects all applications installed on your Windows device from different registry locations:
  - HKLM (HKEY_LOCAL_MACHINE)
  - HKCU (HKEY_CURRENT_USER)
  - HKLM Wow6432Node
- **Compare with Chocolatey**: Identifies which installed apps are available in the Chocolatey package manager.
- **Export to CSV**: Creates a CSV file containing:
  - **Name**: The name of the app
  - **Version**: The version of the app
  - **Install Date**: When the app was installed
  - **Source**: Indicates whether the app is from Chocolatey, HKLM, HKCU, or HKLM Wow6432Node
- **HTML Visualization**: Provides a table to visualize the data in an HTML format.

## 📥 Getting Started
1. Clone this repository.
2. Ensure you have Chocolatey installed on your Windows device.
3. Run the script to generate the list of installed apps.
4. Check the generated CSV file for details.

## 📊 Output
The generated CSV file will include:
- **Device Name**: The name of your device
- **Display Name**: The name of each installed app
- **Display Version**: The version of each app
- **Install Date**: The installation date of each app
- **Source**: The origin of the app (Chocolatey, HKLM, HKCU, or HKLM Wow6432Node)

Feel free to contribute or ask questions! 😊
