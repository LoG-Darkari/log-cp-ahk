cp_getTickets()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/ticket/tickets","")
    cp_Logout()
    FileDelete, ticket.log
    FileAppend, %response%, ticket.log
    return response
}

CleanCell(x)
{
    ; 1) datetime aus <time> extrahieren
    if RegExMatch(x, "datetime=""(.*?)""", m)
    {
        dt := m1   ; z.B. 2026-04-20 01:38:58

        ; In TT.MM.JJJJ HH:MM umwandeln
        StringSplit, part, dt, %A_Space%
        date := part1
        time := part2

        StringSplit, d, date, -
        StringSplit, t, time, :

        return d3 "." d2 "." d1 " " t1 ":" t2
    }

    ; 2) normalen Text extrahieren
    x := RegExReplace(x, "<[^>]+>")
    x := RegExReplace(x, "\s+", " ")
    return Trim(x)
}

ParseTickets(html)
{
    list := []

    pos := 1
    while pos := RegExMatch(html, "s)<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        cols := []
        cpos := 1
        while cpos := RegExMatch(tr, "s)<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)
            cols.Push(c1)
        }

        if (cols.MaxIndex() < 8)
            continue

        status        := CleanCell(cols[2])
        betreff       := CleanCell(cols[4])
        teammitglied  := CleanCell(cols[6])
        letzteAntwort := CleanCell(cols[8])

        obj := {}
        obj.Status := status
        obj.Betreff := betreff
        obj.Teammitglied := teammitglied
        obj.LetzteAntwort := letzteAntwort

        list.Push(obj)
    }

    return list
}

StatusRank(status)
{
    if (status = "Offen")
        return 1
    if (status = "In Bearbeitung")
        return 2
    return 3 ; Geschlossen
}

SortTicketsByStatus(arr)
{
    Sort, arr, F CompareStatus
    return arr
}

CompareStatus(a, b)
{
    return StatusRank(a.Status) - StatusRank(b.Status)
}

StatusColor(status)
{
    if (status = "Offen")
        return "{4AE34A}"   ; grün
    if (status = "In Bearbeitung")
        return "{FFD700}"   ; gelb
    return "{ADADAD}"       ; grau
}

BuildTicketDialog(html)
{
    rows := ParseTickets(html)

    offen := []
    inBearb := []
    geschlossen := []

    for _, obj in rows
    {
        if (obj.Status = "Offen")
            offen.Push(obj)
        else if (obj.Status = "In Bearbeitung")
            inBearb.Push(obj)
        else
            geschlossen.Push(obj)
    }

    dialog := "Status`tBetreff`tTeammitglied`tLetzte Antwort`n"

    ; Reihenfolge: Offen → In Bearbeitung → Geschlossen
    for _, obj in offen
        dialog .= StatusColor(obj.Status) obj.Status "{FFFFFF}`t"
                . obj.Betreff "`t"
                . obj.Teammitglied "`t"
                . obj.LetzteAntwort "`n"

    for _, obj in inBearb
        dialog .= StatusColor(obj.Status) obj.Status "{FFFFFF}`t"
                . obj.Betreff "`t"
                . obj.Teammitglied "`t"
                . obj.LetzteAntwort "`n"

    for _, obj in geschlossen
        dialog .= StatusColor(obj.Status) obj.Status "{FFFFFF}`t"
                . obj.Betreff "`t"
                . obj.Teammitglied "`t"
                . obj.LetzteAntwort "`n"

    return dialog
}


_BuildTicketDialog(html)
{
    rows := ParseTickets(html)
    rows := SortTicketsByStatus(rows)

    dialog := "Status`tBetreff`tTeammitglied`tLetzte Antwort`n"

    for index, obj in rows
    {
        color := StatusColor(obj.Status)

        dialog .= color obj.Status "{FFFFFF}`t"
                . obj.Betreff "`t"
                . obj.Teammitglied "`t"
                . obj.LetzteAntwort "`n"
    }

    return dialog
}
