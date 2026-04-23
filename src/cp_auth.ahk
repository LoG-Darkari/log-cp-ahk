global cpLoggedIn := 0
global cpSession := ""
global CP_USERNAME := ""
global CP_PASSWORD := ""

cp_login() {
    global CP_USERNAME, CP_PASSWORD, cpLoggedIn, cpSession

    if (CP_USERNAME = "" || CP_PASSWORD = "")
        return false

    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", "https://samp.cp.life-of-german.org/login", false)
    whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    whr.Send("username=" CP_USERNAME "&password=" CP_PASSWORD)

    cpSession := whr.GetResponseHeader("Set-Cookie")
    cpLoggedIn := 1
    return true
}

cp_logout() {
    global cpLoggedIn
    cpLoggedIn := 0
}
