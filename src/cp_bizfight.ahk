ParseBusinessInfo(html)
{
    items := []

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        ; <td> Inhalte extrahieren
        cols := []
        cpos := 1
        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)

            ; HTML entfernen
            text := RegExReplace(c1, "<[^>]+>")

            ; Whitespace normalisieren
            text := RegExReplace(text, "\s+", " ")
            text := Trim(text)

            cols.Push(text)
        }

        ; Header-Zeilen überspringen
        if (cols.MaxIndex() < 4)
            continue

        business   := cols[1]
        besitzer   := cols[2]
        schutzgeld := cols[3]

        ; Angriff möglich aus Icon erkennen
        if InStr(tr, "circle_green")
            angriff := "Ja"
        else
            angriff := "Nein"

        items.Push(business "`t" besitzer "`t" schutzgeld "`t" angriff)
    }

    return items
}


BuildBusinessDialog(html)
{
    rows := ParseBusinessInfo(html)

    dialog := "Business`tBesitzer`tSchutzgeld`tAngriff`n"
    for index, line in rows
        dialog .= line "`n"

    return dialog
}

GetAttackableBusinesses(html)
{
    list := []
    rows := ParseBusinessInfo(html)

    for index, line in rows
    {
        StringSplit, p, line, %A_Tab%
        if (p4 = "Ja")
            list.Push(line)
    }

    return list
}

cp_getBizlist()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/businessinfo","")
    ;AddChatMessage("Reponse Länge - " StrLen(response))
    cp_Logout()
    ;AddChatMessage("CP logout")
    return response
}