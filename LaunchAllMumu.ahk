#SingleInstance, force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

IniRead, instanceLaunchDelay, Monitor.ini, Settings, instanceLaunchDelay, 5000
IniRead, waitAfterBulkLaunch, Monitor.ini, Settings, waitAfterBulkLaunch, 20000
IniRead, Instances, Settings.ini, UserSettings, Instances, 1
IniRead, folderPath, Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
IniRead, runMain, Settings.ini, UserSettings, runMain, 1

mumuFolder = %folderPath%\MuMuPlayerGlobal-12.0
if !FileExist(mumuFolder)
    mumuFolder = %folderPath%\MuMu Player 12
if !FileExist(mumuFolder){
	MsgBox, 16, , Double check your folder path! It should be the one that contains the MuMuPlayer 12 folder! `nDefault is just C:\Program Files\Netease
	ExitApp
}

; Loop through each instance, check if it's started, and start it if it's not
launched := 0

if(runMain)
{
    instanceNum := "Main"
    pID := checkInstance(instanceNum)
    if not pID {
        launchInstance(instanceNum)

        Sleep, %instanceLaunchDelay%
        launched := launched + 1
    }
}

Loop %Instances% {
    instanceNum := Format("{:u}", A_Index)
    pID := checkInstance(instanceNum)
    if not pID {
        launchInstance(instanceNum)

        Sleep, %instanceLaunchDelay%
        launched := launched + 1
    }
}

Run, "%A_ScriptDir%\PTCGPB.ahk"

ExitApp





killInstance(instanceNum := "")
{
    pID := checkInstance(instanceNum)
    if pID {
        Process, Close, %pID%
    }
}

checkInstance(instanceNum := "")
{
    ; ret := WinExist(instanceNum)
    WinGet, temp_pid, PID , %instanceNum%
    return temp_pid
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
