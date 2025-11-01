:set -fno-warn-orphans -Wno-type-defaults -XMultiParamTypeClasses -XOverloadedStrings
:set prompt ""
:set -package tidal

import Sound.Tidal.Boot

default (Rational, Integer, Double, Pattern String)

let editorTarget = Target {oName = "editor", oAddress = "127.0.0.1", oPort = 6013, oLatency = 0.03, oSchedule = Live, oWindow = Nothing, oHandshake = False, oBusPort = Nothing }
let editorShape = OSCContext "/editor/highlights"
tidalInst <- mkTidalWith [(superdirtTarget { oLatency = -0.02 }, [superdirtShape]), (editorTarget, [editorShape])] (defaultConfig {cFrameTimespan = 1/50, cProcessAhead = 1/20})

instance Tidally where tidal = tidalInst

:set prompt "tidal> "
:set prompt-cont ""
