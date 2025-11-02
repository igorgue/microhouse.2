#!/usr/bin/env bash
# Setup MIDI for Tidal Cycles with VirMIDI 4-0 (same as SonicPi)

echo "=== Setting up MIDI for Tidal Cycles ==="
echo ""

# Find SuperCollider's ALSA client number dynamically
SC_CLIENT=$(aconnect -l | grep "SuperCollider" | grep -oP 'client \K[0-9]+')

if [ -z "$SC_CLIENT" ]; then
    echo "✗ ERROR: SuperCollider ALSA client not found!"
    echo "  Make sure SuperCollider is running and MIDIClient.init has been called."
    echo "  You may need to initialize MIDI first in SuperCollider."
    exit 1
fi

echo "✓ Found SuperCollider at ALSA client $SC_CLIENT"

# SuperCollider's out0 is usually at port 9 (after in0-in8)
SC_OUT_PORT="$SC_CLIENT:9"
VIRMIDI_PORT="32:0"

# Disconnect any existing connections from SuperCollider out0
echo ""
echo "1. Cleaning up existing connections..."
aconnect -d $SC_OUT_PORT $VIRMIDI_PORT 2>/dev/null || true

# Connect SuperCollider out0 to VirMIDI 4-0 (same as SonicPi)
echo "2. Connecting SuperCollider out0 ($SC_OUT_PORT) to VirMIDI 4-0 ($VIRMIDI_PORT)..."
if aconnect $SC_OUT_PORT $VIRMIDI_PORT; then
    echo "✓ Successfully connected!"
else
    echo "✗ Connection failed."
    exit 1
fi

# Verify the connection
echo ""
echo "3. Verifying connection..."
if aconnect -l | grep -B 1 "$VIRMIDI_PORT" | grep -q "out0"; then
    echo "✓ Connection verified!"
    echo ""
    echo "ALSA MIDI routing:"
    echo "  SuperCollider out0 ($SC_OUT_PORT) → VirMIDI 4-0 ($VIRMIDI_PORT) → Bitwig"
else
    echo "✗ Verification failed"
    exit 1
fi

echo ""
echo "=== MIDI Setup Complete! ==="
echo ""
echo "Now run this in Neovim to initialize SuperCollider:"
echo "  :lua require('tidal.core.message').sclang.send_line('(MIDIClient.init; ~midiOut = MIDIOut(1); ~midiOut.latency = 0.0; ~dirt.soundLibrary.addMIDI(\\\\\\\\mydevice, ~midiOut);)')"
echo ""
echo "Then test with this in your Tidal buffer:"
echo "  d1 \$ n \"60 64 67\" # s \"mydevice\" # midichan 0"
