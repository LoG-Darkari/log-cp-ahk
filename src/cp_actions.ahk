cp_action(method, url, payload := "") {
    global cpSession

    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open(method, url, false)
    whr.SetRequestHeader("Cookie", cpSession)

    if (method = "POST")
        whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

    whr.Send(payload)
    return whr.ResponseText
}
