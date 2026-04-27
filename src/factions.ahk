BuildLeaderObjects()
{
    factions := []

    AddFaction(factions, "Los Santos Police Department", "xKORE", "6495ED")
    AddFaction(factions, "Federal Bureau of Investigation", "JohnHunt", "1111FF") ;1111FF 1650BB
    AddFaction(factions, "United States Army", "AirMake", "33CC00")
    AddFaction(factions, "United States Army", "aviate", "33CC00")
    AddFaction(factions, "Los Santos Medical Department", ".NoNaMe", "FF3333")
    AddFaction(factions, "San Andreas Logistik und Abschleppdienst", "Tobi_Gafas", "FFFF00")
    AddFaction(factions, "Grove Street Families", "ChinG", "006600")
    AddFaction(factions, "Front Yard Ballas", "Division39MID", "660066")
    AddFaction(factions, "Triaden Mafia", "Martin_", "FFFF80")
    AddFaction(factions, "Yakuza Mafia", "hope", "DB7B9D")
    AddFaction(factions, "Terroristen", "Verde", "795F37")
    AddFaction(factions, "Hitman Agency", "OpTiMaLZz", "993300")

    return factions
}

AddFaction(arr, fraktion, leader, farbe)
{
    obj := {}
    obj.Fraktion := fraktion
    obj.Leader := leader
    obj.Farbe := farbe
    arr.Push(obj)
}

BuildLeaderDialog()
{
    rows := BuildLeaderObjects()

    dialog := "Fraktion`tLeader`t`n"

    for index, obj in rows
    {
        ; Leader online?
        if (GetPlayerIdByName(obj.Leader) != -1)
            color := "{4AE34A}"   ; grün
        else
            color := "{ADADAD}"   ; grau

 dialog .= "{" obj.Farbe "}" obj.Fraktion "`t"
                . color obj.Leader "{FFFFFF}`t`n"
    }

    return dialog
}

BuildLeaderOL()
{
{
    rows := BuildLeaderObjects()

    dialog := "Fraktion`tLeader`t`n"

    for index, obj in rows
    {
        ; Leader online?
        if (GetPlayerIdByName(obj.Leader) != -1)
        {
            color := "{4AE34A}"   ; grün
            dialog .= "{" obj.Farbe "}" obj.Fraktion "`t"
                . color obj.Leader "{FFFFFF}`t`n"
    }
    }
    return dialog
}

}

