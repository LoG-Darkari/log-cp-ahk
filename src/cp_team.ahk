parseTeam(html) {
    team := {}
    pos := 1
    while (pos := RegExMatch(html, "([A-Za-zÄÖÜäöüß .]+)[ ]+([A-Za-z0-9_.-]+)", m, pos)) {
        role := Trim(m1)
        name := Trim(m2)
        if (!team.HasKey(name))
            team[name] := []
        team[name].Push(role)
        pos += StrLen(m)
    }
    return team
}

cp_getTeam() {
    if (!cp_login())
        return {}

    html := cp_action("GET", "https://life-of-german.org/team")
    cp_logout()
    return parseTeam(html)
}
