global ItemLog := []
global ItemPages := []
global Item_Page := 1

ParseItemLog(html)
{
    global ItemLog
    ItemLog := []

    dialog := "Datum`tBeteiligter`tItem`tÄnderung`n"
    count := 0

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos + StrLen(m))
    {
        tr := m1
        cols := []
        cpos := 1

        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos + StrLen(c))
            cols.Push(Trim(RegExReplace(c1, "<[^>]+>")))

        if (cols.MaxIndex() < 4)
            continue

        if (++count > 50)
            break

        rawDate := cols[1]
        beteiligter := cols[2]
        item := cols[3]
        change := cols[4]

        RegExMatch(rawDate, "(\d{2}\.\d{2})\.\d{4}\s+(\d{2}:\d{2})", d)
        shortDate := d1 "." SubStr(rawDate, 9, 2) " " d2

        old := RegExReplace(change, ".*?(\d+).*", "$1")
        new := RegExReplace(change, ".*(\d+).*?$", "$1")
        changeFmt := old ">" new

        obj := { Datum:shortDate, Beteiligter:beteiligter, Item:item, Change:changeFmt }
        ItemLog.Push(obj)

        dialog .= shortDate "`t" beteiligter "`t" item "`t" changeFmt "`n"
    }

    return dialog
}

BuildItemPages(full)
{
    global ItemPages
    ItemPages := []

    max := 4096
    pos := 1

    while (pos <= StrLen(full))
    {
        chunk := SubStr(full, pos, max)
        last := InStr(chunk, "`n", false, 0)
        chunk := SubStr(chunk, 1, last)
        ItemPages.Push(chunk)
        pos += StrLen(chunk)
    }
}
