#!/bin/bash

echo "=== Removing VLC (snap + apt) ==="
sudo snap remove vlc 2>/dev/null
sudo apt remove --purge -y vlc vlc-plugin-* libvlc* libvlccore*
sudo apt autoremove --purge -y

echo "=== Cleaning VLC config files ==="
rm -rf ~/snap/vlc
rm -rf ~/.config/vlc
rm -rf ~/.cache/vlc

echo "=== Installing VLC (snap) ==="
sudo snap install vlc

echo "=== Done! Try running VLC normally or with: QT_QPA_PLATFORM=xcb vlc ==="
