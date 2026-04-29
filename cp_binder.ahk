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
AddChatMessage("{006EE6} CP {FFFFFF} erweisung vom eigenen Konto an Spieler")
Sleep, 250
recipient := PlayerInput("Empfnger: ")
amount := PlayerInput("Betrag: ")
additional := PlayerInput("Grund: ")
cpu(recipient, amount, additional)
Return


:?:/scpu::
AddChatMessage("{006EE6} CP {FFFFFF} erweisung vom eigenen Konto an Spieler (ohne Grund)")
Sleep, 250
recipient := PlayerInput("Empfnger: ")
amount := PlayerInput("Betrag: ")
cpu(recipient, amount, "")
Return

:?:/premium::
Sleep, 200
txt := cp_getPremium()
diatxt := BuildPremiumDialog(txt)
ShowDialog(5,"Permiumbersicht", diatxt, "Schlieen")
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
AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} luft nicht ab.")
Return

}
Else
AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} luft am " ablauf[1] " um "ablauf[2]" Uhr ab.")
Return

:?:/ct::
Sleep, 50
AddChatMessage("{FFFFFF}Farbtest: {CD7F32}Bronze - {C0C0C0}Silber - {FFD700}Gold - {868279}Platin")
Return

:?:/wlbestand::
Sleep, 200
txt := cp_getWeaponstore()
diatxt := BuildWeaponstoreDialog(txt)
ShowDialog(5,"Waffenlager Bestand", diatxt, "Schlieen")
Return

:?:/faps::
Sleep, 200
diatxt := cp_getFaps()
diatxt := BuildActivityDialog(diatxt)
ShowDialog(5,"Fraktionsaktivittspunkte", diatxt, "Schlieen")
Return

:?:/bfl::
Sleep, 200
diatxt := cp_getBizlist()
diatxt := BuildBusinessDialog(diatxt)
ShowDialog(5,"Busineesinfo", diatxt, "Schlieen")
Return

:?:/fml::
Sleep, 200
diatxt := cp_getFMembers()
diatxt := BuildFactionMemberDialog(diatxt)
ShowDialog(5,"Fraktionsmitglieder", diatxt, "Schlieen")
Return

:?:/fvl::
Sleep, 200
diatxt := cp_getFVehicles()
diatxt := BuildFactionVehicleDialog(diatxt)
ShowDialog(5,"Fraktionsfahrzeuge", diatxt, "Schlieen")
Return

:?:/hinfo::
Sleep, 200
diatxt := cp_getHouse()
diatxt := BuildHouseDialog(diatxt)
ShowDialog(5,"Hausinformationen", diatxt, "Schlieen")
Return

:?:/finfo::
Sleep, 200
diatxt := cp_getFInfo()
diatxt := BuildFactionInfoDialog(diatxt)
ShowDialog(5,"Fraktionsinformationen", diatxt, "Schlieen")
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
ShowDialog(5,"Team-Online-Liste", diatxt, "Schlieen")
Return

:?:/tl::
Sleep, 200
diatxt := BuildTeamDialog()
ShowDialog(5,"Teamliste", diatxt, "Schlieen")
Return

:?:/leaderol::
Sleep, 200
diatxt := BuildLeaderOL()
ShowDialog(5,"Leader-Online-Liste", diatxt, "Schlieen")
Return

:?:/leader::
Sleep, 200
diatxt := BuildLeaderDialog()
ShowDialog(5,"Leaderliste", diatxt, "Schlieen")
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
AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} luft nicht ab.")
Return

}

Else
{
    AddChatMessage("{006EE6} [CP]: {FFFFFF}Dein "color ""prm[2] "{FFFFFF} luft am " ablauf[1] " um "ablauf[2]" Uhr ab.")
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
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Der Geldlog ist zu gro zum Anzeigen")
}
Else
{
ShowDialog(5,"Geld-LoG", diatxt, "Schlieen")
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
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Der Geldlog ist zu gro zum Anzeigen")
}
Else
{
ShowDialog(5,"Paydays", diatxt, "Schlieen")
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
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Der Geldlog ist zu gro zum Anzeigen")
}
Else
{
ShowDialog(5,"Ticketbersicht", diatxt, "Schlieen")
}
UnBlockChatInput()
BlockInput, Off
Return


F3::
AddChatMessage(StrLen(GetDialogText()))
Return

:?:/buypa::
Sleep, 200
InitPremiumData()
txt := BuildPremiumBuyDialog()
benficiary := ""
ShowDialog(5,"Premiumkauf", txt, "Kaufen", "Schließen")
Loop
{   dialine1 := GetDialogLine(GetDialogIndex())
    if IsDialogButton1Selected() OR GetKeyState("Enter")
    { 
    Sleep, 100
    if !IsDialogOpen()
        Break
    }
        if !IsDialogOpen() OR GetKeyState("Esc")
        {
             AddChatMessage("{006EE6} [CP]: {FFFFFF}Bestelung abgebrochen")
        Return

    }
}
ShowDialog(2,"Empfänger", "Eigener Account`nFremder Account", "Auswählen", "Schließen")
Loop
{   dialine2 := GetDialogLine(GetDialogIndex())
    if IsDialogButton1Selected() OR GetKeyState("Enter")
    { 
    Sleep, 100
    if !IsDialogOpen()
        Break
    }
        if !IsDialogOpen() OR GetKeyState("Esc")
        {
             AddChatMessage("{006EE6} [CP]: {FFFFFF}Bestelung abgebrochen")
        Return
}
}
If (dialine2 == "Fremder Account")
{
    ih := InputHook("V")
    ShowDialog(1,"Empfänger", "Bitte gibt nun den exakten Benutzernamen ein:", "Auswählen", "Schließen")
    ih.start()
    Loop
    {   
        if (IsDialogButton1Selected() OR GetKeyState("Enter"))
        { 
        Sleep, 200
        if !IsDialogOpen()
        {
            ih.stop()
            benficiary := ih.input
            
            
            Break
        }
        }
            if (!IsDialogOpen() OR GetKeyState("Esc"))
            {
                ih.stop()
                AddChatMessage("{006EE6} [CP]: {FFFFFF}Bestelung abgebrochen")
            Return
            }

    }
}
    Else
    {
        benficiary := GetPlayerName()
    }
    benficiary := Trim(Trim(benficiary, "`n"))
if (RegExMatch(benficiary, "^\d+$"))
        if (IsNPCById(benficiary))
   {
       AddChatMessage("{B22222} FEHLER: {FFFFFF} Ungültige Eingabe erkannt!")
       Return 
   }    
   Else
   {
   benficiary := GetPlayerNameById(benficiary)

    If (benficiary = "")
    {
        AddChatMessage("{B22222} FEHLER: {FFFFFF} Ungültige Eingabe erkannt!")
        Return 
    }
}
If (StrLen(benficiary) > 24)
{
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Ungültige Eingabe erkannt!")
}
item := StrSplit(dialine1, A_Tab)
Bestellung := "{FFFFFF}Produkt`t" item[2] "`n{FFFFFF}Laufzeit`t" item[3]  "`nPreis`t`t" item[4]  "`nEmpfänger`t" benficiary
ShowDialog(0,"Bestellübersicht", bestellung, "Bestätigen", "Abbrechen")
Loop
{   dialine2 := GetDialogLine(GetDialogIndex())
    if IsDialogButton1Selected() OR GetKeyState("Enter")
    { 
    Sleep, 100
    if !IsDialogOpen()
    {
        AddChatMessage("{006EE6} [CP]: {FFFFFF}Bestelung wird gesendet")
        Break
    }
}
    if !IsDialogOpen() OR GetKeyState("Esc") 
    {
        AddChatMessage("{006EE6} [CP]: {FFFFFF}Bestelung abgebrochen")
        Return
}
}
cp_buy_premium(benficiary, item[2], item[3]) 
AddChatMessage("{006EE6} [CP]: {FFFFFF}Bestellung für " item[2]  "{FFFFFF} (" item[3]") für " benficiary " aufgegeben")
Return

global PremiumList := []

InitPremiumData()
{
    global PremiumList
    PremiumList := []  ; reset

    data =
    (LTrim
    Premium Bronze|1 Monat|50 LoG-Points
    Premium Silber|1 Monat|100 LoG-Points
    Premium Silber|3 Monate|250 LoG-Points
    Premium Silber|6 Monate|400 LoG-Points
    Premium Gold|1 Monat|200 LoG-Points
    Premium Gold|3 Monate|400 LoG-Points
    Premium Gold|6 Monate|750 LoG-Points
    Premium Platin|1 Monat|250 LoG-Points
    Premium Platin|3 Monate|500 LoG-Points
    Premium Platin|6 Monate|1.000 LoG-Points
    )

    id := 1
    Loop, Parse, data, `n, `r
    {
        parts := StrSplit(A_LoopField, "|")
        obj := {}

        obj.ID     := id
        obj.Art    := parts[1]
        obj.Lauf   := parts[2]
        obj.Preis  := parts[3]

        PremiumList.Push(obj)
        id++
    }
}

BuildPremiumBuyDialog()
{
    global PremiumList

    dialog := "ID`tPremiumart`tLaufzeit`tPreis`n"

    for index, obj in PremiumList
    {
                obj.Art  := StrReplace(obj.Art, "Premium Bronze" , "{CD7F32}Premium Bronze")
        obj.Art := StrReplace(obj.Art, "Premium Gold" , "{FFD700}Premium Gold")
        obj.Art  := StrReplace(obj.Art, "Premium Silber" , "{C0C0C0}Premium Silber")
        obj.Art  := StrReplace(obj.Art, "Premium Platin" , "{868279}Premium Platin")
        dialog .= obj.ID "`t"
                . obj.Art "`t{FFFFFF}"
                . obj.Lauf "`t"
                . obj.Preis "`n"
    }

    return dialog
}


F2::
ih := InputHook("V")
ShowDialog(3,"Passwort", "Bitte Passwort eingeben:", "Login", "Abbrechen")
ih.start()
    Loop
    {   
        if IsDialogButton1Selected() OR GetKeyState("Enter")
        { 
        Sleep, 200
        if !IsDialogOpen()
        {
            ih.stop()
            AddChatMessage(ih.input)
            AddChatMessage(GetDialogLineCount())
            AddChatMessage(pw)
            Break
        }
        }
        if !IsDialogOpen() OR GetKeyState("Esc") 
            {
                AddChatMessage("Abbruch")
            Return
            }

}
