JsonDump(obj) {
    json := "{"
    for k, v in obj {
        if (IsObject(v))
            json .= """" k """: " JsonDump(v) ","
        else
            json .= """" k """: """ v ""","
    }
    return RTrim(json, ",") "}"
}

JsonLoad(json) {
    return %json%
}