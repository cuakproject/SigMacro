; ============================================================
;  shared/Stats.ahk — Session stats dengan persistence ke INI
; ============================================================

global STATS_PATH := A_ScriptDir "\stats.ini"

LoadStats() {
    global g_TotalAttempts, g_SuccessCount, STATS_PATH
    try {
        g_TotalAttempts := Integer(IniRead(STATS_PATH, "Session", "Total",   0))
        g_SuccessCount  := Integer(IniRead(STATS_PATH, "Session", "Success", 0))
    } catch {
        g_TotalAttempts := 0
        g_SuccessCount  := 0
    }
    Log("[Stats] Loaded — " g_SuccessCount "/" g_TotalAttempts)
}

RecordSession(success) {
    global g_TotalAttempts, g_SuccessCount, STATS_PATH
    g_TotalAttempts++
    if success
        g_SuccessCount++
    try {
        IniWrite(g_TotalAttempts, STATS_PATH, "Session", "Total")
        IniWrite(g_SuccessCount,  STATS_PATH, "Session", "Success")
        IniWrite(FormatTime(, "yyyy-MM-dd HH:mm:ss"), STATS_PATH, "Session", "LastRun")
    }
    UpdateStats()
}

ResetStats() {
    global g_TotalAttempts, g_SuccessCount, STATS_PATH
    g_TotalAttempts := 0
    g_SuccessCount  := 0
    try FileDelete(STATS_PATH)
    UpdateStats()
    Log("[Stats] Reset.")
}

GetSuccessRate() {
    global g_TotalAttempts, g_SuccessCount
    if g_TotalAttempts = 0
        return "0%"
    pct := Round(g_SuccessCount / g_TotalAttempts * 100, 1)
    return pct "%"
}
