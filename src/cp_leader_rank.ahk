global RankLog := []
global RankLogPages := []
global RankLog_Page := 1

ParseRankLog(html)
{
    global RankLog
    RankLog := []

    dialog := "Datum`tRang`tMember`tGrund`n"
    count := 0

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos + StrLen(m))
    {
        tr := m1
        cols := []
        cpos := 1

        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos + StrLen(c))
            cols.Push(Trim(RegExReplace(c1, "<[^>]+>")))

        if (cols.MaxIndex() < 8)
            continue

        if (++count > 50)
            break

        rawDate := cols[1]
        oldRank := cols[4]
        newRank := cols[5]
        memberRaw := cols[6]
        grund := cols[8]

        RegExMatch(rawDate, "(\d{2}\.\d{2})\.\d{4}\s+(\d{2}:\d{2})", d)
        shortDate := d1 "." SubStr(rawDate, 9, 2) " " d2

        oldNum := RegExReplace(oldRank, ".*\((\d+)\).*", "$1")
        newNum := RegExReplace(newRank, ".*\((\d+)\).*", "$1")
        rang := oldNum ">" newNum

        if RegExMatch(memberRaw, ".*\((.*?)\)", m2)
            member := m2
        else
            member := RegExReplace(memberRaw, "\s*\(.*?\)", "")

        obj := { Datum:shortDate, Rang:rang, Member:member, Grund:grund }
        RankLog.Push(obj)

        dialog .= shortDate "`t" rang "`t" member "`t" grund "`n"
    }

    return dialog
}

BuildRankLogPages(full)
{
    global RankLogPages
    RankLogPages := []

    max := 4096
    pos := 1

    while (pos <= StrLen(full))
    {
        chunk := SubStr(full, pos, max)
        last := InStr(chunk, "`n", false, 0)
        chunk := SubStr(chunk, 1, last)
        RankLogPages.Push(chunk)
        pos += StrLen(chunk)
    }
}

ShowRankLogPage()
{
    global RankLogPages, RankLog_Page
    max := RankLogPages.MaxIndex()

    if (RankLog_Page < 1)
        RankLog_Page := 1
    if (RankLog_Page > max)
        RankLog_Page := max

    txt := RankLogPages[RankLog_Page]

    if (max = 1)
        ShowDialog(5, "Rang-Log", txt, "Schlieﬂen", "")
    else if (RankLog_Page = 1)
        ShowDialog(5, "Rang-Log", txt, "Weiter >", "Schlieﬂen")
    else if (RankLog_Page = max)
        ShowDialog(5, "Rang-Log", txt, "< Zur¸ck", "Schlieﬂen")
    else
        ShowDialog(5, "Rang-Log", txt, "< Zur¸ck", "Weiter >")
}
