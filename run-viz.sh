#!/usr/bin/env bash
# Wrapper script to run the OSC visualizer with the correct nix environment

if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Entering nix shell..."
    nix develop -c python3 osc-ascii-viz.py "$@"
else
    python3 osc-ascii-viz.py "$@"
fi
