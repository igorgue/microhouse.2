#!/usr/bin/env bash

echo "Starting TidalCycles environment..."

# Start nix-shell with TidalCycles
ghci -ghci-script Tidal.ghci
