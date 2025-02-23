#SingleInstance, force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

;if not A_IsAdmin
;{
;    ; Relaunch script with admin rights
;    Run *RunAs "%A_ScriptFullPath%"
;    ExitApp
;}

IniRead, instanceLaunchDelay, Monitor.ini, Settings, instanceLaunchDelay, 5000
IniRead, waitAfterBulkLaunch, Monitor.ini, Settings, waitAfterBulkLaunch, 20000
IniRead, Instances, Settings.ini, UserSettings, Instances, 1
IniRead, folderPath, Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
mumuFolder = %folderPath%\MuMuPlayerGlobal-12.0
if !FileExist(mumuFolder)
    mumuFolder = %folderPath%\MuMu Player 12
if !FileExist(mumuFolder){
	MsgBox, 16, , Double check your folder path! It should be the one that contains the MuMuPlayer 12 folder! `nDefault is just C:\Program Files\Netease
	ExitApp
}
Loop {
    ; Loop through each instance, check if it's started, and start it if it's not
    launched := 0

    nowEpoch := A_NowUTC
    EnvSub, nowEpoch, 1970, seconds

    Loop %Instances% {
        instanceNum := Format("{:u}", A_Index)

        IniRead, LastEndEpoch, %A_ScriptDir%\Scripts\%instanceNum%.ini, Metrics, LastEndEpoch, 0
        secondsSinceLastEnd := nowEpoch - LastEndEpoch
        if(LastEndEpoch > 0 && secondsSinceLastEnd > (15 * 60))
        {
            ; msgbox, Killing Instance %instanceNum%! Last Run Completed %secondsSinceLastEnd% Seconds Ago
            msg := "Killing Instance " . instanceNum . "! Last Run Completed " . secondsSinceLastEnd . " Seconds Ago"
            LogToFile(msg, "Monitor.txt")
            
            scriptName := instanceNum . ".ahk"

            pID := checkInstance(instanceNum)
            if(pID)
            {
                killAHK(scriptName)
                killInstance(instanceNum)
                Sleep, 3000
            }
            
            pID := checkInstance(instanceNum)
            if not pID {
                launchInstance(instanceNum)
        
                Sleep, %instanceLaunchDelay%
                launched := launched + 1

                Sleep, %waitAfterBulkLaunch%

                Command := "Scripts\" . scriptName
                Run, %Command%
                
                ; Change the last end date to now so that we don't keep trying to restart this beast
                IniWrite, %nowEpoch%, %A_ScriptDir%\Scripts\%instanceNum%.ini, Metrics, LastEndEpoch
            }
        }
    }

    ; Check for dead instances every 30 seconds
    Sleep, 30000
}

LogToFile(message, logFile) {
	logFile := A_ScriptDir . "\Logs\" . logFile

	FormatTime, readableTime, %A_Now%, MMMM dd, yyyy HH:mm:ss
	FileAppend, % "[" readableTime "] " message "`n", %logFile%
}

killAHK(scriptName := "")
{
    if(scriptName != "") {
        DetectHiddenWindows, On
        WinGet, IDList, List, ahk_class AutoHotkey
        Loop %IDList%
        {
            ID:=IDList%A_Index%
            WinGetTitle, ATitle, ahk_id %ID%
            if InStr(ATitle, scriptName) {
                ; MsgBox, Killing: %ATitle%
                WinClose, ahk_id %ID% ;kill
                ; WinClose, %fullScriptPath% ahk_class AutoHotkey
                return
            }
        }
    }
}

killInstance(instanceNum := "")
{
    
    pID := checkInstance(instanceNum)
    if pID {
        Process, Close, %pID%
    }
}

checkInstance(instanceNum := "")
{
    ret := WinExist(instanceNum)
    if(ret)
    {
        WinGet, temp_pid, PID, ahk_id %ret%
        return temp_pid
    }
    
    return ""
}

launchInstance(instanceNum := "")
{
    global mumuFolder

    if(instanceNum != "") {
        mumuNum := getMumuInstanceNumFromPlayerName(instanceNum)
        if(mumuNum != "") {
            Run, %mumuFolder%\shell\MuMuPlayer.exe -v %mumuNum%
        }
    }
}

getMumuInstanceNumFromPlayerName(scriptName := "") {
    global mumuFolder

    if(scriptName == "") {
        return ""
    }

	; Loop through all directories in the base folder
	Loop, Files, %mumuFolder%\vms\*, D  ; D flag to include directories only
	{
		folder := A_LoopFileFullPath
		configFolder := folder "\configs"  ; The config folder inside each directory

		; Check if config folder exists
		IfExist, %configFolder%
		{
			; Define paths to vm_config.json and extra_config.json
			extraConfigFile := configFolder "\extra_config.json"

			; Check if extra_config.json exists and read playerName
			IfExist, %extraConfigFile%
			{
				FileRead, extraConfigContent, %extraConfigFile%
				; Parse the JSON for playerName
				RegExMatch(extraConfigContent, """playerName"":\s*""(.*?)""", playerName)
				if(playerName1 == scriptName) {
                    RegExMatch(A_LoopFileFullPath, "[^-]+$", mumuNum)
					return mumuNum
				}
			}
		}
	}
}
