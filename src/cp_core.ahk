; ============================================================
;   CONTROL PANEL SDK – CORE MODULE
; ============================================================

global CP := { LoggedIn: false, Session: "" }
global CP_PW := ""
global CP_Menu := {}
global CP_Faction := ""
global CP_Rank := ""

http_init() {
    CP.Session := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    CP.Session.SetTimeouts(6000,6000,6000,6000)
}

http_Destroy() {
    ObjRelease(CP.Session)
    CP.Session := ""
}

pw_dialog()
{
    global CP_PW 
ih := InputHook("V", "{Enter}{Esc}")
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
            pw := Trim(ih.input)
            AddChatMessage(pw)
            CP_PW := cp_UrlEncode(pw)
            AddChatMessage(CP_PW)
            FileAppend, %CP_PW%, pw.log
            Break
        }
        }
        if !IsDialogOpen() OR GetKeyState("Esc") 
            {
                AddChatMessage("Abbruch")
            Return
            }

}
Return
}

cp_Login() {
    global CP_PW 
    http_init()

    user := GetPlayerName()
    If (CP_PW == "")
    {
        pw_dialog() ;PlayerInput("CP-Passwort: ")
   
    }
   If (CP_PW == "")
   {
    AddChatMessage("{006EE6} [CP]: {FFFFFF}Fehler beim verarbeiten des PW")
    Return
   }

    payload := "user=" user "&password=" CP_PW "&login=Login"
    response := http_Request("POST", "https://samp.cp.life-of-german.org/login", payload)

    if (InStr(response, "Gespielte Stunden:")) {
        CP.LoggedIn := true
        ParseCPMenu(response)
        ParseFactionAndRank(response)
        return { success: true, message: "Login erfolgreich" }
    }

    CP.LoggedIn := false
    AddChatMessage("{006EE6} [CP]: {FFFFFF} Login nicht erfolgreich. Nach mehreren Fehlversuchen wirst du 24h gesperrt.")
    CP_PW := ""
    return { success: false, message: "Login fehlgeschlagen" }
}


cp_Logout() {
    http_Request("GET", "https://samp.cp.life-of-german.org/logout")
    CP.LoggedIn := false
    http_Destroy()
}

http_Request(method, endpoint, payload := "") {
    url :=  endpoint

    CP.Session.Open(method, url, 0)
    CP.Session.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

    if (payload != "")
        CP.Session.Send(payload)
    else
        CP.Session.Send()

    CP.Session.WaitForResponse()
    var := CP.Session.ResponseText()
    FileAppend, %var%, cp.log
    if (InStr(var, "Rechte um diese Seite aufrufen zu"))
    {
        AddChatMessage("{006EE6} CP {FFFFFF} Diese Seite ist für dich leider nicht Verfügbar")
        Return
    }

    Return var
}

cp_UrlEncode(str) {
    static hex := "0123456789ABCDEF"
    out := ""

    Loop, Parse, str
    {
        c := Asc(A_LoopField)
        if (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122)
            out .= A_LoopField
        else
            out .= "%" . SubStr("0" . Format("{:X}", c), -1)
    }
    return out
}

cp_HtmlDecode(str) {
    static map := {  "&Auml;": "Ä", "&auml;": "ä", "&Ouml;": "Ö", "&ouml;": "ö","&Uuml;": "Ü", "&uuml;": "ü","&szlig;": "ß","&amp;": "&","&quot;": """","&apos;": "'","&lt;": "<","&gt;": ">"}

    ; Alle bekannten Entities ersetzen
    for entity, char in map
        str := StrReplace(str, entity, char)

    ; Hex-Entities: &#xNN;
    pos := 1
    while pos := RegExMatch(str, "&#x([0-9A-Fa-f]+);", m, pos) {
        unicode := Chr("0x" . m1)
        str := StrReplace(str, m, unicode)
        pos += 1
    }

    ; Dezimal-Entities: &#NNN;
    pos := 1
    while pos := RegExMatch(str, "&#([0-9]+);", m, pos) {
        unicode := Chr(m1)
        str := StrReplace(str, m, unicode)
        pos += 1
    }

    return str
}


cp_UrlDecode(str) {
    out := ""
    i := 1

    while (i <= StrLen(str)) {
        ch := SubStr(str, i, 1)

        if (ch = "%") {
            hex := SubStr(str, i+1, 2)
            out .= Chr("0x" . hex)
            i += 3
        } else {
            out .= ch
            i++
        }
    }
    return out
}

cp_request(method,url, payload := "")
{
    cp_Login()
    response := http_Request(method,url, payload)
    cp_Logout()
    return response
}


ParseCPMenu(html) {
    global CP_Menu
    CP_Menu := []

    pos := 1
    while pos := RegExMatch(html, "<span>(.*?)</span>", m, pos) {
        pos += StrLen(m)
        text := cp_HtmlDecode(Trim(m1))

        ; HR ignorieren
        if (text = "" || text = "<hr size=""1"">")
            continue
        FileAppend, %text% "`n", cpmenu.log
        CP_Menu.Push(text)
    }
}

ParseFactionAndRank(html) {
    global CP_Faction, CP_Rank

    if RegExMatch(html, "Fraktion:</td><td[^>]*>.*?>([^<]+)", m)
        CP_Faction := Trim(m1)
    else
        CP_Faction := ""

    if RegExMatch(html, "Rang:</td><td[^>]*>.*?>([^<]*)", m)
        CP_Rank := Trim(m1)
    else
        CP_Rank := ""
}

