#!/bin/bash

echo "=== Removing VLC (snap) ==="
sudo snap remove vlc 2>/dev/null
rm -rf ~/snap/vlc

echo "=== Removing VLC (apt) ==="
sudo apt remove --purge -y vlc vlc-plugin-* libvlc* libvlccore*
sudo apt autoremove --purge -y

echo "=== Removing leftover VLC config files ==="
rm -rf ~/.config/vlc
rm -rf ~/.cache/vlc

echo "=== Checking if any VLC packages are still present ==="
dpkg -l | grep vlc
snap list | grep vlc
which vlc || echo "VLC binary not found (good)."

echo "=== Installing clean VLC (APT) ==="
sudo apt update
sudo apt install -y vlc

echo "=== Done! Try running VLC with: vlc or QT_QPA_PLATFORM=xcb vlc ==="
