#!/usr/bin/env bash
# Monitor VirMIDI 4-0 for MIDI data in real-time

echo "=== Monitoring VirMIDI 4-0 (32:0) for MIDI data ==="
echo "Evaluate your Tidal pattern and you should see MIDI messages here"
echo "Press Ctrl+C to stop"
echo ""

aseqdump -p 32:0
