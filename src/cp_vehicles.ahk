parseFactionVehicles(html) {
    vehicles := []
    pos := 1
    while (pos := RegExMatch(html
        , "([0-9]+)[ ]+([0-9]+)[ ]+(.+?) [ ]+([0-9]+)[ ]+(-?[0-9.]+)[ ]+(-?[0-9.]+)[ ]+(-?[0-9.]+)"
        , m, pos)) {
        vehicles.Push({ "id": m2
                      , "name": Trim(m3)
                      , "rank": m4
                      , "x": m5
                      , "y": m6
                      , "z": m7 })
        pos += StrLen(m)
    }
    return vehicles
}

cp_getFactionVehicles() {
    if (!cp_login())
        return []

    html := cp_action("GET", "https://samp.cp.life-of-german.org/faction/vehicles")
    cp_logout()
    return parseFactionVehicles(html)
}
