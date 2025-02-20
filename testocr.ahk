#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\Scripts\Include\OCR.ahk

screenshot := "sample.png"

;try {
    ocrText := ocr(screenshot, "en")
    msgbox % ocrText
    ocrLines := StrSplit(ocrText, "`n")
    len := ocrLines.MaxIndex()
    if(len > 1) {
        playerName := ocrLines[1]
        playerID := RegExReplace(ocrLines[2], "[^0-9]", "")
        ; playerID := SubStr(ocrLines[2], 1, 19)
        msgbox % playerName . " (" . playerID . ")"
    }
;}
;catch {}