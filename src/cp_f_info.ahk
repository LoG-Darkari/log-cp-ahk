ParseFactionInfo(html)
{
    info := {}

    pos := 1
    while pos := RegExMatch(html, "s)<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        rawCols := []
        cpos := 1
        while cpos := RegExMatch(tr, "s)<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)
            rawCols.Push(c1)
        }

        if (rawCols.MaxIndex() != 2)
            continue

        rawKey := rawCols[1]
        rawVal := rawCols[2]

        key := RegExReplace(rawKey, "<[^>]+>")
        key := Trim(RegExReplace(key, "\s+", " "))
        key := StrReplace(key, ":", "")

        val := RegExReplace(rawVal, "<[^>]+>")
        val := Trim(RegExReplace(val, "\s+", " "))

        if InStr(rawVal, "valid.png")
            val := "Ja"
        else if InStr(rawVal, "invalid.png")
            val := "Nein"

        ; interne Keys
        if (key = "Fraktionslogo")
            key := "Logo"
        else if (key = "Fraktionsbezeichnung")
            key := "Name"
        else if (key = "Mindestlevel")
            key := "MinLevel"
        else if (key = "1 Tag-Schnitt")
            key := "Schnitt1"
        else if (key = "14 Tage-Schnitt")
            key := "Schnitt14"
        else if (key = "30 Tage-Schnitt")
            key := "Schnitt30"
        else if (key = "Fraktionskasse")
            key := "Kasse"
        else if (key = "Letzter Waffentransport")
            key := "LetzterWT"

        info[key] := val
    }

    return info
}


BuildFactionInfoDialog(html)
{
    info := ParseFactionInfo(html)

    ; Reihenfolge festlegen
    order := ["Name", "MinLevel", "Leader", "Member", "Gesamt"
            , "Schnitt1", "Schnitt14", "Schnitt30"
            , "Kasse", "LetzterWT"]

    ; Anzeigenamen
    display := {}
    display["Name"]       := "Fraktion"
    display["MinLevel"]   := "Mindestlevel"
    display["Leader"]     := "Leader"
    display["Member"]     := "Member"
    display["Gesamt"]     := "Gesamt"
    display["Schnitt1"]   := "Schnitt 1 Tag"
    display["Schnitt14"]  := "Schnitt 14 Tage"
    display["Schnitt30"]  := "Schnitt 30 Tage"
    display["Kasse"]      := "Fraktionskasse"
    display["LetzterWT"]  := "Letzter Wsffentransport"

    dialog := "Eigenschaft`tWert`n"

    for _, key in order
    {
        if info.HasKey(key)
            dialog .= display[key] "`t" info[key] "`n"
    }

    return dialog
}



cp_getFInfo()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/info","")
    cp_Logout()
    return response
}