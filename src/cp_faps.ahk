ParseActivityPoints(html)
{
    items := []

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        ; Spalten extrahieren
        cols := []
        cpos := 1
        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)
            text := RegExReplace(c1, "<[^>]+>") ; HTML Tags entfernen
            text := Trim(text)
            cols.Push(text)
        }

        ; Header-Zeilen überspringen
        if (cols.MaxIndex() < 2)
            continue

        aktion := cols[1]
        punkte := cols[2]

        items.Push(aktion "`t" punkte)
    }

    return items
}

BuildActivityDialog(html)
{
    rows := ParseActivityPoints(html)

    dialog := "Aktion`tPunkte`n"
    for index, line in rows
        dialog .= line "`n"

    return dialog
}

cp_getFaps()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/activitypoints","")
    ;AddChatMessage("Reponse Länge - " StrLen(response))
    cp_Logout()
    ;AddChatMessage("CP logout")
    return response
}