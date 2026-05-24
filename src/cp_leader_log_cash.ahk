global DiffLog := []
global DiffPages := []
global Diff_Page := 1

ParseDiffLog(html)
{
    global DiffLog
    DiffLog := []

    dialog := "Datum`tTyp`tBeteiligter`tDifferenz`n"
    count := 0

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos + StrLen(m))
    {
        tr := m1
        cols := []
        cpos := 1

        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos + StrLen(c))
            cols.Push(Trim(RegExReplace(c1, "<[^>]+>")))

        if (cols.MaxIndex() < 5)
            continue

        if (++count > 50)
            break

        rawDate := cols[1]
        memberRaw := cols[2]
        typ := cols[5]

        RegExMatch(rawDate, "(\d{2}\.\d{2})\.\d{4}\s+(\d{2}:\d{2})", d)
        shortDate := d1 "." SubStr(rawDate, 9, 2) " " d2

        if RegExMatch(memberRaw, ".*\((.*?)\)", m2)
            member := m2
        else
            member := RegExReplace(memberRaw, "\s*\(.*?\)", "")

        if RegExMatch(typ, "(\([^\)]*\)|[+-]?\d+)", d3)
            diff := d31
        else
            diff := typ

        obj := { Datum:shortDate, Typ:typ, Beteiligter:member, Differenz:diff }
        DiffLog.Push(obj)

        dialog .= shortDate "`t" typ "`t" member "`t" diff "`n"
    }

    return dialog
}

BuildDiffPages(full)
{
    global DiffPages
    DiffPages := []

    max := 4096
    pos := 1

    while (pos <= StrLen(full))
    {
        chunk := SubStr(full, pos, max)
        last := InStr(chunk, "`n", false, 0)
        chunk := SubStr(chunk, 1, last)
        DiffPages.Push(chunk)
        pos += StrLen(chunk)
    }
}
