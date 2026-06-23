; ============================================================
;  core/Mouse.ahk — Human-like mouse movement
;  Semua timing baca dari CFG (shared/Config.ahk)
; ============================================================

RandInt(lo, hi) {
    return Integer(Round(Random(lo, hi)))
}

RandOff(base, variance) {
    return Integer(Round(base + Random(-variance, variance)))
}

RandSleep(lo, hi) {
    Sleep(RandInt(lo, hi))
}

; Delay standar pakai config
Delay() {
    global CFG
    RandSleep(CFG["delay_min"], CFG["delay_max"])
}

BezierMove(x1, y1, x2, y2, steps, sleepMs) {
    global CFG
    offX := RandInt(CFG["bez_offset_min"], CFG["bez_offset_max"])
    offY := RandInt(CFG["bez_offset_min"], CFG["bez_offset_max"])
    mx   := Integer(Round((x1+x2)/2)) + RandInt(-offX, offX)
    my   := Integer(Round((y1+y2)/2)) + RandInt(-offY, offY)
    Loop steps {
        t  := A_Index / steps
        cx := Integer(Round((1-t)**2 * x1 + 2*(1-t)*t * mx + t**2 * x2)) + RandInt(-1, 1)
        cy := Integer(Round((1-t)**2 * y1 + 2*(1-t)*t * my + t**2 * y2)) + RandInt(-1, 1)
        MouseMove(cx, cy, 0)
        Sleep(sleepMs)
    }
    MouseMove(x2, y2, 0)
    Sleep(10)
}

HumanClick(x, y, variance := 8) {
    global CFG
    MouseGetPos(&sx, &sy)
    tx := RandOff(x, variance)
    ty := RandOff(y, variance)
    BezierMove(Integer(sx), Integer(sy), tx, ty,
               RandInt(CFG["bez_steps_min"], CFG["bez_steps_max"]),
               RandInt(CFG["bez_sleep_min"], CFG["bez_sleep_max"]))
    Sleep(RandInt(CFG["click_pre"], CFG["click_pre"] + 15))
    Click()
    Sleep(RandInt(CFG["click_post"], CFG["click_post"] + 25))
}

HumanDoubleClick(x, y, variance := 8) {
    global CFG
    MouseGetPos(&sx, &sy)
    tx := RandOff(x, variance)
    ty := RandOff(y, variance)
    BezierMove(Integer(sx), Integer(sy), tx, ty,
               RandInt(CFG["bez_steps_min"], CFG["bez_steps_max"]),
               RandInt(CFG["bez_sleep_min"], CFG["bez_sleep_max"]))
    Sleep(RandInt(CFG["click_pre"], CFG["click_pre"] + 15))
    Click(2)
    Sleep(RandInt(CFG["click_post"], CFG["click_post"] + 25))
}

DirectClick(x, y) {
    global CFG
    MouseMove(Integer(x), Integer(y), 0)
    Sleep(20)
    Click()
    Sleep(30)
}

DirectDoubleClick(x, y) {
    MouseMove(Integer(x), Integer(y), 0)
    Sleep(20)
    Click(2)
    Sleep(30)
}
