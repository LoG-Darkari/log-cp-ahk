cp_loadActivityPoints() {
    if (!cp_login())
        return ""

    html := cp_action("GET", "https://samp.cp.life-of-german.org/faction/activitypoints")
    cp_logout()
    return html
}

parseActivityPoints(html) {
    data := {}
    pos := 1
    while (pos := RegExMatch(html, "<td>(.*?)</td>.*?<td>([0-9]+)</td>", m, pos)) {
        data[Trim(m1)] := m2
        pos += StrLen(m)
    }
    return data
}
