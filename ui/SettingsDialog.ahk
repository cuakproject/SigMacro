; ============================================================
;  ui/SettingsDialog.ahk — Settings panel (edit & save tanpa restart)
; ============================================================

ShowSettingsDialog() {
    global CFG

    sd := Gui("+AlwaysOnTop +Owner", "Settings — Sigmacro")
    sd.BackColor := "F0F0F0"
    sd.SetFont("s9 c444444 Bold", "Segoe UI")
    sd.Add("Text", "x10 y10 w360 Center", "Edit Settings")

    ; ── TIMING ────────────────────────────────────────────────
    sd.SetFont("s9 c444444 Bold", "Segoe UI")
    sd.Add("GroupBox", "x10 y30 w360 h140", "Timing (ms)")
    sd.SetFont("s9 c000000 Norm", "Segoe UI")

    sd.Add("Text",  "x20 y50 w140",  "Delay Min:")
    edDelayMin := sd.Add("Edit", "x165 y48 w80 h22 Number", CFG["delay_min"])

    sd.Add("Text",  "x20 y76 w140",  "Delay Max:")
    edDelayMax := sd.Add("Edit", "x165 y74 w80 h22 Number", CFG["delay_max"])

    sd.Add("Text",  "x20 y102 w140", "2FA Timeout:")
    edTFATimeout := sd.Add("Edit", "x165 y100 w80 h22 Number", CFG["tfa_timeout"])

    sd.Add("Text",  "x20 y128 w140", "WinV Delay:")
    edWinVDelay := sd.Add("Edit", "x165 y126 w80 h22 Number", CFG["winv_delay"])

    ; ── RETRY ─────────────────────────────────────────────────
    sd.SetFont("s9 c444444 Bold", "Segoe UI")
    sd.Add("GroupBox", "x10 y178 w360 h55", "Retry")
    sd.SetFont("s9 c000000 Norm", "Segoe UI")

    sd.Add("Text",  "x20 y198 w140", "BC Max Retry:")
    edMaxRetry := sd.Add("Edit", "x165 y196 w80 h22 Number", CFG["bc_max_retry"])

    ; ── BUTTONS ───────────────────────────────────────────────
    btnSave  := sd.Add("Button", "x10  y244 w170 h30", "Simpan & Apply")
    btnClose := sd.Add("Button", "x200 y244 w170 h30", "Batal")

    btnSave.OnEvent("Click", (*) => _ApplySettings(
        sd, edDelayMin, edDelayMax, edTFATimeout, edWinVDelay, edMaxRetry
    ))
    btnClose.OnEvent("Click", (*) => sd.Destroy())
    sd.OnEvent("Close", (*) => sd.Destroy())

    sd.Show("w380 h286")
}

_ApplySettings(sd, edDelayMin, edDelayMax, edTFATimeout, edWinVDelay, edMaxRetry) {
    global CFG
    CFG["delay_min"]    := Integer(edDelayMin.Value)
    CFG["delay_max"]    := Integer(edDelayMax.Value)
    CFG["tfa_timeout"]  := Integer(edTFATimeout.Value)
    CFG["winv_delay"]   := Integer(edWinVDelay.Value)
    CFG["bc_max_retry"] := Integer(edMaxRetry.Value)
    SaveConfig()
    Log("[Settings] Settings diapply dan disimpan")
    sd.Destroy()
    MsgBox("Settings tersimpan!`nEfektif langsung tanpa restart.", "Settings", 64)
}
