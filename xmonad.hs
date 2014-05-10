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
import XMonad.StackSet (view)

--alert = dzenConfig return . show

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ defaultConfig
        {
            workspaces = myWorkspaces
          , manageHook = myManageHook <+> manageDocks <+> manageHook defaultConfig
          , layoutHook = avoidStruts $ myLayout $ layoutHook defaultConfig
          , logHook = dynamicLogWithPP xmobarPP { ppOutput = hPutStrLn xmproc , ppTitle = xmobarColor "green" "" . shorten 50 }
          , modMask = mod4Mask
        } `additionalKeys`
        [

-- Launchers

            ((0, xF86XK_Sleep), spawn "xscreensaver-command -lock")
          , ((0, xF86XK_HomePage), wslaunch "/home/christoph/.bin/ff" "Web")
          , ((0, xF86XK_Messenger), wslaunch "pidgin" "Chat")
          , ((0, xF86XK_Mail), wslaunch "thunderbird" "Mail")
          , ((controlMask, xF86XK_Mail), wslaunch "thunderbird -compose" "Mail")
          , ((0, xF86XK_Favorites), spawn $ XMonad.terminal defaultConfig)

-- Volume keys

          , ((0, xF86XK_AudioLowerVolume), setMute False >> lowerVolume 4 >> return())
          , ((0, xF86XK_AudioRaiseVolume), setMute False >> raiseVolume 4 >> return())
          , ((0, xF86XK_AudioMute), toggleMute >> return())
        ]
    where
        wsview id = (windows . view) id
        wslaunch cmd id = spawn cmd >> wsview id >> return()

        myWorkspaces = (map show [1..9]) ++ ["Mail", "Web", "Chat"]

        myLayout = onWorkspace "Chat" chatLayout
            where
                chatLayout = withIM (18/100) (Role "buddy_list") Grid

        myManageHook = composeAll [
              className =? "Pidgin" --> doShift "Chat"
            , className =? "Thunderbird" --> doShift "Mail"
            , className =? "Firefox" --> doShift "Web"
            , className =? "LyX" --> doShift "2"
          ]
