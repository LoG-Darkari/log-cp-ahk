cp_setAbsent(days, desc := "") {
    if (!cp_login())
        return false

    cp_action("POST", "https://samp.cp.life-of-german.org/settings/absent"
        , "days=" days "&description=" desc "&submit=Speichern")

    cp_logout()
    return true
}
