import XMonad

import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86

import XMonad.Hooks.DynamicLog
import XMonad.Util.Run(spawnPipe)
import XMonad.Actions.Volume
import XMonad.Util.Dzen
import Data.Map    (fromList)
import Data.Monoid (mappend)
import System.IO

--alert = dzenConfig return . show

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ defaultConfig
        {
            manageHook = manageDocks <+> manageHook defaultConfig,
            layoutHook = avoidStruts  $  layoutHook defaultConfig,
            logHook = dynamicLogWithPP xmobarPP { ppOutput = hPutStrLn xmproc , ppTitle = xmobarColor "green" "" . shorten 50 },
            modMask = mod4Mask,
            keys = keys defaultConfig `mappend`
                \c -> fromList [
                   ((0, 0x1008FF11), setMute False >> lowerVolume 4 >> return()),
                   ((0, 0x1008FF13), setMute False >> raiseVolume 4 >> return()),
                   ((0, 0x1008FF12), toggleMute >> return())
                ]
        } `additionalKeys`
        [
            ((0, xF86XK_Sleep), spawn "xscreensaver-command -lock")
        ]
