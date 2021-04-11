import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers (isDialog, (/=?), isInProperty)
import XMonad.Hooks.SetWMName
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
import System.Directory (getHomeDirectory, createDirectoryIfMissing)
import System.FilePath (joinPath)
import Data.List (isPrefixOf)

import Graphics.X11.Xinerama

myFont2 = "-*-terminus-medium-*-*-*-14-*-*-*-*-*-iso10646-1"
--myFont = "Monospace:pixelsize="
myDzen = "dzen2 \
    \ -bg 'black' -fg 'white' -p -xs 1"
conkyBar = "conky | " ++ myDzen ++ " -e '' -ta r"
infoBar = myDzen ++ " -e '' -ta l"
notice = "^bg(darkred)"
normal = "^bg(black)"

myWorkspaces =
    [ "1:main"
    , "2:eclipse"
    , "3:subl"
    , "4:firefox"
    , "5:chrome"
    , "6:dev"
    , "7:rand1"
    ]

myLayouts = onWorkspaces ["3:subl", "4:firefox", "5:chrome"] (Full ||| twoCols ||| simpleFloat)
    where
        tiled = Tall 1 (3/100) (1/2)
        twoCols = TwoPane (3/100) (1/2)

scratchpads =
    [ NS "scratch" "urxvt -name scratch" (title =? "scratch") place
    , NS "keepassx" "keepassx" (className =? "Keepassx") place
    , NS "notes" "subl -n ~/notes" (title =? "~/notes - Sublime Text"
        <||>  title =? "~/notes • - Sublime Text") place
    ]
   where
    place = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)

myManageHook :: ManageHook
myManageHook = composeAll . concat $ [
        [ className =? "firefox" --> viewShift "4:firefox"
        , className =? "chromium" --> doShift "5:chrome"
        ,(className =? "Sublime_text" <&&> title /=? "~/notes - Sublime Text"
            <&&> title /=? "~/notes • - Sublime Text") --> viewShift "3:subl"
        , className =? "Eclipse" --> doShift "2:eclipse"

        ,(className =? "firefox" <&&> role /=? "browser") --> doFloat
        ,(className =? "chromium" <&&> role /=? "browser") --> doFloat
        , isDialog --> doFloat
        , isSplash --> doFloat

        , namedScratchpadManageHook scratchpads
        ]
        , [ className =?  c --> doFloat | c <- myFloats ]
        ]
    where
        role = stringProperty "WM_WINDOW_ROLE"
        viewShift = doF . liftM2 (.) W.greedyView W.shift
        isSplash = (isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"
            <||> isInProperty "_NET_WM_STATE" "_NET_WM_STATE_MODAL")
        myFloats =
            [ "GpicView"
            , "Pcmanfm"
            , "Evince"
            , "SpeedCrunch"
            ]

myKeys =
    [ ("M-q", spawn "killall conky dzen2 && xmonad --recompile && xmonad --restart")
    --, ("M-t", namedScratchpadAction scratchpads "scratch")
    , ("M-s", namedScratchpadAction scratchpads "keepassx")
    , ("M-n", namedScratchpadAction scratchpads "notes")
   ]

main = do
    screenWidth <- getScreenWidth 0
    screenHeight <- getScreenHeight 0
    let heights = getHeights screenHeight
    dockConky <- spawnPipe (getConkyBar screenWidth heights)
    dockInfo <- spawnPipe (getInfoBar screenWidth heights)
    conkyDir <- getConkyConfigDir
    cpuCount <- getCpuCount

    createDirectoryIfMissing True conkyDir
    writeFile (joinPath [conkyDir, "conky.conf"]) (getConkyConfig (read cpuCount))

    xmonad $ def
        { manageHook = myManageHook <+> manageHook def
        , layoutHook = gaps [(U,(snd heights)),(D,0),(L,0),(R,0)] $ myLayouts $ layoutHook def
        , terminal = "xterm"
        , workspaces = myWorkspaces
        , startupHook = setWMName "LG3D"
        , logHook = dynamicLogWithPP $ def
                    { ppOutput = hPutStrLn dockInfo
                    , ppHidden = const ""
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

getScreenHeight :: Int -> IO Int
getScreenHeight n = do
    d        <- openDisplay ""
    screens  <- xineramaQueryScreens d
    return $ case screens of
        Nothing -> 0
        Just [] -> 0
        Just ss -> if n >= 0 && n < length ss
            then fromIntegral . xsi_height $ ss !! n else 0

getHeights :: Int -> (Int,Int)
getHeights w
    | w <= 1080 = (12, 18)
    | otherwise = (14, 20)

getConkyBar :: Int -> (Int,Int) -> String
getConkyBar sw (fsize, height) = getBar conkyBar fsize height (sw-1500) 1500

getInfoBar :: Int -> (Int,Int) -> String
getInfoBar sw (fsize, height) = getBar infoBar fsize height 0 (sw-1500)

getBar :: String -> Int -> Int -> Int -> Int -> String
getBar bar fsize height x w = bar
--    ++ " -fn '" ++ myFont ++ show fsize ++ "'"
    ++ " -fn '" ++ myFont2 ++ "'"
    ++ " -h " ++ show height
    ++ " -x " ++ show x
    ++ " -w " ++ show w

getConkyConfig :: Int -> String
getConkyConfig x = "\
\conky.config = {\n\
\    out_to_x = false,\n\
\    out_to_console = true,\n\
\    update_interval = 1,\n\
\    use_spacer = 'left',\n\
\    net_avg_samples = 2,\n\
\    pad_percents = 3\n\
\}\n\
\\n\
\conky.text = [[\n\
\${downspeed enp0s3} ${color2}${upspeed enp0s3} \\\n\
\|" ++ (getCpus "" x) ++ " \\\n\
\${cpu cpu0}% ${loadavg 1} ${color} ${loadavg 2} ${loadavg 3} \\\n\
\|${diskio_read /dev/sda} ${diskio_write /dev/sda} ${diskio /dev/sda} \\\n\
\ " ++ (noticeIfGt "fs_used_perc" "70") ++ "\\\n\
\| $mem " ++ (noticeIfGt "memperc" "80") ++ " \\\n\
\$swap \\\n\
\| ${top name 1} ${top pid 1} \\\n\
\| ${time %F %T} \\\n\
\]]\
\\n"

noticeIfGt :: String -> String -> String
noticeIfGt s v = "${if_match ${" ++ s ++ "} > " ++ v ++ "}"
  ++ notice ++ "${endif}${" ++ s ++ "}% " ++ normal

getCpuCount :: IO String
getCpuCount = do
    -- We read core count from file, because xmonad didn't work correctly
    -- with readProcess. Some problem with SIGCHILD
    info <- readFile "/proc/cpuinfo"
    let line = head (filter (\s -> "cpu cores" `isPrefixOf` s) (lines info))
    return [(line !! ((length line)-1))]

getCpus :: String -> Int -> String
getCpus x 0 = x
getCpus x y = getCpus (" " ++ getCpustring y ++ x) (y-1)

getCpustring :: Int -> String
getCpustring x = "${cpu cpu" ++ show x ++ "}"

getConkyConfigDir :: IO FilePath
getConkyConfigDir = do
    home <- getHomeDirectory
    return (joinPath [home, ".config", "conky"])

