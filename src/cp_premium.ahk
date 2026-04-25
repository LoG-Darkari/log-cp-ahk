GetActivePremium(html)
{
    ; Alle <tr> Zeilen finden
    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos+StrLen(m))
    {
        tr := m1

        ; Alle <td> Inhalte extrahieren
        cols := []
        cpos := 1
        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos+StrLen(c))
        {
            text := c1
            text := RegExReplace(text, "<[^>]+>") ; HTML Tags entfernen
            text := Trim(text)
            cols.Push(text)
        }

        ; Wir brauchen mindestens 5 Spalten
        if (cols.MaxIndex() < 5)
            continue

        status  := cols[1]
        produkt := cols[2]
        ablauf  := cols[5]

        ; Nur den aktiven Eintrag zurückgeben
        if (status = "Aktiv")
            return status " | " produkt " | " ablauf
    }

    return ""  ; Kein aktiver Eintrag gefunden
}


BuildPremiumDialog(html)
{
    ;AddChatMessage("HTML: "strlen(html))
    ;FileDelete, html.log
    ;FileAppend, %html% , html.log
    rows := []

    ; Alle <tr> Zeilen finden
    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos+StrLen(m))
    {
        tr := m1

        ; Alle <td> Inhalte extrahieren
        cols := []
        cpos := 1
        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos+StrLen(c))
        {
            text := c1
            text := RegExReplace(text, "<[^>]+>") ; HTML Tags entfernen
            text := Trim(text)
            cols.Push(text)
        }

        ; Wir brauchen nur Zeilen mit mindestens 5 Spalten
        if (cols.MaxIndex() < 5)
            continue

        status  := cols[1]
        produkt := cols[2]
        ablauf  := cols[5]

        rows.Push(status "`t" produkt "`t" ablauf)
    }

    ; Dialogstring bauen
    dialog := "Status`tProdukt`tAblaufdatum`n"
    for index, line in rows
        dialog .= line "`n"

    return dialog
}



cp_getPremium()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/home/premiumduration","")
    cp_Logout()
    return response
}

