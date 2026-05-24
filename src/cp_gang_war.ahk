ParseWarGebiete(html)
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

            text := RegExReplace(c1, "<[^>]+>") ; HTML entfernen
            text := RegExReplace(text, "\s+", " ")
            text := Trim(text)

            cols.Push(text)
        }

        ; Header überspringen
        if (cols.MaxIndex() < 3)
            continue

        gebiet := cols[1]
        zugeh  := cols[2]

        ; Angriff möglich anhand des Icons
        if InStr(tr, "circle_green")
            angriff := "{32CD32}Angriff möglich"
        else
            angriff := "{C41E3A}Angriff nicht möglich"

        items.Push(gebiet "`t" zugeh "`t" angriff)
    }

    return items
}

BuildWarDialog(html)
{
    rows := ParseWarGebiete(html)

    dialog := "Gebiet`tZugehörigkeit`tAngriff`n"
    for index, line in rows
        dialog .= line "`n"

    return dialog
}

GetAttackableWarGebiete(html)
{
    list := []
    rows := ParseWarGebiete(html)

    for index, line in rows
    {
        StringSplit, p, line, %A_Tab%
        if InStr(p3, "Angriff möglich")
            list.Push(line)
    }

    return list
}

cp_getGangWarGebiete()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/gangwarinfo","")
    cp_Logout()
    return response
}

cp_getWarGebiete()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/warinfo","")
    FileAppend, %response%, war.log
    cp_Logout()
    return response
}

ParseGangwarGebiete(html)
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

            text := RegExReplace(c1, "<[^>]+>") ; HTML entfernen
            text := RegExReplace(text, "\s+", " ")
            text := Trim(text)

            cols.Push(text)
        }

        ; Header überspringen
        if (cols.MaxIndex() < 3)
            continue

        gebiet := cols[1]
        zugeh  := cols[2]

        ; Angriff möglich anhand des Icons
        if InStr(tr, "circle_green")
            angriff := "{32CD32}Angriff möglich"
        else
            angriff := "{C41E3A}Angriff nicht möglich"

        items.Push(gebiet "`t" zugeh "`t" angriff)
    }

    return items
}

BuildGangwarDialog(html)
{
    rows := ParseGangwarGebiete(html)

    dialog := "Gebiet`tZugehörigkeit`tAngriff`n"
    for index, line in rows
        dialog .= line "`n"

    return dialog
}

GetAttackableGangwar(html)
{
    list := []
    rows := ParseGangwarGebiete(html)

    for index, line in rows
    {
        StringSplit, p, line, %A_Tab%
        if InStr(p3, "Angriff möglich")
            list.Push(line)
    }

    return list
}
