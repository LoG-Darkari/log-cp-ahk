; ============================================================
;   CONTROL PANEL SDK – CORE MODULE
; ============================================================

global CP := { LoggedIn: false, Session: "" }

http_init() {
    CP.Session := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    CP.Session.SetTimeouts(6000,6000,6000,6000)
    ;AddChatMessage("HTTP-OBjekt erstellt")
}

http_Destroy() {
    ObjRelease(CP.Session)
    CP.Session := ""
    ;AddChatMessage("HTTP-OBjekt zerstört")
}

cp_Login() {
    http_init()

    user := GetPlayerName()
    pw := PlayerInput("CP-Passwort: ")
    pw := cp_UrlEncode(pw)

    payload := "user=" user "&password=" pw "&login=Login"
    response := cp_Request("POST", "https://samp.cp.life-of-german.org/login", payload)

    if (InStr(response.text, "Gespielte Stunden:")) {
        CP.LoggedIn := true
        ;AddChatMessage("CP: Login erfolgreich")
        return { success: true, message: "Login erfolgreich" }
    }

    CP.LoggedIn := false
    ;AddChatMessage("Login nicht erfolgreich")
    return { success: false, message: "Login fehlgeschlagen" }
}

cp_Logout() {
    cp_Request("GET", "https://samp.cp.life-of-german.org/logout")
    ;AddChatMessage("Logout durchgeführt")
    CP.LoggedIn := false
    http_Destroy()
}

cp_Request(method, endpoint, payload := "") {
    url :=  endpoint

    CP.Session.Open(method, url, 0)
    CP.Session.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

    if (payload != "")
        CP.Session.Send(payload)
    else
        CP.Session.Send()

    CP.Session.WaitForResponse()

    return { text: CP.Session.ResponseText(), status: CP.Session.Status }
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
