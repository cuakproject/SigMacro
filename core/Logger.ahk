; ============================================================
;  core/Logger.ahk — Centralized logger dengan file logging opsional
; ============================================================

global _logCallback  := ""
global _logToFile    := false
global _logFilePath  := A_ScriptDir "\sigmacro.log"
global _logMaxLines  := 500   ; max baris sebelum rotate

SetLogCallback(fn) {
    global _logCallback
    _logCallback := fn
}

EnableFileLog(enable := true, path := "") {
    global _logToFile, _logFilePath
    _logToFile   := enable
    if (path != "")
        _logFilePath := path
    if enable
        Log("[Logger] File logging aktif: " _logFilePath)
}

Log(msg) {
    global _logCallback, _logToFile, _logFilePath
    ts   := FormatTime(, "HH:mm:ss")
    line := "[" ts "] " msg

    if _logCallback
        _logCallback.Call(line)
    else
        OutputDebug(line)

    if _logToFile
        _WriteLogFile(line)
}

_WriteLogFile(line) {
    global _logFilePath, _logMaxLines
    try {
        FileAppend(line "`n", _logFilePath, "UTF-8")
        ; Rotate kalau terlalu besar (>500 baris)
        content := FileRead(_logFilePath)
        lines   := StrSplit(content, "`n")
        if lines.Length > _logMaxLines {
            trimmed := ""
            start   := lines.Length - _logMaxLines
            Loop _logMaxLines {
                trimmed .= lines[start + A_Index] "`n"
            }
            FileDelete(_logFilePath)
            FileAppend(trimmed, _logFilePath, "UTF-8")
        }
    } catch {
        ; Gagal tulis log, skip
    }
}

ClearLog() {
    global _logFilePath
    try FileDelete(_logFilePath)
    Log("[Logger] Log file dihapus")
}
