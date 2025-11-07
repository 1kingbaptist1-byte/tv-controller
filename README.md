# TV Controller App

A Flutter app to scan for UPnP-enabled smart TVs on a local network and control their power state.

## Features
- Scans for UPnP devices using SSDP.
- Lists discovered TVs with IP addresses.
- Sends power on/off commands (placeholder API, customize for your TV).

## Setup
1. Install Flutter (version >= 3.0.0).
2. Run `flutter pub get` to install dependencies (`http`, `xml`).
3. Ensure your phone and TVs are on the same Wi-Fi network.

## Usage
1. Press "Scan for TVs" to discover devices.
2. Select a TV and use the "On" or "Off" buttons.
3. Replace the placeholder API in `togglePower` with your TV's API.

## Notes
- This is a prototype. The power control API is hypothetical and must be customized for specific TV brands (e.g., Samsung, LG).
- Only control devices you own or have explicit permission to manage.

## License
MIT License (see LICENSE file).
