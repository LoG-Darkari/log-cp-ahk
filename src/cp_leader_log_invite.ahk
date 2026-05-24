global InviteLog := []
global InvitePages := []
global Invite_Page := 1

ParseInviteLog(html)
{
    global InviteLog
    InviteLog := []

    dialog := "Datum`tMember`tLeader`tTyp`n"
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
        leader := cols[3]
        typRaw := cols[5]

        RegExMatch(rawDate, "(\d{2}\.\d{2})\.\d{4}\s+(\d{2}:\d{2})", d)
        shortDate := d1 "." SubStr(rawDate, 9, 2) " " d2

        if RegExMatch(memberRaw, ".*\((.*?)\)", m2)
            member := m2
        else
            member := RegExReplace(memberRaw, "\s*\(.*?\)", "")

        if InStr(typRaw, "uninvitet")
            typ := "Out"
        else if InStr(typRaw, "invitet")
            typ := "In"
        else
            typ := typRaw

        obj := { Datum:shortDate, Member:member, Leader:leader, Typ:typ }
        InviteLog.Push(obj)

        dialog .= shortDate "`t" member "`t" leader "`t" typ "`n"
    }

    return dialog
}

BuildInvitePages(full)
{
    global InvitePages
    InvitePages := []

    max := 4096
    pos := 1

    while (pos <= StrLen(full))
    {
        chunk := SubStr(full, pos, max)
        last := InStr(chunk, "`n", false, 0)
        chunk := SubStr(chunk, 1, last)
        InvitePages.Push(chunk)
        pos += StrLen(chunk)
    }
}
