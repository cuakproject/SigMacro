; ============================================================
;  Main.ahk  —  Sigmacro v2.1 (Modular Edition)
;  Requires AHK v2.0+
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
DllCall("SetProcessDPIAware")

; ── COORDMODE — WAJIB sebelum semua include ───────────────
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
SendMode("Input")

; ── MODULES (urutan penting!) ──────────────────────────────
#Include shared\Constants.ahk      ; COORD map — semua koordinat
#Include shared\Config.ahk         ; CFG map — timing, toleransi (INI)
#Include shared\Stats.ahk          ; RecordSession, LoadStats, ResetStats
#Include shared\Update.ahk         ; CheckForUpdate
#Include core\Logger.ahk           ; Log, SetLogCallback, EnableFileLog
#Include core\Mouse.ahk            ; HumanClick, BezierMove, Delay
#Include core\ImageSearch.ahk      ; FindImage, WaitForImage, CheckIncompatible
#Include core\Logic.ahk            ; Semua aksi (Login, BC, dll)
#Include ui\SettingsDialog.ahk     ; ShowSettingsDialog

; ── INIT ───────────────────────────────────────────────────
if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

EnsureDefaultConfig()
LoadConfig()
LoadStats()

iconPath := A_MyDocuments "\..\Downloads\sigmacro\mamayo.ico"
if FileExist(iconPath)
    TraySetIcon(iconPath)

; ── GLOBAL STATE ───────────────────────────────────────────
global g_IsRunning := false
global g_TotalAttempts  ; diset oleh LoadStats()
global g_SuccessCount   ; diset oleh LoadStats()

; ── GUI ────────────────────────────────────────────────────
global AppGui := Gui("+AlwaysOnTop", "Ditsyy v2.1")
global StatusText, EditLog, StatsText

AppGui.BackColor := "F0F0F0"

; Header
AppGui.SetFont("s14 c222222 Bold", "Segoe UI")
AppGui.Add("Text", "x10 y8 w380 Center BackgroundTrans", "Ditsy v2.1")

AppGui.SetFont("s8 c888888 Norm", "Segoe UI")
AppGui.Add("Text", "x10 y32 w380 Center BackgroundTrans", "Automation Tool - Sigma")

AppGui.SetFont("s9 c444444 Bold", "Segoe UI")
StatusText := AppGui.Add("Text", "x10 y50 w380 Center vStatusText BackgroundTrans", "Ready")

; ── GROUP: LOGIN ───────────────────────────────────────────
AppGui.SetFont("s9 c444444 Bold", "Segoe UI")
AppGui.Add("GroupBox", "x10 y70 w380 h110", "LOGIN")
AppGui.SetFont("s9 c000000 Norm", "Segoe UI")
b1 := AppGui.Add("Button", "x22 y88  w178 h30", "Login Clipboard")
b2 := AppGui.Add("Button", "x206 y88  w178 h30", "Login Website")
b3 := AppGui.Add("Button", "x22 y124 w178 h30", "PW Tele")
b4 := AppGui.Add("Button", "x206 y124 w178 h30", "Paste PW")

; ── GROUP: BACKUP CODE ─────────────────────────────────────
AppGui.SetFont("s9 c444444 Bold", "Segoe UI")
AppGui.Add("GroupBox", "x10 y188 w380 h110", "BACKUP CODE")
AppGui.SetFont("s9 c000000 Norm", "Segoe UI")
b5 := AppGui.Add("Button", "x22 y206 w178 h30", "Proses BC 1")
b6 := AppGui.Add("Button", "x206 y206 w178 h30", "Proses BC 2")
b7 := AppGui.Add("Button", "x22 y242 w178 h30", "BC Authen")
b8 := AppGui.Add("Button", "x206 y242 w178 h30", "Copy BC")

; ── GROUP: TOOLS ───────────────────────────────────────────
AppGui.SetFont("s9 c444444 Bold", "Segoe UI")
AppGui.Add("GroupBox", "x10 y306 w380 h55", "TOOLS")
AppGui.SetFont("s9 c000000 Norm", "Segoe UI")
b9  := AppGui.Add("Button", "x22  y324 w86 h30", "Reload")
b10 := AppGui.Add("Button", "x114 y324 w86 h30", "Exit")
b11 := AppGui.Add("Button", "x206 y324 w86 h30", "Pause")
b12 := AppGui.Add("Button", "x298 y324 w86 h30", "Settings")

; ── LOG ────────────────────────────────────────────────────
AppGui.SetFont("s9 c444444 Bold", "Segoe UI")
AppGui.Add("GroupBox", "x10 y369 w380 h90", "LOG")
AppGui.SetFont("s8 c222222 Norm", "Consolas")
EditLog := AppGui.Add("Edit", "x20 y387 w362 h62 vEditLog ReadOnly -VScroll")

; ── FOOTER ─────────────────────────────────────────────────
AppGui.SetFont("s7 c888888 Norm", "Segoe UI")
StatsText := AppGui.Add("Text", "x12 y467 w280 vStatsText BackgroundTrans",
    "Sessions: 0 success / 0 total  (0%)")

AppGui.SetFont("s7 cAAAAAA Norm", "Segoe UI")
AppGui.Add("Text", "x12 y481 w380 BackgroundTrans",
    "Ctrl+B Reload  |  Ctrl+Esc Exit  |  Ctrl+F12 Pause")

; ── EVENT BINDING ──────────────────────────────────────────
b1.OnEvent("Click",  (*) => GuiAction("Login Clipboard",  DoLoginClipboard))
b2.OnEvent("Click",  (*) => GuiAction("Login Website",    DoLoginWebsite))
b3.OnEvent("Click",  (*) => GuiAction("PW Tele",          PwdThenBC))
b4.OnEvent("Click",  (*) => GuiAction("Paste PW",         PastePwClipboard))
b5.OnEvent("Click",  (*) => GuiAction("Proses BC 1",      DoProsesBC1))
b6.OnEvent("Click",  (*) => GuiAction("Proses BC 2",      BCWithIncompat))
b7.OnEvent("Click",  (*) => GuiAction("BC Authen",        BCAuthen))
b8.OnEvent("Click",  (*) => GuiAction("Copy BC",          CopyBackupCodes))
b9.OnEvent("Click",  (*) => Reload())
b10.OnEvent("Click", (*) => ExitApp())
b11.OnEvent("Click", (*) => TogglePause())
b12.OnEvent("Click", (*) => ShowSettingsDialog())
AppGui.OnEvent("Close", (*) => ExitApp())

; ── START ──────────────────────────────────────────────────
SetLogCallback(UILog)
EnableFileLog(true)   ; aktifkan file logging ke sigmacro.log
UpdateStats()
AppGui.Show("x50 y50 w400 h501")
UILog("[" FormatTime(, "HH:mm:ss") "] Hotkeys enabled — Sigmacro v2.1 ready")

; Cek update di background (silent, tidak popup kalau udah terbaru)
SetTimer(() => CheckForUpdate(true), -3000)

; ── HOTKEYS ────────────────────────────────────────────────
^u:: HotkeyAction("Login Clipboard",  DoLoginClipboard)
^m:: HotkeyAction("Login Website",    DoLoginWebsite)
^p:: HotkeyAction("PW Tele",          PwdThenBC)
^q:: HotkeyAction("Paste PW",         PastePwClipboard)
^o:: HotkeyAction("Proses BC 1",      DoProsesBC1)
^e:: HotkeyAction("Proses BC 2",      BCWithIncompat)
^k:: HotkeyAction("BC Authen",        BCAuthen)
^i:: HotkeyAction("Copy BC",          CopyBackupCodes)
^b:: Reload()
^Esc:: ExitApp()
^F12:: TogglePause()

; Debug
^j:: ShowMousePos()
^t:: DebugFind2FA()
^y:: DebugWinPos()
^0:: MsgBox(CheckIncompatible() ? "Incompatible KEDETECT" : "Tidak kedetect", "Debug")

; ── PAUSE ──────────────────────────────────────────────────
global _paused := false

TogglePause() {
    global _paused
    _paused := !_paused
    if _paused {
        UpdateStatus("Paused")
        UILog("[" FormatTime(, "HH:mm:ss") "] [PAUSE] Script paused")
        Pause(true)
    } else {
        UpdateStatus("Ready")
        UILog("[" FormatTime(, "HH:mm:ss") "] [RESUME] Script resumed")
        Pause(false)
    }
}

; ── DEBUG ──────────────────────────────────────────────────
ShowMousePos() {
    MouseGetPos(&mx, &my)
    UILog("[DEBUG] Mouse: " mx ", " my)
    MsgBox("Posisi Mouse: " mx ", " my, "Debug")
}

DebugFind2FA() {
    if WaitForTwoStepPage(3000) {
        UILog("[DEBUG] 2FA terdeteksi!")
        MsgBox("2FA kedetect!", "Find 2FA")
    } else {
        UILog("[DEBUG] 2FA tidak terdeteksi")
        MsgBox("2FA TIDAK kedetect", "Find 2FA")
    }
}

DebugWinPos() {
    WinGetPos(&tx, &ty, &tw, &th, "A")
    WinGetTitle(&title, "A")
    UILog("[DEBUG] Window: " SubStr(title, 1, 30) " | " tw "x" th)
    MsgBox("Window: " title "`nX: " tx " Y: " ty " W: " tw " H: " th, "Window Pos")
}

; ── UI HELPERS ─────────────────────────────────────────────
GuiAction(name, fn) {
    global g_IsRunning
    if (g_IsRunning)
        return
    g_IsRunning := true
    UpdateStatus("Running")
    UILog("[" FormatTime(, "HH:mm:ss") "] [START] " name)
    success := false
    try {
        fn.Call()
        success := true
        UILog("[" FormatTime(, "HH:mm:ss") "] [OK] " name " selesai")
        UpdateStatus("Ready")
    } catch as e {
        UILog("[" FormatTime(, "HH:mm:ss") "] [ERROR] " e.Message)
        UpdateStatus("Error")
        Sleep(2000)
        UpdateStatus("Ready")
    }
    RecordSession(success)
    g_IsRunning := false
}

HotkeyAction(name, fn) {
    global g_IsRunning
    if (g_IsRunning)
        return
    g_IsRunning := true
    UpdateStatus("Running")
    UILog("[" FormatTime(, "HH:mm:ss") "] [START] " name)
    success := false
    try {
        fn.Call()
        success := true
        UILog("[" FormatTime(, "HH:mm:ss") "] [OK] " name " selesai")
        UpdateStatus("Ready")
    } catch as e {
        UILog("[" FormatTime(, "HH:mm:ss") "] [ERROR] " e.Message)
        UpdateStatus("Error")
        Sleep(2000)
        UpdateStatus("Ready")
    }
    RecordSession(success)
    g_IsRunning := false
}

UpdateStatus(status) {
    if (status = "Running")
        StatusText.Text := "⌛ Processing..."
    else if (status = "Error")
        StatusText.Text := "✗ Error"
    else if (status = "Paused")
        StatusText.Text := "⏸ Paused"
    else
        StatusText.Text := "✓ Ready"
}

UILog(line) {
    current := EditLog.Value
    newText  := current . (current = "" ? "" : "`n") . line
    EditLog.Value := newText
    SendMessage(0x115, 7, 0, EditLog)
}

UpdateStats() {
    global g_SuccessCount, g_TotalAttempts
    StatsText.Text := "Sessions: " g_SuccessCount " success / " g_TotalAttempts " total"
        . "  (" GetSuccessRate() ")"
}
