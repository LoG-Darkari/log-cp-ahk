; ============================================================
if not A_IsAdmin{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}
OnError(LogError)

class LogError {
    Call(exc) {
        FileAppend % "Error on line " exc.Line ": " exc.Message "`n", error.log
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

:?:/premium::
Sleep, 200
txt := cp_getPremium()
;AddChatMessage("TXT"StrLen(txt))
diatxt := BuildPremiumDialog(txt)
FileDelete, dia.log
FileAppend, %diatxt%, dia.log
;AddChatMessage(StrLen(diatxt))
ShowDialog(5,"Permiumübersicht", diatxt, "Schließen")
Return

:?:/pl::
Sleep, 200
txt := GetActivePremium(cp_getPremium())
prm := StrSplit(txt, " | ")
ablauf := StrSplit(prm[3], " - ")
If (InStr(prm[2], "Bronze"))
{
color := "{CD7F32}"
}
If (InStr(prm[2], "Gold"))
{
 color := "{FFD700}"
}
If (InStr(prm[2], "Silber"))
{
color :=   "{C0C0C0}"
}
If (InStr(prm[2], "Platin"))
{
color := "{868279}"
}
AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} läuft am " ablauf[1] " um "ablauf[2]" Uhr ab.")
Return

:?:/ct::
Sleep, 50
AddChatMessage("Farbtest: {CD7F32}Bronze - {C0C0C0}Silber - {FFD700}Gold - {868279}Platin")
Return