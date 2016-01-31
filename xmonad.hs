import Data.List   (isPrefixOf)
import Data.Map    (fromList)
import Data.Monoid (mappend)

import Graphics.X11.ExtraTypes.XF86

import System.IO (hPutStrLn)

import XMonad

import XMonad.Actions.CycleWS
import XMonad.Actions.Volume (lowerVolume, raiseVolume, setMute, toggleMute)
import qualified XMonad.Hooks.DynamicLog as Log
import XMonad.Hooks.ManageDocks (avoidStruts, manageDocks)
import XMonad.Layout.PerWorkspace (onWorkspace)
import qualified XMonad.Layout.IM as IM
import qualified XMonad.Layout.Grid as Grid
import XMonad.StackSet (view)
--import XMonad.Util.Dzen
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Run (spawnPipe)

--alert = dzenConfig return . show

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ defaultConfig
        {
            workspaces = myWorkspaces
          , manageHook = myManageHook <+> manageDocks <+> manageHook defaultConfig
          , layoutHook = avoidStruts
                       $ myLayout
                       $ layoutHook defaultConfig
          , logHook = Log.dynamicLogWithPP Log.xmobarPP { Log.ppOutput = hPutStrLn xmproc , Log.ppTitle = Log.xmobarColor "green" "" . Log.shorten 50 }
          , modMask = mod4Mask
        } `additionalKeys` multiBind
        [

-- Navigation

            ([(mod4Mask, xK_Left)], prevWS)
          , ([(mod4Mask, xK_Right)], nextWS)
          , ([(mod4Mask .|. shiftMask, xK_Left)], shiftToPrev >> prevWS)
          , ([(mod4Mask .|. shiftMask, xK_Right)], shiftToNext >> nextWS)

-- Utility

          , ([(controlMask, xK_Print)], spawn "sleep 0.2; scs -s")
          , ([(0, xK_Print)], spawn "scs")
          , ([(controlMask .|. mod4Mask, xK_Print)], spawn "sleep 0.2; scs -s up")
          , ([(mod4Mask, xK_Print)], spawn "scs '' up")

-- Launchers

          , ([(0, xF86XK_Sleep), (mod4Mask .|. shiftMask, xK_Delete)], spawn "xscreensaver-command -lock")
          , ([(0, xF86XK_HomePage), (mod4Mask, xK_f)], wslaunch "ifnotrunning firefox" "Web")
          , ([(0, xF86XK_Messenger), (mod4Mask, xK_c)], wslaunch "pidgin" "Chat")
          , ([(0, xF86XK_Mail), (mod4Mask, xK_e)], wslaunch "thunderbird" "Mail")
          , ([(controlMask, xF86XK_Mail), (mod4Mask .|. shiftMask, xK_e)], wslaunch "thunderbird -compose" "Mail")
          , ([(0, xF86XK_Favorites)], spawn $ XMonad.terminal defaultConfig)
          , ([(mod4Mask, xF86XK_AudioMute), (mod4Mask, xK_r)], wslaunch "rhythmbox" "Music")
          , ([(mod4Mask .|. shiftMask, xK_l)], wslaunch "lyx" "Write")

-- Volume keys

          , ([(0, xF86XK_AudioLowerVolume)], lowerVolume 4 >> return())
          , ([(0, xF86XK_AudioRaiseVolume)], raiseVolume 4 >> return())
          , ([(0, xF86XK_AudioMute)], toggleMute >> return())

          , ([(mod4Mask .|. mod1Mask, xK_space)], spawn $ rb "play-pause")
          , ([(mod4Mask .|. mod1Mask, xK_Left)], spawn $ rb "previous")
          , ([(mod4Mask .|. mod1Mask, xK_Right)], spawn $ rb "next")
          , ([(mod4Mask, xF86XK_AudioLowerVolume)], spawn $ rb "volume-down")
          , ([(mod4Mask, xF86XK_AudioRaiseVolume)], spawn $ rb "volume-up")
        ]
    where
        multiBind = (foldr (++) []) . (map (\(xs,y) -> [(x,y) | x<-xs]))
        wsview id = (windows . view) id
        wslaunch cmd id = spawn cmd >> wsview id >> return()

        myWorkspaces = (map show [1..9]) ++ ["Write", "Mail", "Web", "Chat", "Music"]

        myLayout = onWorkspace "Chat" chatLayout
            where
                chatLayout = IM.withIM (12/100) (IM.Role "buddy_list") Grid.Grid

        myManageHook = composeAll [
              className =? "Pidgin" --> doShift "Chat"
            , className =? "Thunderbird" --> doShift "Mail"
            , className =? "Firefox" --> doShift "Web"
            , fmap ("Lyx" `isPrefixOf`) className --> doShift "Write"
            , className =? "Rhythmbox" --> doShift "Music"
          ]

	rb a = "rhythmbox-client --no-start --" ++ a
