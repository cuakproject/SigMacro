; ============================================================
;  RegionSelector.ahk — Visual region picker untuk SigMacro
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
DllCall("SetProcessDPIAware")
CoordMode("Mouse", "Screen")

CFG_PATH := A_ScriptDir "\sigmacro.ini"

global g_regionKey  := ""
global g_regionName := ""

; ── GUI ──────────────────────────────────────────────────
g := Gui("+AlwaysOnTop", "Region Selector — SigMacro")
g.BackColor := "1E1E2E"
g.SetFont("s10 cCDD6F4 Bold", "Segoe UI")
g.Add("Text", "x15 y12 w350 Center", "Pilih region yang mau di-set:")
g.SetFont("s9 cA6E3A1 Norm", "Segoe UI")
g.Add("Text", "x15 y34 w350 Center", "Klik tombol → klik & drag di layar → lepas")

g.SetFont("s9 cCDD6F4 Bold", "Segoe UI")
b1 := g.Add("Button", "x15  y60 w100 h34", "Incompatible")
b2 := g.Add("Button", "x125 y60 w100 h34", "2FA Icon")
b3 := g.Add("Button", "x235 y60 w100 h34", "Password")
b4 := g.Add("Button", "x15  y104 w100 h34", "Invalid BC")
b5 := g.Add("Button", "x125 y104 w100 h34", "Roblox Home")
b6 := g.Add("Button", "x235 y104 w100 h34", "80 Robux")
b7 := g.Add("Button", "x15  y148 w100 h34", "Robux List")
b8 := g.Add("Button", "x125 y148 w100 h34", "Don't Buy")

; ── Tombol SS Region (kuning, beda dari yang lain) ────────
g.SetFont("s9 cF9E2AF Bold", "Segoe UI")
bSS := g.Add("Button", "x235 y148 w100 h34", "📷 SS Region")

; ── Status labels ─────────────────────────────────────────
g.SetFont("s8 cF38BA8 Norm", "Segoe UI")
statusLbl := g.Add("Text", "x15 y192 w350 Center vStatusLbl", "Belum ada region dipilih")
g.SetFont("s8 c89B4FA Norm", "Segoe UI")
coordLbl  := g.Add("Text", "x15 y208 w350 Center vCoordLbl",  "")
g.SetFont("s8 cA6E3A1 Norm", "Segoe UI")
savedLbl  := g.Add("Text", "x15 y224 w350 Center vSavedLbl",  "")

ShowSavedSSRegion()

g.OnEvent("Close", (*) => ExitApp())
g.Show("w380 h255 x50 y50")

b1.OnEvent("Click", (*) => StartDrag("incompat",    "Incompatible Accounts"))
b2.OnEvent("Click", (*) => StartDrag("2fa",         "2FA Icon"))
b3.OnEvent("Click", (*) => StartDrag("pwd",         "Password Label"))
b4.OnEvent("Click", (*) => StartDrag("invalidbc",   "Invalid BC"))
b5.OnEvent("Click", (*) => StartDrag("robloxhome",  "Roblox Home"))
b6.OnEvent("Click", (*) => StartDrag("80robux",     "80 Robux"))
b7.OnEvent("Click", (*) => StartDrag("robuxlist",   "Robux List"))
b8.OnEvent("Click", (*) => StartDrag("dontbuy",     "Don't Buy"))
bSS.OnEvent("Click", (*) => StartDrag("screenshot", "Screenshot Region"))

; ── Tampilkan region screenshot yang sudah ada di INI ─────
ShowSavedSSRegion() {
    global CFG_PATH
    x1 := IniRead(CFG_PATH, "Regions", "region_screenshot_x1", "")
    if (x1 = "")
        return
    y1 := IniRead(CFG_PATH, "Regions", "region_screenshot_y1", "")
    x2 := IniRead(CFG_PATH, "Regions", "region_screenshot_x2", "")
    y2 := IniRead(CFG_PATH, "Regions", "region_screenshot_y2", "")
    g["StatusLbl"].Value := "📷 SS Region aktif — PrintScreen untuk capture"
    g["CoordLbl"].Value  := "x1=" x1 "  y1=" y1 "  x2=" x2 "  y2=" y2
    g["SavedLbl"].Value  := "Drag ulang '📷 SS Region' untuk ganti region"
}

; ── StartDrag ─────────────────────────────────────────────
StartDrag(regionKey, regionName) {
    global g_regionKey, g_regionName
    g_regionKey  := regionKey
    g_regionName := regionName
    g["StatusLbl"].Value := "⏳ Klik & drag di layar untuk [" regionName "]..."
    g["CoordLbl"].Value  := ""
    g["SavedLbl"].Value  := ""
    SetTimer(WaitForDrag, 50)
}

WaitForDrag() {
    if !GetKeyState("LButton", "P")
        return
    SetTimer(WaitForDrag, 0)
    DoDrag()
}

DoDrag() {
    global g_regionKey, g_regionName, CFG_PATH

    ; Sembunyikan GUI biar tidak masuk ke overlay/screenshot
    g.Hide()
    Sleep(80)

    MouseGetPos(&x1, &y1)

    ; ── Win11-style: 4 dark panel + border putih ──────────
    ScrW := SysGet(78)   ; SM_CXVIRTUALSCREEN (total lebar semua monitor)
    ScrH := SysGet(79)   ; SM_CYVIRTUALSCREEN
    ScrX := SysGet(76)   ; SM_XVIRTUALSCREEN  (origin X, bisa negatif)
    ScrY := SysGet(77)   ; SM_YVIRTUALSCREEN

    thick := 2
    top := MakeWhiteBar()
    bot := MakeWhiteBar()
    lft := MakeWhiteBar()
    rgt := MakeWhiteBar()

    ; 4 panel gelap cover area di luar selection
    pTop := MakeDarkPanel()
    pBot := MakeDarkPanel()
    pLft := MakeDarkPanel()
    pRgt := MakeDarkPanel()

    loop {
        if !GetKeyState("LButton", "P")
            break

        MouseGetPos(&cx, &cy)
        rx := Min(x1, cx)
        ry := Min(y1, cy)
        rw := Max(Abs(cx - x1), 1)
        rh := Max(Abs(cy - y1), 1)

        ; Dark panel: area di luar selection
        pTop.Move(ScrX,      ScrY,       ScrW,               ry - ScrY)
        pBot.Move(ScrX,      ry + rh,    ScrW,               (ScrY + ScrH) - (ry + rh))
        pLft.Move(ScrX,      ry,         rx - ScrX,          rh)
        pRgt.Move(rx + rw,   ry,         (ScrX + ScrW) - (rx + rw), rh)

        ; Border putih
        top.Move(rx,      ry,      rw,    thick)
        bot.Move(rx,      ry + rh, rw,    thick)
        lft.Move(rx,      ry,      thick, rh)
        rgt.Move(rx + rw, ry,      thick, rh)

        Sleep(16)
    }

    MouseGetPos(&x2, &y2)

    ; Cleanup overlay
    top.Destroy()
    bot.Destroy()
    lft.Destroy()
    rgt.Destroy()
    pTop.Destroy()
    pBot.Destroy()
    pLft.Destroy()
    pRgt.Destroy()

    g.Show()

    rx1 := Min(x1, x2)
    ry1 := Min(y1, y2)
    rx2 := Max(x1, x2)
    ry2 := Max(y1, y2)

    if (Abs(rx2 - rx1) < 10 || Abs(ry2 - ry1) < 10) {
        g["StatusLbl"].Value := "❌ Terlalu kecil, coba lagi"
        return
    }

    key := g_regionKey
    IniWrite(rx1, CFG_PATH, "Regions", "region_" key "_x1")
    IniWrite(ry1, CFG_PATH, "Regions", "region_" key "_y1")
    IniWrite(rx2, CFG_PATH, "Regions", "region_" key "_x2")
    IniWrite(ry2, CFG_PATH, "Regions", "region_" key "_y2")

    g["StatusLbl"].Value := "✓ [" g_regionName "] tersimpan!"
    g["CoordLbl"].Value  := "x1=" rx1 "  y1=" ry1 "  x2=" rx2 "  y2=" ry2

    if (key = "screenshot")
        g["SavedLbl"].Value := "✅ Siap! PrintScreen kapanpun untuk capture region ini"
    else
        g["SavedLbl"].Value := "→ Reload SigMacro untuk apply"
}

; ── Overlay helpers ───────────────────────────────────────
MakeWhiteBar() {
    bar := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20")
    bar.BackColor := "FFFFFF"
    bar.Show("x0 y0 w1 h1 NoActivate")
    return bar
}

MakeDarkPanel() {
    panel := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20")
    panel.BackColor := "000000"
    panel.Show("x0 y0 w1 h1 NoActivate")
    WinSetTransparent(120, panel)
    return panel
}
