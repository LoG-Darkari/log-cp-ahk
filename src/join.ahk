printJoinDisconnect() {
    static players := {}
    static initialized := false
    static cooldown := 0


    if (cooldown > 0) {
        cooldown--
        return
    }

    if (!initialized) {
        initialized := true
        cooldown := 20   ; ~1 Sekunde warten
        Loop, % SAMP_PLAYER_MAX {
            id := A_Index - 1
            name := getPlayerNameById(id)
            if (name && !IsNPCById(id))
                players[id] := name
            else
                players[id] := ""
        }
        return
    }


    Loop, % SAMP_PLAYER_MAX {
        id := A_Index - 1

        if (IsNPCById(id))
            continue

        name := getPlayerNameById(id)
        old  := players[id]


        if (name = "")
            continue

        if (old = "") {
            players[id] := name
            AddChatMessage("{d9fd29}**** " name " [ID: " id "] (Login)")
            continue
        }

    }


    Loop, % SAMP_PLAYER_MAX {
        id := A_Index - 1
        if (players[id] != "" && getPlayerNameById(id) = "") {
            AddChatMessage("{d9fd29}**** " players[id] " (Logout)")
            players[id] := ""
        }
    }
}

global joinmsg := 0

:?:/tog join::
Suspend, Permit

if (joinmsg) {
    AddChatMessage("{45B6FE}Info: {FFFFFF}Benachrichtigungen (Betreten/Verlassen) ausgeschaltet.")
    SetTimer, Join, OFF
    joinmsg := 0
} else {
    AddChatMessage("{45B6FE}Info: {FFFFFF}Benachrichtigungen (Betreten/Verlassen) eingeschaltet.")
    SetTimer, Join, 100
    joinmsg := 1
}
return

Join:
if (WinActive("GTA:SA:MP"))
{
printJoinDisconnect()
return
}