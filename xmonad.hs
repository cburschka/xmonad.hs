import XMonad
import XMonad.Util.Run(spawnPipe)
import XMonad.Actions.Volume
import XMonad.Util.Dzen
import Data.Map    (fromList)
import Data.Monoid (mappend)

--alert = dzenConfig return . show

main = do
     xmproc <- spawnPipe "xmobar"
     xmonad $ defaultConfig
     	    {
		terminal = "gnome-terminal",
		modMask = mod4Mask,
		keys = keys defaultConfig `mappend`
		\c -> fromList [
		   ((0, 0x1008FF11), setMute False >> lowerVolume 4 >> return()),
		   ((0, 0x1008FF13), setMute False >> raiseVolume 4 >> return()),
		   ((0, 0x1008FF12), toggleMute >> return())
		]
	    }