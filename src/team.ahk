BuildTeamObjects()
{
    team := []

    ; Jede Zeile als Objekt hinzufügen
    Add(team, "Orangebox",     "Projektleitung - Mapping",          "1338", "Mapverwaltung - Task-Force Vorschläge")
    Add(team, "dreamtex",      "Projektmanagement - Mapping",       "1338", "Mapverwaltung -Task-Force Vorschläge")
    Add(team, "Luke",          "Projektmanagement",                "1338", "Task-Force Vorschläge")
    Add(team, "Scaryman000",   "Projektmanagement",                "1338", "")
    Add(team, "Fefe",          "Entwicklung",                      "(1338)", "Serveradministration")
    Add(team, "hydranT",       "Entwicklung",                      "(1337)", "")
    Add(team, "Miniex",        "Entwicklung",                      "(1337)", "")
    Add(team, "Montero",       "Entwicklung",                      "(1337)", "")
    Add(team, "Zeuto",         "Entwicklung",                      "(1337)", "")
    Add(team, "Artemis",       "Administration",                   "3",    "Eventmanagement - Task-Force")
    Add(team, "Atze1207",      "Administration",                   "3",    "")
    Add(team, "Cronix",        "Administration",                   "1337", "Fraktionsverwaltung")
    Add(team, "Dim",           "Administration",                   "1337", "Haus- und Businessverwaltung")
    Add(team, "hope",          "Administration",                   "2",    "Task-Force Vorschläge")
    Add(team, "Kulmi",         "Administration",                   "1",    "")
    Add(team, "Markus",        "Administration",                   "1337", "Haus- und Businessverwaltung")
    Add(team, "Martin_",       "Administration",                   "2",    "Eventmanagement")
    Add(team, "Tobi_Gafas",    "Administration",                   "2",    "Fraktionsverwaltung -Task-Force")
    Add(team, "Airmake",       "Support",                          "",     "")
    Add(team, "Paaqo",         "Support",                          "",     "")
    Add(team, "Skrillex",      "Support",                          "",     "")
    Add(team, "Monsta.",   "Social Media",                     "",     "")
    Add(team, "Manipulate.",   "Social Media",                     "",     "")
    Add(team, "Pseudobaer",    "Social Media",                     "",     "")

    return team
}

Add(arr, name, pos, admin, sonder)
{
    obj := {}
    obj.Name := name
    obj.Position := pos
    obj.Adminlevel := admin
    obj.Sonderaufgaben := sonder
    arr.Push(obj)
}


BuildTeamDialog()
{
    rows := BuildTeamObjects()

    dialog := "Name`tPosition(en)`tAdminlevel`tSonderaufgabe(n)`n"

    for index, obj in rows
    {
        If (GetPlayerIdByName(obj.Name) != -1)
        {
            color := "{4AE34A}"
        }
        Else
        {
          color := "{ADADAD}"  
        }

        dialog .= color obj.Name "`t{FFFFFF}"
                . obj.Position "`t"
                . obj.Adminlevel "`t"
                . obj.Sonderaufgaben "`n"
    }

    return dialog
}

BuildTeamOL()
{
    rows := BuildTeamObjects()

    dialog := "Name`tPosition(en)`tAdminlevel`tSonderaufgabe(n)`n"

    for index, obj in rows
    {
        If (GetPlayerIdByName(obj.Name) != -1)
        {
            color := "{4AE34A}"
                    dialog .= color obj.Name "`t{FFFFFF}"
                . obj.Position "`t"
                . obj.Adminlevel "`t"
                . obj.Sonderaufgaben "`n"
    }
        }

    return dialog
}

