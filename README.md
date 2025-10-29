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

## Common Issues

If you get module errors, make sure you're running TidalCycles through the nix-shell environment as shown above.

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
