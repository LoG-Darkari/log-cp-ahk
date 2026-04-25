; ============================================================
;   CONTROL PANEL SDK – CORE MODULE
; ============================================================

global CP := { LoggedIn: false, Session: "" }
global CP_PW := ""

http_init() {
    CP.Session := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    CP.Session.SetTimeouts(6000,6000,6000,6000)
    ;AddChatMessage("HTTP-Objekt erstellt")
}

http_Destroy() {
    ;CP.Session.Close()
    ObjRelease(CP.Session)
    CP.Session := ""
    ;AddChatMessage("HTTP-Objekt zerstört")
}

cp_Login() {
    http_init()

    user := GetPlayerName()
    If (CP_PW == "")
    {
    CP_PW := PlayerInput("CP-Passwort: ")
    CP_PW := cp_UrlEncode(CP_PW)
    }
   

    payload := "user=" user "&password=" CP_PW "&login=Login"
    response := http_Request("POST", "https://samp.cp.life-of-german.org/login", payload)

    if (InStr(response, "Gespielte Stunden:")) {
        CP.LoggedIn := true
        ;AddChatMessage("{006EE6} [CP]: {FFFFFF} Login erfolgreich")
        return { success: true, message: "Login erfolgreich" }
    }

    CP.LoggedIn := false
    AddChatMessage("{006EE6} [CP]: {FFFFFF} Login nicht erfolgreich. Nach mehreren Fehlversuchen wirst du 24h gesperrt.")
    CP_PW := ""
    return { success: false, message: "Login fehlgeschlagen" }
}


cp_Logout() {
    http_Request("GET", "https://samp.cp.life-of-german.org/logout")
    ;AddChatMessage("Logout durchgeführt")
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
    If (url = "https://samp.cp.life-of-german.org/home/premiumduration")
    {
    var := CP.Session.ResponseText()
    ;FileDelete, response.log
    ;FileAppend, %var% , response.log
    }

    ;return { text: CP.Session.ResponseText(), status: CP.Session.Status }
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