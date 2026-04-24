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

#Requires AutoHotkey <2.0
#Requires AutoHotkey 32-bit
#SingleInstance Force
#NoEnv
#IfWinActive, GTA:SA:MP
#Persistent

; PlayerInput by Ryan (?)
PlayerInput(text){
s := A_IsSuspended
Suspend On
KeyWait Enter
SendInput t^a{backspace}%text%
Input, var, v, {enter}
SendInput ^a{backspace 100}{enter}
Sleep, 300
if(!s)
Suspend Off
return var
}

:?:/cpu::
AddChatMessage("{006EE6} CP {FFFFFF} Üerweisung vom eigenen Konto an Spieler")
Sleep, 250
recipient := PlayerInput("Empfänger: ")
amount := PlayerInput("Betrag: ")
additional := PlayerInput("Grund: ")
cpu(recipient, amount, additional)
Return


:?:/scpu::
AddChatMessage("{006EE6} CP {FFFFFF} Üerweisung vom eigenen Konto an Spieler (ohne Grund)")
Sleep, 250
recipient := PlayerInput("Empfänger: ")
amount := PlayerInput("Betrag: ")
cpu(recipient, amount, "")
Return