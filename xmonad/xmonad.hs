import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Layout.Gaps
import XMonad.Layout.TwoPane
import XMonad.Layout.SimpleFloat
import XMonad.Layout.PerWorkspace (onWorkspace, onWorkspaces)
import qualified XMonad.StackSet as W
import Control.Monad (liftM2)
import System.IO

import Graphics.X11.Xinerama

myFont = "Monospace:pixelsize=14"
myBarHeight = 20
myDzen = "dzen2 -fn '" ++ myFont ++ "' -h " ++ (show myBarHeight) ++ " \
    \ -bg '#000000' -fg '#ffffff' -p -xs 1"
conkyBar = "conky | " ++ myDzen ++ " -e '' -ta r"
infoBar = myDzen ++ " -e '' -ta l"

myWorkspaces =
    [ "1:main"
    , "2:eclipse"
    , "3:subl"
    , "4:firefox"
    , "5:chrome"
    , "6:dev"
    , "7:rand1"
    , "8:rand2"
    , "9:rand3"
    ]

myLayouts = onWorkspaces ["3:subl", "4:firefox", "5:chrome"] (Full ||| twoCols ||| simpleFloat)
    where
        tiled = Tall 1 (3/100) (1/2)
        twoCols = TwoPane (3/100) (1/2)

scratchpads =
    [ NS "scratch" "urxvt -name scratch" (title =? "scratch") place
    , NS "keepassx" "keepassx" (className =? "Keepassx") place
    ]
   where
    place = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)

myManageHook :: ManageHook
myManageHook = composeAll
        [ className =? "Firefox" --> viewShift "4:firefox"
        , className =? "Google_chrome" --> viewShift "5:chrome"
        , className =? "Sublime_text" --> viewShift "3:subl"
        , className =? "Eclipse" --> viewShift "2:eclipse"
        , className =? "Gpicview" --> doFloat
        , className =? "Pcmanfm" --> doFloat
        , className =? "Evince" --> doFloat
        ]
        <+> namedScratchpadManageHook scratchpads
    where viewShift = doF . liftM2 (.) W.greedyView W.shift

myKeys =
    [ ("M-q", spawn "killall conky dzen2 && xmonad --recompile && xmonad --restart")
    , ("M-t", namedScratchpadAction scratchpads "scratch")
    , ("M-s", namedScratchpadAction scratchpads "keepassx")
   ]

main = do
    screenWidth <- getScreenWidth 0
    dockConky <- spawnPipe (getConkyBar screenWidth)
    dockInfo <- spawnPipe (getInfoBar screenWidth)

    xmonad $ def
        { manageHook = myManageHook <+> manageHook def
        , layoutHook = gaps [(U,myBarHeight),(D,0),(L,0),(R,0)] $ myLayouts $ layoutHook def
        , terminal = "urxvt"
        , workspaces = myWorkspaces
        , logHook = dynamicLogWithPP $ def
                    { ppOutput = hPutStrLn dockInfo
                    , ppTitle = shorten 100
                    }
        } `additionalKeysP` myKeys

getScreenWidth :: Int -> IO Int
getScreenWidth n = do
    d        <- openDisplay ""
    screens  <- xineramaQueryScreens d
    return $ case screens of
        Nothing -> 0
        Just [] -> 0
        Just ss -> if n >= 0 && n < length ss
            then fromIntegral . xsi_width $ ss !! n else 0

getConkyBar :: Int -> String
getConkyBar sw = getBar conkyBar (sw-1500) 1500

getInfoBar :: Int -> String
getInfoBar sw = getBar infoBar 0 (sw-1500)

getBar :: String -> Int -> Int -> String
getBar bar x w = bar ++ " -x " ++ show x ++ " -w " ++ show w
