ParseFactionMembers(html)
{
    members := []

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        ; Roh-Extraktion aller <td>-Zellen
        rawCols := []
        cpos := 1
        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)
            rawCols.Push(c1)
        }

        ; Header überspringen
        if (rawCols.MaxIndex() < 4)
            continue

        ; Username (2. <td>)
        username := RegExReplace(rawCols[2], "<[^>]+>")
        username := RegExReplace(username, "\s+", " ")
        username := Trim(username)

        ; Rang (4. <td>)
        rang := RegExReplace(rawCols[4], "<[^>]+>")
        rang := RegExReplace(rang, "\s+", " ")
        rang := Trim(rang)

        ; Objekt erzeugen
        obj := {}
        obj.Name := username
        obj.Rang := rang

        members.Push(obj)
    }

    return members
}

BuildFactionMemberDialog(html)
{
    rows := ParseFactionMembers(html)

    dialog := "Name`tRang`n"
    for index, obj in rows
    {
        if(GetPlayerIdByName(obj.Name) != -1)
        {
           dialog .="{4AE34A}" obj.Name "`t{FFFFFF}" obj.Rang "`n" 
        }
        Else
        {
            dialog .="{ADADAD}" obj.Name "`t{FFFFFF}" obj.Rang "`n" 
        }
    }
    return dialog
}

cp_getFMembers()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/members","")
    ;AddChatMessage("Reponse Länge - " StrLen(response))
    cp_Logout()
    ;AddChatMessage("CP logout")
    return response
}