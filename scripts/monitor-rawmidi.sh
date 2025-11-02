#!/usr/bin/env bash
# Monitor VirMIDI 4-0 using raw MIDI (amidi) instead of ALSA sequencer
# This will catch MIDI if SuperCollider writes to /dev/snd/midiC4D0

echo "Monitoring VirMIDI 4-0 (hw:4,0) for raw MIDI data..."
echo "This monitors the device file directly, not ALSA sequencer"
echo ""
amidi -p hw:4,0 -d
