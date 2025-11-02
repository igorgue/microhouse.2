# TidalCycles MIDI Setup for Bitwig

This guide explains how to send MIDI from TidalCycles to Bitwig Studio via VirMIDI.

## Quick Setup

Run this in Neovim after starting TidalCycles:

```vim
:lua dofile('setup-tidal-midi.lua').setup()
```

This will:
1. Initialize MIDI in SuperCollider
2. Connect SuperCollider's ALSA output to VirMIDI 4-0
3. Send a test note

## Manual Setup

If you prefer to set things up manually:

### 1. Initialize MIDI in SuperCollider

Send this to SuperCollider (or add to your startup file):

```supercollider
(
MIDIClient.init;
~midiOut = MIDIOut.newByName("Virtual Raw MIDI 4-0", "VirMIDI 4-0");
~midiOut.latency = 0.0;
~dirt.soundLibrary.addMIDI(\mydevice, ~midiOut);
)
```

### 2. Connect ALSA MIDI Routing

Run the connection script:

```bash
./setup-tidal-midi.sh
```

This finds SuperCollider's ALSA client and connects it to VirMIDI 4-0.

### 3. Configure Bitwig

In Bitwig:
1. Go to Settings → Controllers
2. Add a Generic MIDI controller
3. Select "VirMIDI 4-0" as the input

## Usage in TidalCycles

```haskell
-- Send MIDI notes (middle C = 60)
d1 $ n "60 64 67 72" # s "mydevice" # midichan 0

-- Use note names
d1 $ n "c4 e4 g4 c5" # s "mydevice" # midichan 0

-- With velocity
d1 $ n "60 64 67" # s "mydevice" # midichan 0 # velocity 0.8
```

## Monitoring MIDI

To verify MIDI is working, use the monitoring scripts:

```bash
# Monitor ALSA sequencer (shows routing)
./scripts/check-midi-live.sh

# Monitor raw MIDI device (shows actual data)
./scripts/monitor-rawmidi.sh
```

## How It Works

The MIDI signal flow is:

```
TidalCycles → SuperCollider → ALSA Sequencer → VirMIDI 4-0 → Bitwig
```

**Key Points:**
- SuperCollider creates an ALSA sequencer client only after `MIDIClient.init` is called
- You must then connect SuperCollider's output port to VirMIDI using `aconnect`
- The SuperCollider ALSA client number can vary, so the setup script finds it dynamically
- VirMIDI 4-0 appears as ALSA client 32:0

## Troubleshooting

### No MIDI in Bitwig

1. Check ALSA connections:
   ```bash
   aconnect -l | grep -A 5 SuperCollider
   ```
   You should see SuperCollider's out0 connecting to 32:0

2. Monitor raw MIDI:
   ```bash
   ./scripts/monitor-rawmidi.sh
   ```
   Then send test notes from Tidal. You should see MIDI data.

3. Verify SuperCollider MIDI is initialized:
   ```supercollider
   MIDIClient.initialized.postln;  // should print 'true'
   ~midiOut.postln;                 // should show MIDIOut object
   ```

### SuperCollider client not found

If `setup-tidal-midi.sh` reports "SuperCollider ALSA client not found":

1. Make sure SuperCollider is running
2. Initialize MIDI first: `MIDIClient.init;` in SuperCollider
3. Then run the setup script again

## Files

- `setup-tidal-midi.lua` - Automated setup script (run from Neovim)
- `setup-tidal-midi.sh` - ALSA connection script (can run standalone)
- `scripts/check-midi-live.sh` - Monitor ALSA sequencer
- `scripts/monitor-rawmidi.sh` - Monitor raw MIDI device
