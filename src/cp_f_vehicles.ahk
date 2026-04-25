ParseFactionVehicles(html)
{
    vehicles := []

    pos := 1
    while pos := RegExMatch(html, "<tr[^>]*>(.*?)</tr>", m, pos)
    {
        pos += StrLen(m)
        tr := m1

        ; Alle <td>-Zellen extrahieren
        rawCols := []
        cpos := 1
        while cpos := RegExMatch(tr, "<td[^>]*>(.*?)</td>", c, cpos)
        {
            cpos += StrLen(c)
            rawCols.Push(c1)
        }

        ; Header überspringen
        if (rawCols.MaxIndex() < 8)
            continue

        ; Spalten zuweisen
        slot     := Trim(RegExReplace(rawCols[1], "<[^>]+>"))
        id       := Trim(RegExReplace(rawCols[2], "<[^>]+>"))
        vehicle  := Trim(RegExReplace(rawCols[4], "<[^>]+>"))
        rang     := Trim(RegExReplace(rawCols[5], "<[^>]+>"))
        x        := Trim(RegExReplace(rawCols[6], "<[^>]+>"))
        y        := Trim(RegExReplace(rawCols[7], "<[^>]+>"))
        z        := Trim(RegExReplace(rawCols[8], "<[^>]+>"))

        obj := {}
        obj.ID      := id
        obj.Vehicle := vehicle
        obj.Rang    := rang
        obj.X       := x
        obj.Y       := y
        obj.Z       := z

        vehicles.Push(obj)
    }

    return vehicles
}


BuildFactionVehicleDialog(html)
{
    rows := ParseFactionVehicles(html)

    dialog := "ID`tFahrzeug`tRang`n"
    for index, obj in rows
        dialog .= obj.ID "`t" obj.Vehicle "`t" obj.Rang "`n"

    return dialog
}


cp_getFVehicles()
{
    cp_Login()
    response := http_Request("GET","https://samp.cp.life-of-german.org/faction/vehicles","")
    ;AddChatMessage("Reponse Länge - " StrLen(response))
    cp_Logout()
    ;AddChatMessage("CP logout")
    return response
}