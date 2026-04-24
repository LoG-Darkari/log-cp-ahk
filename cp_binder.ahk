; ============================================================
if not A_IsAdmin{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}
OnError(LogError)

class LogError {
    Call(exc) {
        FileAppend % "Error on line " exc.Line ": " exc.Message "`n", errorlog.txt
        return true
    }
}
SendMode Input
SetWorkingDir %A_ScriptDir%
; ------------------------------------------------------------
; SAMP UDF laden
; ------------------------------------------------------------
#Include %A_ScriptDir%\src\SAMP.ahk

; ------------------------------------------------------------
; ControlPanel SDK laden
; ------------------------------------------------------------
#Include %A_ScriptDir%\include.ahk


#NoEnv
#SingleInstance Force
#IfWinActive, GTA:SA:MP
#Persistent