
cp_getWeaponstore()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/weaponstore","")
    cp_Logout()
    return response
}


ParseWeaponstore(html)
{
    items := []

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)  ; wichtig: pos korrekt erhöhen
        tr := m1

        ; <td> Inhalte extrahieren
        cols := []
        cpos := 1
        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)
            text := RegExReplace(c1, "<[^>]+>") ; HTML Tags entfernen
            text := Trim(text)
            cols.Push(text)
        }

        ; Wir brauchen mindestens 2 Spalten: Gegenstand + Menge
        if (cols.MaxIndex() < 2)
            continue

        item  := cols[1]
        menge := cols[2]

        items.Push(item "`t" menge)
    }

    return items
}

BuildWeaponstoreDialog(html)
{
    rows := ParseWeaponstore(html)

    dialog := "Gegenstand`tMenge`n"
    for index, line in rows
        dialog .= line "`n"

    return dialog
}
