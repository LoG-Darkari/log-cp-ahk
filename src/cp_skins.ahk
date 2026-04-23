global CivSkins := {}
global FacSkins := {}

cp_loadSkinLists() {
    global CivSkins, FacSkins

    CivSkins := {}
    FacSkins := {}

    if (!cp_login())
        return

    html := cp_action("GET", "https://samp.cp.life-of-german.org/ingameshop/skin")
    cp_logout()

    pos := 1
    while (pos := RegExMatch(html, "civilianSkinID/([0-9]+)", m, pos)) {
        CivSkins[m1] := true
        pos += StrLen(m)
    }

    pos := 1
    while (pos := RegExMatch(html, "factionSkinID/([0-9]+)", m, pos)) {
        FacSkins[m1] := true
        pos += StrLen(m)
    }
}

cp_changeSkin(id) {
    global CivSkins, FacSkins

    if (!CivSkins[id] && !FacSkins[id])
        return false

    if (!cp_login())
        return false

    cp_action("POST", "https://samp.cp.life-of-german.org/ingameshop/skin", "skin=" id "&submit=Kaufen")
    cp_logout()

    return true
}
