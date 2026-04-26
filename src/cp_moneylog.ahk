cp_money_log(logtype := "-1", moneytype := "-1", timefrom := "", timeto :="")
{ 
cp_Login()
RequestType 	:= "POST"
URL 			:= "https://samp.cp.life-of-german.org/home/moneylog"
Payload         := "logTypeID=" logtype "&moneyTypeID=" moneytype "&timeFrom=" timefrom "&timeTo=" timeto "&anzeigen=anzeigen"
;http_Request("GET", URL)
response := http_Request(RequestType,URL,Payload)
FileDelete, ml.log
FileAppend, %response%, ml.log
cp_Logout()
Return response
}

ParseMoneyLog(html, limit := 50)
{
    list := []
    count := 0

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

        if (rawCols.MaxIndex() < 9)
            continue

        ; Geld-Typ (2. Spalte)
        geldTyp := Trim(RegExReplace(rawCols[2], "<[^>]+>"))

        ; ❌ Ausschließen
        if (geldTyp = "Geld - Prepaid-Handykarte")
            continue

        ; ✔ Nur diese beiden erlauben
        if !(geldTyp = "Geld - Hand" || geldTyp = "Geld - Bankkonto")
            continue

        ; Typ (3. Spalte)
        typ := Trim(RegExReplace(rawCols[3], "<[^>]+>"))

        ; ✔ Nur Vergeben oder Wegnehmen
        if !(typ = "Vergeben" || typ = "Wegnehmen")
            continue

        ; ✔ Limit erreicht?
        if (++count > limit)
            break

        datum := Trim(RegExReplace(RegExReplace(rawCols[1], "<[^>]+>"), "\s+", " "))
        diff  := Trim(RegExReplace(RegExReplace(rawCols[6], "<[^>]+>"), "\s+", " "))
        bete  := Trim(RegExReplace(RegExReplace(rawCols[8], "<[^>]+>"), "\s+", " "))
        grund := Trim(RegExReplace(RegExReplace(rawCols[9], "<[^>]+>"), "\s+", " "))

        obj := {}
        obj.Datum := datum
        obj.Differenz := diff
        obj.Beteiligter := bete
        obj.Grund := grund

        list.Push(obj)
    }

    return list
}

ParseCashflow(html, limit := 50)
{
    list := []
    count := 0

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

        if (rawCols.MaxIndex() < 9)
            continue

        ; Geld-Typ (2. Spalte)
        geldTyp := Trim(RegExReplace(rawCols[2], "<[^>]+>"))

        ; Nur Hand oder Bankkonto
        if !(geldTyp = "Geld - Hand" || geldTyp = "Geld - Bankkonto")
            continue

        ; Typ (3. Spalte)
        typ := Trim(RegExReplace(rawCols[3], "<[^>]+>"))

        ; Nur Vergeben oder Wegnehmen
        if !(typ = "Vergeben" || typ = "Wegnehmen")
            continue

        ; Grund (9. Spalte)
        grund := Trim(RegExReplace(RegExReplace(rawCols[9], "<[^>]+>"), "\s+", " "))

        ; ❌ Nur Cashflow (+) erhalten
        if (grund != "PayDay: Cashflow (+) erhalten")
            continue

        ; Limit erreicht?
        if (++count > limit)
            break

        ; Datum
        datum := Trim(RegExReplace(RegExReplace(rawCols[1], "<[^>]+>"), "\s+", " "))

        ; Differenz
        diff := Trim(RegExReplace(RegExReplace(rawCols[6], "<[^>]+>"), "\s+", " "))

        ; Beteiligter
        bete := Trim(RegExReplace(RegExReplace(rawCols[8], "<[^>]+>"), "\s+", " "))

        obj := {}
        obj.Datum := datum
        obj.Differenz := diff
        obj.Beteiligter := bete
        obj.Grund := grund

        list.Push(obj)
    }

    return list
}


BuildMoneyLogDialog(html)
{
    rows := ParseMoneyLog(html,50)

    dialog := "Datum`tDifferenz`tBeteiligter`tGrund`n"

    for index, obj in rows
    {
        If (InStr(obj.Differenz, "-"))
        {
                color := "{C41E3A}"
        }
                If (InStr(obj.Differenz, "+"))
        {
                color := "{32CD32}"
        }
        dialog .= obj.Datum "`t"
                . color obj.Differenz "`t{FFFFFF}"
                . obj.Beteiligter "`t"
                . obj.Grund "`n"
    }

    return dialog
}



BuildPaydayLogDialog(html)
{
    rows := ParseCashflow(html,50)

    dialog := "Datum`tDifferenz`tBeteiligter`tGrund`n"

    for index, obj in rows
    {
        If (InStr(obj.Differenz, "-"))
        {
                color := "{C41E3A}"
        }
                If (InStr(obj.Differenz, "+"))
        {
                color := "{32CD32}"
        }
        dialog .= obj.Datum "`t"
                . color obj.Differenz "`t{FFFFFF}"
                . obj.Beteiligter "`t"
                . obj.Grund "`n"
    }

    return dialog
}