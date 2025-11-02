-- Complete Tidal MIDI setup script
-- Usage: :lua dofile('setup-tidal-midi.lua').setup()

local M = {}

function M.setup()
  local msg = require("tidal.core.message")

  print("=== Tidal MIDI Setup ===\n")

  -- Step 1: Initialize SuperCollider MIDI first
  -- This creates the ALSA client that we need to connect
  print("Step 1: Initializing SuperCollider MIDI...")
  local init_cmd = '(MIDIClient.init; ~midiOut = MIDIOut.newByName("Virtual Raw MIDI 4-0", "VirMIDI 4-0"); ~midiOut.latency = 0.0; ~dirt.soundLibrary.addMIDI(\\\\mydevice, ~midiOut); "MIDI initialized!".postln;)'
  msg.sclang.send_line(init_cmd)

  -- Wait for SuperCollider to create ALSA client
  print("Waiting for SuperCollider to create ALSA client...")
  vim.wait(2000)

  -- Step 2: Setup ALSA connections (now that SuperCollider client exists)
  print("\nStep 2: Setting up ALSA MIDI routing...")
  local result = vim.fn.system("bash setup-tidal-midi.sh")
  print(result)

  -- Step 3: Verify initialization
  print("\nStep 3: Verifying MIDI setup...")
  msg.sclang.send_line('if(~midiOut.notNil, { "✓ ~midiOut is ready".postln; }, { "✗ ERROR: ~midiOut is nil!".postln; });')

  vim.wait(500)

  -- Step 4: Test
  print("\nStep 4: Sending test MIDI note...")
  msg.sclang.send_line('if(~midiOut.notNil, { ~midiOut.noteOn(0, 60, 100); { ~midiOut.noteOff(0, 60, 0); }.defer(0.5); "Test note sent!".postln; }, { "ERROR: Cannot send test note - ~midiOut is nil!".postln; });')

  print("\n✓ Setup complete!")
  print("\nCheck SuperCollider post window and your MIDI monitor.")
  print("You should see MIDI data going to Bitwig now!")
  print("\nTry this in your midi.tidal buffer:")
  print('  d1 $ n "60 64 67 72" # s "mydevice" # midichan 0')
  print("\nOr test with:")
  print('  :lua dofile("setup-tidal-midi.lua").test()')
end

function M.test()
  local msg = require("tidal.core.message")
  print("Sending test MIDI note (C4)...")
  msg.sclang.send_line('if(~midiOut.notNil, { ~midiOut.noteOn(0, 60, 127); { ~midiOut.noteOff(0, 60, 0); }.defer(0.5); "Test note sent!".postln; }, { "ERROR: ~midiOut is nil - run setup first!".postln; });')
end

function M.info()
  print("=== Tidal MIDI Configuration ===")
  print("\nALSA Routing:")
  print("  SuperCollider out0 (128:9) → VirMIDI 4-0 (32:0) → Bitwig")
  print("\nSuperCollider:")
  print("  MIDIOut(1) = VirMIDI 4-0")
  print("  Device name: 'mydevice'")
  print("\nTidal Usage:")
  print('  d1 $ n "60 64 67" # s "mydevice" # midichan 0')
  print("\nCommands:")
  print("  :lua dofile('setup-tidal-midi.lua').setup()  -- Full setup")
  print("  :lua dofile('setup-tidal-midi.lua').test()   -- Test MIDI")
  print("  :lua dofile('setup-tidal-midi.lua').info()   -- Show this info")
end

return M
