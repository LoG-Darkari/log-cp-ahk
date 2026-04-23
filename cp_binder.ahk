; ============================================================
; Life of German – Keybinder (Final Version)
; SAMP-UDF + ControlPanel SDK + sichere Passwortabfrage
; ============================================================
if not A_IsAdmin{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

SendMode Input
SetWorkingDir %A_ScriptDir%

SetTimer, c_hook, 150

global LAST_CHAT_LINE := ""

c_hook:
    GetChatLine(0, line)

    if (line = "" || line = LAST_CHAT_LINE)
        return

    LAST_CHAT_LINE := line
SAMP_OnChatMessage(line)
Return

; ------------------------------------------------------------
; SAMP UDF laden
; ------------------------------------------------------------
#Include %A_ScriptDir%\src\SAMP.ahk

; ------------------------------------------------------------
; ControlPanel SDK laden
; ------------------------------------------------------------
#Include %A_ScriptDir%\include.ahk


; ============================================================
; SICHERE PASSWORT-EINGABE
; ============================================================

PlayerInput(text){
    s := A_IsSuspended
    Suspend On
    KeyWait Enter
    SendInput t^a{backspace}%text%
    Input, var, v, {enter}
    SendInput ^a{backspace 100}{enter}
    Sleep, 20
    if(!s)
        Suspend Off
    return var
}

AskForPassword() {
    global CP_PASSWORD
    CP_PASSWORD := PlayerInput("CP Passwort:")
    return (CP_PASSWORD != "")
}



; ============================================================
; COMMAND REGISTRY
; ============================================================

global Commands := {}

RegisterCommand(cmd, desc, func) {
    global Commands
    Commands[cmd] := { "desc": desc, "func": func }
}

ShowHelp() {
    global Commands
    text := "{00C0FF}Verfügbare Befehle:`n`n"
    for cmd, data in Commands
        text .= "{FFFFFF}" cmd " – " data.desc "`n"
    ShowDialog(0, "Hilfe", text, "OK")
}

ShowHelpCommand(cmd) {
    global Commands
    if (!Commands.HasKey(cmd)) {
        AddChatMessage("Unbekannter Befehl: " cmd)
        return
    }
    data := Commands[cmd]
    ShowDialog(0, "Hilfe: " cmd, "{FFFFFF}" data.desc, "OK")
}


; ============================================================
; BEFEHLE REGISTRIEREN
; ============================================================

RegisterCommand("/skin",      "Ändert deinen Skin über das CP",                "cmd_skin")
RegisterCommand("/skinlist",  "Zeigt erlaubte Skins (civ/fac)",                "cmd_skinlist")
RegisterCommand("/activity",  "Zeigt Activity-Points deiner Fraktion",         "cmd_activity")
RegisterCommand("/premium",   "Zeigt deinen Premiumstatus",                    "cmd_premium")
RegisterCommand("/absent",    "Setzt eine Abwesenheitsmeldung",               "cmd_absent")
RegisterCommand("/vehicles",  "Zeigt Fraktionsfahrzeuge + Checkpoint",         "cmd_vehicles")
RegisterCommand("/team",      "Zeigt Teammitglieder + Online-Status",          "cmd_team")
RegisterCommand("/help",      "Zeigt diese Hilfe an",                          "cmd_help")


; ============================================================
; COMMAND HANDLER
; ============================================================

cmd_skin(params) {
    if cp_changeSkin(params)
        AddChatMessage("Skin geändert.")
    else
        AddChatMessage("Skin nicht erlaubt.")
}

cmd_skinlist(params) {
    cp_loadSkinLists()
    text := ""
    if (params = "civ")
        for id, _ in CivSkins
            text .= id " "
    else
        for id, _ in FacSkins
            text .= id " "
    ShowDialog(0, "Skins", text, "OK")
}

cmd_activity(params) {
    html := cp_loadActivityPoints()
    data := parseActivityPoints(html)
    text := ""
    for name, pts in data
        text .= name ": " pts "`n"
    ShowDialog(0, "Activity", text, "OK")
}

cmd_premium(params) {
    p := cp_getPremium()
    AddChatMessage("Premium: " p.produkt)
    AddChatMessage("Ablauf: " p.ablauf)
}

cmd_absent(params) {
    StringSplit, p, params, %A_Space%
    days := p1
    desc := ""
    Loop % p0-1
        desc .= p%A_Index%+1 " "
    cp_setAbsent(days, Trim(desc))
    AddChatMessage("Abwesenheit gesetzt.")
}

cmd_vehicles(params) {
    cp_login()
    html := cp_action("GET", "https://samp.cp.life-of-german.org/faction/vehicles")
    cp_logout()

    vehicles := parseFactionVehicles(html)
    text := ""
    for i, v in vehicles
        text .= i ": " v.id " | " v.name " | Rang " v.rank "`n"

    ShowDialog(0, "Fahrzeuge", text, "OK")
}

cmd_team(params) {
    cp_login()
    html := cp_action("GET", "https://life-of-german.org/team")
    cp_logout()

    team := parseTeam(html)
    text := ""

    for name, roles in team {
        id := GetPlayerIdByName(name)
        status := (id != -1) ? "Online" : "Offline"

        text .= name " (" status "): "
        for i, r in roles
            text .= r (i < roles.MaxIndex() ? ", " : "")
        text .= "`n"
    }

    ShowDialog(0, "Team", text, "OK")
}

cmd_help(params) {
    if (params = "")
        ShowHelp()
    else
        ShowHelpCommand("/" params)
}

; ============================================================
; SAMP CHAT HOOK
; ============================================================

SAMP_OnChatMessage(text) {

    if (SubStr(text, 1, 1) = "/") {

        StringSplit, p, text, %A_Space%
        cmd := p1
        params := SubStr(text, StrLen(p1) + 2)

        global Commands
        if (Commands.HasKey(cmd)) {
            func := Commands[cmd].func
            %func%(params)
            return 0
        }
    }

    return 1
}