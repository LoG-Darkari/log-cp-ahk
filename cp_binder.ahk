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
diatxt := BuildPremiumDialog(txt)
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

:?:/wlbestand::
Sleep, 200
txt := cp_getWeaponstore()
diatxt := BuildWeaponstoreDialog(txt)
ShowDialog(5,"Waffenlager Bestand", diatxt, "Schließen")
Return

:?:/faps::
Sleep, 200
diatxt := cp_getFaps()
diatxt := BuildActivityDialog(diatxt)
ShowDialog(5,"Fraktionsaktivitätspunkte", diatxt, "Schließen")
Return

:?:/bfl::
Sleep, 200
diatxt := cp_getBizlist()
diatxt := BuildBusinessDialog(diatxt)
ShowDialog(5,"Busineesinfo", diatxt, "Schließen")
Return

:?:/fml::
Sleep, 200
diatxt := cp_getFMembers()
diatxt := BuildFactionMemberDialog(diatxt)
ShowDialog(5,"Fraktionsmember", diatxt, "Schließen")
Return

:?:/fvl::
Sleep, 200
diatxt := cp_getFVehicles()
diatxt := BuildFactionVehicleDialog(diatxt)
ShowDialog(5,"Fraktionsfahrzeuge", diatxt, "Schließen")
Return

:?:/hinfo::
Sleep, 200
diatxt := cp_getHouse()
diatxt := BuildHouseDialog(diatxt)
ShowDialog(5,"Hausinformationen", diatxt, "Schließen")
Return

:?:/finfo::
Sleep, 200
diatxt := cp_getFInfo()
diatxt := BuildFactionInfoDialog(diatxt)
ShowDialog(5,"Fraktionsinformationen", diatxt, "Schließen")
Return

:?:/fkinfo::
Sleep, 200
diatxt := cp_getFInfo()
fkasse := ParseFactionInfo(diatxt)
fraks := initFraks()
color := fraks[fkasse["Name"]]
faction := fkasse["Name"]
AddChatMessage("{006EE6} [CP]: {FFFFFF}Auf der Fraktionskasse ({"color "}" faction "{FFFFFF}) befinden sich aktuell: " fkasse["Kasse"])
Return

initFraks()
{
frak := {}
frak.insert("San Andreas Logistik und Abschleppdienst","FFFF00")
frak.insert("Los Santos Police Department","6495ED")
frak.insert("Federal Bureau of Investigation","1111FF")
frak.insert("United States Army","33CC00")
frak.insert("Front Yard Ballas","660066")
frak.insert("Grove Street Families","006600")
frak.insert("Russen Mafia","666666")
frak.insert("Triaden Mafia","FFFF80")
frak.insert("Terroristen","795F37")
frak.insert("San Andreas Abschlepp- und Pannendienst","CC9966")
frak.insert("Los Santos Medical Department","ZF3333")
frak.insert("Hitman","993300")
frak.insert("Yakuza Mafia","DB7B9D")
frak.insert("Bodyguard", "FD824D")

Return frak
}