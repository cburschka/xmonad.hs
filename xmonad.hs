import Data.List   (isPrefixOf)
import Data.Map    (fromList)
import Data.Monoid (mappend)

import Graphics.X11.ExtraTypes.XF86

import System.IO (hPutStrLn)

import XMonad

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
          , layoutHook = avoidStruts $ myLayout $ layoutHook defaultConfig
          , logHook = Log.dynamicLogWithPP Log.xmobarPP { Log.ppOutput = hPutStrLn xmproc , Log.ppTitle = Log.xmobarColor "green" "" . Log.shorten 50 }
          , modMask = mod4Mask
        } `additionalKeys` multiBind
        [

-- Launchers

            ([(0, xF86XK_Sleep)], spawn "xscreensaver-command -lock")
          , ([(0, xF86XK_HomePage), (mod4Mask, xK_f)], wslaunch "/home/christoph/.bin/ff" "Web")
          , ([(0, xF86XK_Messenger), (mod4Mask, xK_c)], wslaunch "pidgin" "Chat")
          , ([(0, xF86XK_Mail), (mod4Mask, xK_e)], wslaunch "thunderbird" "Mail")
          , ([(controlMask, xF86XK_Mail)], wslaunch "thunderbird -compose" "Mail")
          , ([(0, xF86XK_Favorites)], spawn $ XMonad.terminal defaultConfig)

-- Volume keys

          , ([(0, xF86XK_AudioLowerVolume)], lowerVolume 4 >> return())
          , ([(0, xF86XK_AudioRaiseVolume)], raiseVolume 4 >> return())
          , ([(0, xF86XK_AudioMute)], toggleMute >> return())
        ]
    where
        multiBind = (foldr (++) []) . (map (\(xs,y) -> [(x,y) | x<-xs]))
        wsview id = (windows . view) id
        wslaunch cmd id = spawn cmd >> wsview id >> return()

        myWorkspaces = (map show [1..9]) ++ ["Mail", "Web", "Chat"]

        myLayout = onWorkspace "Chat" chatLayout
            where
                chatLayout = IM.withIM (15/100) (IM.Role "buddy_list") Grid.Grid

        myManageHook = composeAll [
              className =? "Pidgin" --> doShift "Chat"
            , className =? "Thunderbird" --> doShift "Mail"
            , className =? "Firefox" --> doShift "Web"
            , fmap ("Lyx" `isPrefixOf`) className --> doShift "2"
          ]
