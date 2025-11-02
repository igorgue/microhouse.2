# TidalCycles Setup

This project has been configured to work with TidalCycles on NixOS.

## Setup Instructions

### 1. Start SuperCollider
First, you need to start SuperCollider and load SuperDirt:

```bash
# In one terminal, start SuperCollider
sclang
```

Once in SuperCollider, run:
```supercollider
SuperDirt.start
```

### 2. Start TidalCycles
In another terminal, start TidalCycles:

```bash
# Using the startup script
./start-tidal.sh

# Or manually
nix-shell -p haskellPackages.tidal haskellPackages.tidal-link supercollider --run "ghci BootTidal.hs"
```

### 3. Make Music
Now you can write patterns in `hello.tidal` and they will automatically load when you start TidalCycles.

## Files

- `BootTidal.hs` - TidalCycles bootstrap file with all necessary imports
- `hello.tidal` - Your Tidal patterns go here
- `start-tidal.sh` - Startup script for TidalCycles
- `flake.nix` - Nix flake for reproducible environment

## MIDI Setup

To send MIDI from TidalCycles to external software (like Bitwig):

```vim
:lua dofile('setup-tidal-midi.lua').setup()
```

See [MIDI-SETUP.md](MIDI-SETUP.md) for detailed instructions.

## Common Issues

If you get module errors, make sure you're running TidalCycles through the nix-shell environment as shown above.

## OSC ASCII Visualizer

This project includes an ASCII visualizer that displays TidalCycles OSC messages in real-time!

### Usage

Make the script executable and run it:

```bash
chmod +x osc-ascii-viz.py
python osc-ascii-viz.py
```

Or with custom settings:

```bash
# Listen on a different port
python osc-ascii-viz.py --port 57120

# Listen on specific IP
python osc-ascii-viz.py --ip 127.0.0.1 --port 6010
```

### Features

- 🎨 **4 Visualization Modes** (auto-cycles every ~10 seconds):
  - Waveform - animated sine waves
  - Bar Graph - activity bars  
  - Circle - expanding circles based on message activity
  - Particles - falling particle effects

- 📊 **Real-time OSC Message Log** - shows recent messages at the bottom
- 🎵 **Sound Display** - shows the current sound/sample being played
- 🌈 **Colorful ASCII Art** - uses terminal colors for visual appeal

### Controls

- Press `q` or `ESC` to quit
- Visualization modes auto-cycle

### Requirements

The visualizer uses `oscpy` which is included in the flake. Just make sure you've run `direnv allow` or entered the nix shell.

## Example Patterns

```haskell
-- Simple beat
d1 $ sound "bd sn"

-- More complex pattern
d1 $ sound "bd*2 sn cp hh*4"
# pan "0 1 0.5 0.25"
# gain "0.8 0.9 1 0.7"

-- Melodic pattern
d2 $ note "c4 g3 e4 g3" # s "superpiano"
```
