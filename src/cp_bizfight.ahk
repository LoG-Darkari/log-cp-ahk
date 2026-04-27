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

        schutzgeld  := StrReplace(schutzgeld, "Niemand" , "{6495ED}Los Santos Police Department")
        schutzgeld  := StrReplace(schutzgeld, "Grove Street Families" , "{006600}Grove Street Families")
        schutzgeld  := StrReplace(schutzgeld, "Front Yard Ballas" , "{660066}Front Yard Ballas")
        schutzgeld  := StrReplace(schutzgeld, "Triaden Mafia" , "{FFFF80}Triaden Mafia")
        schutzgeld  := StrReplace(schutzgeld, "Yakuza Mafia" , "{DB7B9D}Yakuza Mafia")
        schutzgeld  := StrReplace(schutzgeld, "Russen Mafia" , "{666666}Russen Mafia")
        ; Angriff möglich aus Icon erkennen
        if InStr(tr, "circle_green")
        angriff := "{32CD32}Angriff möglich"
        else
        angriff := "{C41E3A}Angriff nicht möglich"

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
    cp_Logout()
    return response
}