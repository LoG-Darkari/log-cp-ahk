og_ParseHouseInformation(html)
{
    house := {}

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        ; Zwei <td>-Zellen extrahieren
        if RegExMatch(tr, "<td[^>]*>(.*?)</td>.*?<td[^>]*>(.*?)</td>", c)
        {
            key := RegExReplace(c1, "<[^>]+>")
            key := Trim(RegExReplace(key, "\s+", " "))

            valRaw := c2

            ; Wert bereinigen
            val := RegExReplace(valRaw, "<[^>]+>")
            val := Trim(RegExReplace(val, "\s+", " "))

            ; Spezialfälle: Icons → true/false
            if InStr(valRaw, "valid.png")
                val := "Ja"
            else if InStr(valRaw, "invalid.png")
                val := "Nein"

            ; Key normalisieren
            key := StrReplace(key, ":", "")
            key := StrReplace(key, "(Truhen-Upgrade)", "InventarUpgrade")
            key := StrReplace(key, "Inventar", "InventarUpgrade")
            key := StrReplace(key, "Heal-Upgrade", "HealUpgrade")

            house[key] := val
        }
    }

    return house
}

ParseHouseInformation(html)
{
    house := {}

    pos := 1
    ; DOTALL: "s)" damit .* auch über Zeilen geht
    while pos := RegExMatch(html, "s)<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        ; Alle <td>-Zellen extrahieren (auch hier DOTALL)
        rawCols := []
        cpos := 1
        while cpos := RegExMatch(tr, "s)<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)
            rawCols.Push(c1)
        }

        ; Wir brauchen genau 2 Spalten: Key + Value
        if (rawCols.MaxIndex() != 2)
            continue

        ; Key bereinigen
        key := RegExReplace(rawCols[1], "<[^>]+>")
        key := RegExReplace(key, "\s+", " ")
        key := Trim(key)
        key := StrReplace(key, ":", "")

        ; Value bereinigen
        rawVal := rawCols[2]
        val := RegExReplace(rawVal, "<[^>]+>")
        val := RegExReplace(val, "\s+", " ")
        val := Trim(val)

        ; Icons erkennen
        if InStr(rawVal, "valid.png")
            val := "Ja"
        else if InStr(rawVal, "invalid.png")
            val := "Nein"

        ; Key normalisieren
        ;key := StrReplace(key, "(Truhen-Upgrade)", "InventarUpgrade")
        key := StrReplace(key, "Inventar", "Inventar-Upgrade")
        key := StrReplace(key, "Heal-Upgrade", "Heal-Upgrade")

        house[key] := val
    }

    return house
}


BuildHouseDialog(html)
{
    info := ParseHouseInformation(html)

    dialog := "Eigenschaft`tWert`n"
    for key, val in info
        dialog .= key "`t" val "`n"

    return dialog
}



og_BuildHouseDialog(html)
{
    info := ParseHouseInformation(html)

    dialog := "Eigenschaft`tWert`n"

    for key, val in info
        dialog .= key "`t" val "`n"

    return dialog
}

cp_getHouse()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/house/information","")
    cp_Logout()
    return response
}