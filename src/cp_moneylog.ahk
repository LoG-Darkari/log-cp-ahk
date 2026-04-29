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

        ; ? Ausschließen
        if (geldTyp = "Geld - Prepaid-Handykarte")
            continue

        ; ? Nur diese beiden erlauben
        if !(geldTyp = "Geld - Hand" || geldTyp = "Geld - Bankkonto")
            continue

        ; Typ (3. Spalte)
        typ := Trim(RegExReplace(rawCols[3], "<[^>]+>"))

        ; ? Nur Vergeben oder Wegnehmen
        if !(typ = "Vergeben" || typ = "Wegnehmen")
            continue

        ; ? Limit erreicht?
        if (++count > limit)
            break

        datum := Trim(RegExReplace(RegExReplace(rawCols[1], "<[^>]+>"), "\s+", " "))
        diff  := Trim(RegExReplace(RegExReplace(rawCols[6], "<[^>]+>"), "\s+", " "))
        bete  := Trim(RegExReplace(RegExReplace(rawCols[8], "<[^>]+>"), "\s+", " "))
        grund := Trim(RegExReplace(RegExReplace(rawCols[9], "<[^>]+>"), "\s+", " "))
        grund := ReplaceMapped(grund)

        obj := {}
        obj.Datum := FormatDate(FormatDate(datum))
        obj.Differenz := diff
        obj.Beteiligter := bete
        obj.Grund := ReplaceMapped(grund)

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

        ; ? Nur Cashflow (+) erhalten
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
        obj.Datum := FormatDate(FormatDate(datum))
        obj.Differenz := diff
        obj.Beteiligter := bete
        obj.Grund := ReplaceMapped(grund)

        list.Push(obj)
    }

    return list
}


BuildMoneyLogDialog(html)
{
    rows := ParseMoneyLog(html,80)

    dialog := "Datum`tDifferenz`tBeteiligter`tGrund`n"

    for index, obj in rows
    {
        If (InStr(obj.Differenz, "-"))
        {
                obj.Differenz := StrReplace(obj.Differenz, "- $")
                color := "{C41E3A}"
        }
                If (InStr(obj.Differenz, "+ "))
        {
                obj.Differenz := StrReplace(obj.Differenz, "+ $")
                color := "{32CD32}"
        }
        dialog .= Trim(obj.Datum) "`t"
                . color Trim(obj.Differenz) "`t{FFFFFF}"
                . Trim(obj.Beteiligter) "`t"
                . Trim(obj.Grund) "`n"
    }

    return dialog
}



BuildPaydayLogDialog(html)
{
    rows := ParseCashflow(html,100)

    dialog := "Datum`tCashflow`t`n"

    for index, obj in rows
    {
         {
                obj.Differenz := StrReplace(obj.Differenz, "- $")
                color := "{C41E3A}"
        }
                If (InStr(obj.Differenz, ""))
        {
                obj.Differenz := StrReplace(obj.Differenz, "+ $")
                color := "{32CD32}"
        }
        dialog .= Trim(obj.Datum) "`t"
                . color Trim(obj.Differenz) "`t`n{FFFFFF}"
    }

    return dialog
}

FormatDate(str) {
    ; Erwartet Format: DD.MM.YYYY HH:MM:SS

    ; Jahr kürzen: 2026 ? 26
    str := RegExReplace(str, "(\d{2}\.\d{2}\.)20(\d{2})", "$1$2")

    ; Sekunden entfernen: HH:MM:SS ? HH:MM
    str := RegExReplace(str, "(\d{2}:\d{2}):\d{2}", "$1")

    return str
}

/*
ReplaceMapped(str) {
    static rules := []

    ; -------------------------
    ; EXAKTE MATCHES
    ; -------------------------
    rules.Push({ type: "exact", find: "24/7-Shop", replace: "24/7" })
    rules.Push({ type: "exact", find: "Angeln: Geldbeutel im Meer gefunden", replace: "Fund" })
    rules.Push({ type: "exact", find: "Appartement erworben", replace: "Appartment" })
    rules.Push({ type: "exact", find: "Bar", replace: "Bar" })
    rules.Push({ type: "exact", find: "Bus-Ticket bezahlt", replace: "Bus" })
    rules.Push({ type: "exact", find: "Car-Terminal", replace: "CT" })
    rules.Push({ type: "exact", find: "Casino", replace: "Casino" })
    rules.Push({ type: "exact", find: "Drogen verkauft", replace: "Drogen" })
    rules.Push({ type: "exact", find: "Entzug-Angebot von Sanitäter akzeptiert", replace: "Rehab" })
    rules.Push({ type: "exact", find: "Erkältungstabletten-Packung(en) erworben", replace: "Apotheke" })
    rules.Push({ type: "exact", find: "Erzmine Arbeiter verprügelt", replace: "Fund" })
    rules.Push({ type: "exact", find: "Eventspende", replace: "Event" })
    rules.Push({ type: "exact", find: "Fahrzeug abgemeldet", replace: "PF" })
    rules.Push({ type: "exact", find: "Feste Radarfalle", replace: "Blitzer" })
    rules.Push({ type: "exact", find: "Fitness-Studio", replace: "Fitness" })
    rules.Push({ type: "exact", find: "Gang/Mafia", replace: "Gangwar" })
    rules.Push({ type: "exact", find: "Geld vernichtet", replace: "/vernichten" })
    rules.Push({ type: "exact", find: "Geld via /pay transferiert", replace: "/pay" })
    rules.Push({ type: "exact", find: "Geld via Überweisung an Spieler transferiert", replace: "Überweisung" })
    rules.Push({ type: "exact", find: "Geldautomat", replace: "ATM" })
    rules.Push({ type: "exact", find: "Gruppe umbenannt", replace: "Gruppe" })
    rules.Push({ type: "exact", find: "Gunshop", replace: "Gunshop" })
    rules.Push({ type: "exact", find: "Haus gekauft", replace: "Haus" })
    rules.Push({ type: "exact", find: "Heal-Automat", replace: "Heal" })
    rules.Push({ type: "exact", find: "Heroin als Schmuggler hergesellt", replace: "Schmuggler" })
    rules.Push({ type: "exact", find: "Joint als Schmuggler hergesellt", replace: "Schmuggler" })
    rules.Push({ type: "exact", find: "Kill für Hitman in Auftrag gegeben", replace: "Kopfgeld" })
    rules.Push({ type: "exact", find: "Korrektur aufgrund von accountabhängiger Geldgrenze", replace: "Korrektur" })
    rules.Push({ type: "exact", find: "LS-Mall-Rentcar", replace: "Rentcar" })
    rules.Push({ type: "exact", find: "Methamphetamin als Schmuggler hergesellt", replace: "Schmuggler" })
    rules.Push({ type: "exact", find: "Methamphetamin von Schmuggler gekauft", replace: "Schmuggler" })
    rules.Push({ type: "exact", find: "Mülldienst: Geldbeutel im Müll gefunden", replace: "Fund" })
    rules.Push({ type: "exact", find: "News Reporter Spieler fotografiert", replace: "NR: Foto" })
    rules.Push({ type: "exact", find: "Ostereiersuche 2026", replace: "Event" })
    rules.Push({ type: "exact", find: "Paintball", replace: "Paintball" })
    rules.Push({ type: "exact", find: "PayDay", replace: "PayDay" })
    rules.Push({ type: "exact", find: "Permanente Gruppe gegründet", replace: "Gruppe" })
    rules.Push({ type: "exact", find: "Restaurant:", replace: "Heal" })
    rules.Push({ type: "exact", find: "Sanitäter: Spieler wiederbelebt", replace: "/revive" })
    rules.Push({ type: "exact", find: "Schießstand betreten", replace: "Gunrange" })
    rules.Push({ type: "exact", find: "Spieler als Sanitäter geheilt.", replace: "/mh" })
    rules.Push({ type: "exact", find: "Tankstelle:", replace: "Tanken" })
    rules.Push({ type: "exact", find: "Taxi-Bonus", replace: "Taxi" })
    rules.Push({ type: "exact", find: "Taxi-Kosten bezahlt", replace: "Taxi" })
    rules.Push({ type: "exact", find: "Ticket bezahlt", replace: "Ticket" })
    rules.Push({ type: "exact", find: "Vehikel gekauft", replace: "Überweisung" })
    rules.Push({ type: "exact", find: "Vehikel von Mitspieler gekauft", replace: "PF" })
    rules.Push({ type: "exact", find: "Von Admin editiert", replace: "Admin" })
    rules.Push({ type: "exact", find: "Von Sanitäter heilen lassen.", replace: "/mh" })
    rules.Push({ type: "exact", find: "Weihnachten-Special:", replace: "Event" })
    rules.Push({ type: "exact", find: "Weihnachtstruck geliehen", replace: "Event" })
    rules.Push({ type: "exact", find: "Werbeanzeige geschaltet", replace: "Werbung" })
    rules.Push({ type: "exact", find: "Werkstatt:", replace: "Werkstatt" })
    rules.Push({ type: "exact", find: "West-LS-Rentcar:", replace: "Rentcar" })

    ; -------------------------
    ; REGEX MATCHES
    ; -------------------------
    rules.Push({ type: "regex", find: "Level\s+\d+\s+gekauft", replace: "LVL-UP" })
    rules.Push({ type: "regex", find: "Geld auf Fraktionskasse eingezahlt.*", replace: "F-Kasse" })
    rules.Push({ type: "regex", find: "Online-Überweisung.*", replace: "Überweisung" })

    ; -------------------------
    ; ENGINE
    ; -------------------------
    for i, rule in rules {
        if (rule.type = "exact") {
            StringReplace, str, str, % rule.find, % rule.replace, All
        } else if (rule.type = "regex") {
            str := RegExReplace(str, rule.find, rule.replace)
        }
    }

    return str
}
    */

    ReplaceMapped(str) {
    static rules := []

    if (rules.Length() = 0) {

        ; -------------------------
        ; EXAKTE MATCHES
        ; -------------------------
        rules.Push({type:"contains", find:"24/7-Shop:", replace:"24/7"})
        rules.Push({type:"contains", find:"Angeln: Geldbeutel im Meer gefunden", replace:"Fund"})
        rules.Push({type:"contains", find:"Appartement erworben", replace:"Appartment"})
        rules.Push({type:"contains", find:"Bar: Soda gekauft", replace:"Bar"})
        rules.Push({type:"contains", find:"Bar: Whiskey gekauft", replace:"Bar"})
        rules.Push({type:"contains", find:"Bus-Ticket bezahlt", replace:"Bus"})
        rules.Push({type:"contains", find:"Car-Terminal", replace:"CT"})
        rules.Push({type:"contains", find:"Casino:", replace:"Casino"})
        rules.Push({type:"contains", find:"Drogen verkauft", replace:"Drogen"})
        rules.Push({type:"contains", find:"Entzug-Angebot von Sanitäter akzeptiert", replace:"Rehab"})
        rules.Push({type:"contains", find:"Erkältungstabletten-Packung(en) erworben", replace:"Apotheke"})
        rules.Push({type:"contains", find:"Erzmine: Arbeiter verprügelt", replace:"Fund"})
        rules.Push({type:"contains", find:"Eventspende", replace:"Event"})
        rules.Push({type:"contains", find:"Fahrzeug abgemeldet", replace:"PF"})
        rules.Push({type:"contains", find:"Feste Radarfalle", replace:"Blitzer"})
        rules.Push({type:"contains", find:"Fitness-Studio", replace:"Fitness"})
        rules.Push({type:"contains", find:"Gang/Mafia", replace:"Gangwar"})
        rules.Push({type:"contains", find:"Geld vernichtet", replace:"/vernichten"})
        rules.Push({type:"contains", find:"Geld via /pay transferiert", replace:"/pay"})
        rules.Push({type:"contains", find:"Geld via Überweisung an Spieler transferiert", replace:"Überweisung"})
        rules.Push({type:"contains", find:"Geldautomat", replace:"ATM"})
        rules.Push({type:"contains", find:"Gruppe umbenannt", replace:"Gruppe"})
        rules.Push({type:"contains", find:"Gunshop", replace:"Gunshop"})
        rules.Push({type:"contains", find:"Haus gekauft", replace:"Haus"})
        rules.Push({type:"contains", find:"Heal-Automat", replace:"Heal"})
        rules.Push({type:"contains", find:"Heroin als Schmuggler", replace:"Schmuggler"})
        rules.Push({type:"contains", find:"Joint als Schmuggler", replace:"Schmuggler"})
        rules.Push({type:"contains", find:"Kill für Hitman", replace:"Kopfgeld"})
        rules.Push({type:"contains", find:"Korrektur aufgrund", replace:"Korrektur"})
        rules.Push({type:"contains", find:"Rentcar", replace:"Rentcar"})
        rules.Push({type:"contains", find:"Mülldienst", replace:"Fund"})
        rules.Push({type:"contains", find:"News Reporter", replace:"NR: Foto"})
        rules.Push({type:"contains", find:"Ostereiersuche", replace:"Event"})
        rules.Push({type:"contains", find:"Paintball", replace:"Paintball"})
        rules.Push({type:"contains", find:"PayDay", replace:"PayDay"})
        rules.Push({type:"contains", find:"Permanente Gruppe gegründet", replace:"Gruppe"})
        rules.Push({type:"contains", find:"Restaurant", replace:"Heal"})
        rules.Push({type:"contains", find:"Sanitäter: Kunde hat Entzug-Angebot akzeptiert", replace:"Rehab"})
        rules.Push({type:"contains", find:"Sanitäter: Spieler wiederbelebt", replace:"/revive"})
        rules.Push({type:"contains", find:"Schießstand betreten", replace:"Gunrange"})
        rules.Push({type:"contains", find:"Spieler als Sanitäter geheilt", replace:"/mh"})
        rules.Push({type:"contains", find:"Tankstelle", replace:"Tanken"})
        rules.Push({type:"contains", find:"Taxi-Bonus", replace:"Taxi"})
        rules.Push({type:"contains", find:"Taxi-Kosten bezahlt", replace:"Taxi"})
        rules.Push({type:"contains", find:"Ticket bezahlt", replace:"Ticket"})
        rules.Push({type:"contains", find:"Vehikel gekauft", replace:"Überweisung"})
        rules.Push({type:"contains", find:"Vehikel von Mitspieler gekauft", replace:"PF"})
        rules.Push({type:"contains", find:"Von Admin editiert", replace:"Admin"})
        rules.Push({type:"contains", find:"Von Sanitäter heilen lassen", replace:"/mh"})
        rules.Push({type:"contains", find:"Weihnachten-Special", replace:"Event"})
        rules.Push({type:"contains", find:"Weihnachtstruck", replace:"Event"})
        rules.Push({type:"contains", find:"Werbeanzeige geschaltet", replace:"Werbung"})
        rules.Push({type:"contains", find:"Werkstatt", replace:"Werkstatt"})

        ; -------------------------
        ; REGEX MATCHES (ganzer String)
        ; -------------------------
        rules.Push({type:"regex", find:"^Level\s+\d+\s+gekauft$", replace:"LVL-UP"})
        rules.Push({type:"regex", find:"^Geld auf Fraktionskasse eingezahlt.*$", replace:"F-Kasse"})
        rules.Push({type:"regex", find:"^Online-Überweisung.*$", replace:"Überweisung"})
    }

    ; -------------------------
    ; ENGINE
    ; -------------------------

    ; 1) RegEx-Regeln zuerst (ganzer String)
    for i, rule in rules {
        if (rule.type = "regex" && RegExMatch(str, rule.find))
            return rule.replace
    }

    ; 2) Contains-Regeln (wenn Teilstring vorkommt ? GANZER String ersetzen)
    for i, rule in rules {
        if (rule.type = "contains" && InStr(str, rule.find))
            return rule.replace
    }

    return str
}

