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
AddChatMessage("{006EE6} CP {FFFFFF} ‹erweisung vom eigenen Konto an Spieler")
Sleep, 250
recipient := PlayerInput("Empf‰nger: ")
amount := PlayerInput("Betrag: ")
additional := PlayerInput("Grund: ")
cpu(recipient, amount, additional)
Return


:?:/scpu::
AddChatMessage("{006EE6} CP {FFFFFF} ‹erweisung vom eigenen Konto an Spieler (ohne Grund)")
Sleep, 250
recipient := PlayerInput("Empf‰nger: ")
amount := PlayerInput("Betrag: ")
cpu(recipient, amount, "")
Return

:?:/premium::
Sleep, 200
txt := cp_getPremium()
diatxt := BuildPremiumDialog(txt)
ShowDialog(5,"Permium¸bersicht", diatxt, "Schlieﬂen")
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
If (InStr(prm[3], "unbegrenzt"))
{
AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} l‰uft nicht ab.")
Return

}
Else
AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} l‰uft am " ablauf[1] " um "ablauf[2]" Uhr ab.")
Return

:?:/ct::
Sleep, 50
AddChatMessage("{FFFFFF}Farbtest: {CD7F32}Bronze - {C0C0C0}Silber - {FFD700}Gold - {868279}Platin")
Return

:?:/wlbestand::
Sleep, 200
txt := cp_getWeaponstore()
diatxt := BuildWeaponstoreDialog(txt)
ShowDialog(5,"Waffenlager Bestand", diatxt, "Schlieﬂen")
Return

:?:/faps::
Sleep, 200
diatxt := cp_getFaps()
diatxt := BuildActivityDialog(diatxt)
ShowDialog(5,"Fraktionsaktivit‰tspunkte", diatxt, "Schlieﬂen")
Return

:?:/bfl::
Sleep, 200
diatxt := cp_getBizlist()
diatxt := BuildBusinessDialog(diatxt)
ShowDialog(5,"Busineesinfo", diatxt, "Schlieﬂen")
Return

:?:/fml::
Sleep, 200
diatxt := cp_getFMembers()
diatxt := BuildFactionMemberDialog(diatxt)
ShowDialog(5,"Fraktionsmember", diatxt, "Schlieﬂen")
Return

:?:/fvl::
Sleep, 200
diatxt := cp_getFVehicles()
diatxt := BuildFactionVehicleDialog(diatxt)
ShowDialog(5,"Fraktionsfahrzeuge", diatxt, "Schlieﬂen")
Return

:?:/hinfo::
Sleep, 200
diatxt := cp_getHouse()
diatxt := BuildHouseDialog(diatxt)
ShowDialog(5,"Hausinformationen", diatxt, "Schlieﬂen")
Return

:?:/finfo::
Sleep, 200
diatxt := cp_getFInfo()
diatxt := BuildFactionInfoDialog(diatxt)
ShowDialog(5,"Fraktionsinformationen", diatxt, "Schlieﬂen")
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
frak.insert("Los Santos Medical Department","FF3333")
frak.insert("Hitman Agency","993300")
frak.insert("Yakuza Mafia","DB7B9D")
frak.insert("Bodyguard", "FD824D")

Return frak
}

:?:/teamol::
Sleep, 200
diatxt := BuildTeamOL()
ShowDialog(5,"Team Online Liste", diatxt, "Schlieﬂen")
Return

:?:/tl::
Sleep, 200
diatxt := BuildTeamDialog()
ShowDialog(5,"Teamliste", diatxt, "Schlieﬂen")
Return

:?:/leaderol::
Sleep, 200
diatxt := BuildLeaderOL()
ShowDialog(5,"Leader Online Liste", diatxt, "Schlieﬂen")
Return

:?:/leader::
Sleep, 200
diatxt := BuildLeaderDialog()
ShowDialog(5,"Leaderliste", diatxt, "Schlieﬂen")
Return


:?:/plt::
Sleep, 200
txt := "Aktiv | Premium Plus (jetzt Silber) (Lifetime) | lifetime (unbegrenzt)"
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
If (InStr(prm[3], "unbegrenzt"))
{
AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} l‰uft nicht ab.")
Return

}

Else
{
    AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} l‰uft am " ablauf[1] " um "ablauf[2]" Uhr ab.")
Return
}


:?:/mlog::
timefrom := A_Now
Sleep, 200
If (CP_PW == "")
    {
    CP_PW := PlayerInput("CP-Passwort: ")
    CP_PW := cp_UrlEncode(CP_PW)
    }
BlockInput, On
BlockChatInput()
txt := cp_money_log()
diatxt := BuildMoneyLogDialog(txt)
;AddChatMessage(StrLen(diatxt))
If (StrLen(diatxt) > 4096)
{
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Der Geldlog ist zu groﬂ zum Anzeigen")
}
Else
{
ShowDialog(5,"Geld-LoG", diatxt, "Schlieﬂen")
}
UnBlockChatInput()
BlockInput, Off
Return

:?:/cc::
Loop, 100
    AddChatMessage("")
Return

:?:/paydays::
Sleep, 200
If (CP_PW == "")
    {
    CP_PW := PlayerInput("CP-Passwort: ")
    CP_PW := cp_UrlEncode(CP_PW)
    }
BlockInput, On
BlockChatInput()
txt := cp_money_log()
diatxt := BuildPaydayLogDialog(txt)
;AddChatMessage(StrLen(diatxt))
If (StrLen(diatxt) > 4096)
{
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Der Geldlog ist zu groﬂ zum Anzeigen")
}
Else
{
ShowDialog(5,"Geld-LoG", diatxt, "Schlieﬂen")
}
UnBlockChatInput()
BlockInput, Off
Return

:?:/ticketlist::
Sleep, 200
If (CP_PW == "")
    {
    CP_PW := PlayerInput("CP-Passwort: ")
    CP_PW := cp_UrlEncode(CP_PW)
    }
BlockInput, On
BlockChatInput()
txt := cp_getTickets()
diatxt := BuildTicketDialog(txt)
;AddChatMessage(StrLen(diatxt))
If (StrLen(diatxt) > 4096)
{
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Der Geldlog ist zu groﬂ zum Anzeigen")
}
Else
{
ShowDialog(5,"Geld-LoG", diatxt, "Schlieﬂen")
}
UnBlockChatInput()
BlockInput, Off
Return
