; ============================================================
;  core/ImageSearch.ahk — Image search helpers
;  Region default baca dari COORD, toleransi dari CFG
; ============================================================

FindImage(imagePath, x1, y1, x2, y2, &outX, &outY, tolerances := "") {
    global CFG
    if (tolerances = "")
        tolerances := CFG["img_tolerances"]
    if !FileExist(imagePath) {
        Log("⚠ Image tidak ada: " imagePath)
        return false
    }
    for tol in StrSplit(tolerances, ",") {
        if ImageSearch(&fx, &fy, x1, y1, x2, y2, "*" tol " " imagePath) {
            outX := Integer(fx)
            outY := Integer(fy)
            return true
        }
    }
    return false
}

FindBottomImage(imagePath, x1, y1, x2, y2, &outX, &outY, tolerances := "") {
    global CFG
    if (tolerances = "")
        tolerances := CFG["img_tolerances"]
    if !FileExist(imagePath) {
        Log("⚠ Image tidak ada: " imagePath)
        return false
    }
    found := false
    bestX := 0
    bestY := 0
    for tol in StrSplit(tolerances, ",") {
        top := y1
        Loop {
            if !ImageSearch(&fx, &fy, x1, top, x2, y2, "*" tol " " imagePath)
                break
            if (Integer(fy) > bestY) {
                bestX := Integer(fx)
                bestY := Integer(fy)
                found := true
            }
            top := Integer(fy) + 5
            if (top >= y2)
                break
        }
        if found
            break
    }
    if found {
        outX := bestX
        outY := bestY
    }
    return found
}

WaitForImage(imagePath, x1, y1, x2, y2, timeoutMs := 0, tolerances := "") {
    global CFG
    if (timeoutMs = 0)
        timeoutMs := CFG["tfa_timeout"]
    if (tolerances = "")
        tolerances := CFG["img_tol_fast"]
    elapsed := 0
    Loop {
        if FindImage(imagePath, x1, y1, x2, y2, &fx, &fy, tolerances)
            return true
        Sleep(100)
        elapsed += 100
        if (elapsed >= timeoutMs)
            return false
    }
}

; ── Region helpers (pakai COORD map) ──────────────────────────

FindInRegion(imagePath, &outX, &outY, tolerances := "") {
    global COORD
    return FindImage(imagePath,
        COORD["region_x1"], COORD["region_y1"],
        COORD["region_x2"], COORD["region_y2"],
        &outX, &outY, tolerances)
}

WaitInRegion(imagePath, timeoutMs := 0, tolerances := "") {
    global COORD
    return WaitForImage(imagePath,
        COORD["region_x1"], COORD["region_y1"],
        COORD["region_x2"], COORD["region_y2"],
        timeoutMs, tolerances)
}

CheckIncompatible() {
    return FindInRegion(A_ScriptDir "\incompatible.png", &fx, &fy, "30,50,70,90,110,130")
}

WaitForTwoStepPage(timeoutMs := 0) {
    return WaitInRegion(A_ScriptDir "\twostep_icon.png", timeoutMs)
}

FindPasswordLabel(&outX, &outY) {
    WinGetPos(&wx, &wy, &ww, &wh, "A")
    return FindBottomImage(A_ScriptDir "\label_password.png",
                           wx, wy, wx+ww, wy+wh, &outX, &outY)
}
