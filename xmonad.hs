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

import XMonad.Layout.PerWorkspace
import XMonad.Layout.IM
import XMonad.Layout.Grid

--alert = dzenConfig return . show

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ defaultConfig
        {
            workspaces = myWorkspaces
          , manageHook = myManageHook <+> manageDocks <+> manageHook defaultConfig
          , layoutHook = avoidStruts $ myLayout
          , logHook = dynamicLogWithPP xmobarPP { ppOutput = hPutStrLn xmproc , ppTitle = xmobarColor "green" "" . shorten 50 }
          , modMask = mod4Mask
        } `additionalKeys`
        [
            ((0, xF86XK_Sleep), spawn "xscreensaver-command -lock")
          , ((0, xF86XK_AudioRaiseVolume), setMute False >> lowerVolume 4 >> return())
          , ((0, xF86XK_AudioLowerVolume), setMute False >> raiseVolume 4 >> return())
          , ((0, xF86XK_AudioMute), toggleMute >> return())
        ]



myWorkspaces = ["1","2","3","4","5","6", "7", "Chat", "Mail"]

-- Pidgin
myLayout = onWorkspace "Chat" pidginLayout (layoutHook defaultConfig)

pidginLayout = withIM (18/100) (Role "buddy_list") gridLayout
    where
    gridLayout = Grid

myManageHook = composeAll [
    className =? "Pidgin" --> doShift "Chat",
    className =? "Thunderbird" --> doShift "Mail"
  ]
