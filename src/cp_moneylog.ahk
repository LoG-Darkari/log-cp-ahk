cp_money_log(logtype := "-1", moneytype := "-1", timefrom := "", timeto :="")
{ 
cp_Login()
RequestType 	:= "POST"
URL 			:= "https://samp.cp.life-of-german.org/home/moneylog"
Payload         := "logTypeID=" logtype "&moneyTypeID=" moneytype "&timeFrom=" timefrom "&timeTo=" timeto "&anzeigen=anzeigen"
response := http_Request(RequestType,URL,Payload)
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
        grund := grund

        obj := {}
        obj.Datum := FormatDate(FormatDate(datum))
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
        obj.Grund := grund

        list.Push(obj)
    }

    return list
}


BuildMoneyLogDialog_Pages(html) {
    rows := ParseMoneyLog(html, 8000)

    header := "Datum`tDifferenz`tBeteiligter`tGrund`n"
    maxLen := 3800
    pages := []
    current := header

    for index, obj in rows
    {
        ; Farbe bestimmen
        if InStr(obj.Differenz, "-") {
            diff := StrReplace(obj.Differenz, "- $")
            color := "{C41E3A}"
        } else if InStr(obj.Differenz, "+ ") {
            diff := StrReplace(obj.Differenz, "+ $")
            color := "{32CD32}"
        } else {
            diff := obj.Differenz
            color := "{FFFFFF}"
        }

        line := Trim(obj.Datum) "`t"
             . color Trim(diff) "`t{FFFFFF}"
             . Trim(obj.Beteiligter) "`t"
             . Trim(obj.Grund) "`n"

        if (StrLen(current . line) > maxLen) {
            pages.Push(current)
            current := header . line
        } else {
            current .= line
        }
    }

    pages.Push(current)

    ; Footer hinzufügen
    finalPages := []
    Loop % pages.MaxIndex() {
        i := A_Index
        hasPrev := (i > 1)
        hasNext := (i < pages.MaxIndex())
        finalPages.Push(AddFooter(pages[i], hasPrev, hasNext))
    }

    return finalPages
}


AddFooter(pageText, hasPrev, hasNext) {
    f1 := ""              ; Leerzeile
    f2 := hasNext ? "Weiter" : ""
    f3 := hasPrev ? "Zurück" : ""
    return pageText "`n" f1 "`n" f2 "`n" f3
}





BuildPaydayLogDialog(html)
{
    rows := ParseCashflow(html,100)

    dialog := "Datum`tCashflow`t`n"

    for index, obj in rows
    {
         {
                obj.Differenz := StrReplace(obj.Differenz, "- ")
                color := "{C41E3A}"
        }
                If (InStr(obj.Differenz, ""))
        {
                obj.Differenz := StrReplace(obj.Differenz, "+ ")
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
        rules.Push({type:"contains", find:"Schmuggler", replace:"Schmuggler"})
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

/*
BuildMoneyLogDialog_Paged(html) {
    full := BuildMoneyLogDialog(html)
    pages := []
    max := 4000

    pos := 1
    while (pos <= StrLen(full)) {
        pages.Push(SubStr(full, pos, max))
        pos += max
    }
    return pages
}


global CP_PAGES := []
global CP_PAGE_INDEX := 1

ShowPagedDialog(title, pages) {
    global CP_PAGES, CP_PAGE_INDEX
    CP_PAGES := pages
    CP_PAGE_INDEX := 1
    ShowCurrentPage(title)
}
*/

global MLOG_PAGES := []
global MLOG_INDEX := 1

ShowMoneyLogPaged(title, pages) {
    global MLOG_PAGES, MLOG_INDEX
    MLOG_PAGES := pages
    MLOG_INDEX := 1
    ShowMoneyLogPage(title)
}

ShowMoneyLogPage(title) {
    global MLOG_PAGES, MLOG_INDEX

    txt := MLOG_PAGES[MLOG_INDEX]

    ShowDialog(5, title " (" MLOG_INDEX "/" MLOG_PAGES.MaxIndex() ")", txt, "Auswählen", "Schließen")

    Loop {
        if IsDialogButton1Clicked() {
            ;Sleep, 120
        
                sel := Trim(GetDialogLine(GetDialogIndex()))

                if (sel = "Vor" && MLOG_INDEX < MLOG_PAGES.MaxIndex()) {
                    MLOG_INDEX++
                    ShowMoneyLogPage(title)
                }
                else if (sel = "Zurück" && MLOG_INDEX > 1) {
                    MLOG_INDEX--
                    ShowMoneyLogPage(title)
                }

                return
            }
        



        if !IsDialogOpen() || GetKeyState("Esc")
            return
        }
    }




ShowCurrentPage(title) {
    global CP_PAGES, CP_PAGE_INDEX

    txt := CP_PAGES[CP_PAGE_INDEX]

    btn1 := (CP_PAGE_INDEX > 1) ? "Zurück" : ""
    btn2 := (CP_PAGE_INDEX < CP_PAGES.MaxIndex()) ? "Weiter" : "Schließen"

    ShowDialog(5, title " (" CP_PAGE_INDEX "/" CP_PAGES.MaxIndex() ")", txt, btn2, btn1)

    Loop {
        if IsDialogButton1Clicked()() { ; Weiter / Schließen
            Sleep, 120
            if !IsDialogOpen() {
                if (CP_PAGE_INDEX < CP_PAGES.MaxIndex()) {
                    CP_PAGE_INDEX++
                    ShowCurrentPage(title)
                }
                return
            }
        }
/*


        if IsDialogButton2Selected() { ; Zurück
            Sleep, 120
            if !IsDialogOpen() {
                if (CP_PAGE_INDEX > 1) {
                    CP_PAGE_INDEX--
                    ShowCurrentPage(title)
                }
                return
            }
        }
*/
        if !IsDialogOpen() || GetKeyState("Esc") {
            return
        }
    }
}


BuildTestPages() {
    header := "Datum`tDifferenz`tBeteiligter`tGrund`n"

    page1 := header
    page1 .= " `t `t `tVor`n"
    page1 .= "`n"   
    page1 .= "1.1`t+100`tTestA`tGrund A`n"
    page1 .= "1.2`t-50`tTestB`tGrund B`n"

    page2 := header
    page2 .= " `t `t `tVor`n"
    page2 .= "Zurück`n" 
    page2 .= " `n"
    page2 .= "2.1`t+200`tTestC`tGrund C`n"
    page2 .= "2.2`t-10`tTestD`tGrund D`n"

    page3 := header
    page3 .= "Zurück`n"
    page3 .= "n"
    page3 .= "3.1`t+999`tTestE`tGrund E`n"
    page3 .= "3.2`t-123`tTestF`tGrund F`n"

    pages := []
    pages.Push(AddFooter(page1, false, true))  ; Seite 1: kein Zurück, aber Vor
    pages.Push(AddFooter(page2, true, true))   ; Seite 2: Vor + Zurück
    pages.Push(AddFooter(page3, true, false))  ; Seite 3: Zurück, kein Vor

    return pages
}

global TEST_PAGES := []
global TEST_INDEX := 1

ShowTestPaged(title, pages) {
    global TEST_PAGES, TEST_INDEX
    TEST_PAGES := pages
    TEST_INDEX := 1
    ShowTestPage(title)
}

ShowTestPage(title) {
    global TEST_PAGES, TEST_INDEX

    txt := TEST_PAGES[TEST_INDEX]

    ; Button 1 = Auswählen (Vor/Zurück)
    ; Button 2 = Schließen
    ShowDialog(5, title " (" TEST_INDEX "/" TEST_PAGES.MaxIndex() ")", txt, "Auswählen", "Schließen")

Loop {
    
                sel := Trim(GetDialogLine(GetDialogIndex()))
        if IsDialogButton1Clicked() {
            ;Sleep, 120
        
                AddChatMessage(sel)
                AddChatMessage(GetDialogText())
                if (InStr(sel, "vor") && MLOG_INDEX < MLOG_PAGES.MaxIndex()) {
                    MLOG_INDEX++
                    ShowMoneyLogPage(title)
                }
                else if (sel = "Zurück" && MLOG_INDEX > 1) {
                    MLOG_INDEX--
                    ShowMoneyLogPage(title)
                }

                return
            }
        



        if !IsDialogOpen() || GetKeyState("Esc")
            return
        }
}
