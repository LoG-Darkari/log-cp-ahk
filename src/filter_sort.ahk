; ============================================
; filter_sort.ahk – universelle Filter & Sortierung
; ============================================

; -------------------------
; FILTER
; -------------------------
FilterList(list, field, value)
{
    out := []

    Loop % list.MaxIndex()
    {
        obj := list[A_Index]

        if (InStr(obj[field], value, false))
            out.Push(obj)
    }

    return out
}

; -------------------------
; SORTIERUNG (ASC)
; -------------------------
SortListAsc(ByRef list, field)
{
    Sort, list, F __SortAsc
    return

    __SortAsc(a, b)
    {
        global field
        if (a[field] < b[field])
            return -1
        if (a[field] > b[field])
            return 1
        return 0
    }
}

; -------------------------
; SORTIERUNG (DESC)
; -------------------------
SortListDesc(ByRef list, field)
{
    Sort, list, F __SortDesc
    return

    __SortDesc(a, b)
    {
        global field
        if (a[field] > b[field])
            return -1
        if (a[field] < b[field])
            return 1
        return 0
    }
}
