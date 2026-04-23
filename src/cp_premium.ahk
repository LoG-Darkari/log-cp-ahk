parsePremium(html) {
    result := {}
    RegExMatch(html, "Aktiv (.+?) ([0-9]{2}\.[0-9]{2}\.[0-9]{4} - [0-9]{2}:[0-9]{2}:[0-9]{2})", m)
    result.produkt := m1
    result.ablauf := m2
    return result
}

cp_getPremium() {
    if (!cp_login())
        return {}

    html := cp_action("GET", "https://samp.cp.life-of-german.org/home/premiumduration")
    cp_logout()
    return parsePremium(html)
}
