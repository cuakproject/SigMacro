; ── Screenshot region → langsung ke clipboard sebagai bitmap ──
; Taruh fungsi ini di core/Logic.ahk
; Hotkey di Main.ahk: PrintScreen:: HotkeyAction("Screenshot", CaptureScreenshotRegion)

CaptureScreenshotRegion() {
    global CFG_PATH

    ; Baca region dari INI
    x1 := IniRead(CFG_PATH, "Regions", "region_screenshot_x1", "")
    y1 := IniRead(CFG_PATH, "Regions", "region_screenshot_y1", "")
    x2 := IniRead(CFG_PATH, "Regions", "region_screenshot_x2", "")
    y2 := IniRead(CFG_PATH, "Regions", "region_screenshot_y2", "")

    if (x1 = "" || y1 = "" || x2 = "" || y2 = "") {
        Log("❌ SS Region belum di-set. Buka RegionSelector → 📷 SS Region")
        return
    }

    w := x2 - x1
    h := y2 - y1

    ; ── GDI: capture region layar ke HBITMAP ──────────────
    hScrDC  := DllCall("GetDC",                  "Ptr", 0,      "Ptr")
    hMemDC  := DllCall("CreateCompatibleDC",     "Ptr", hScrDC, "Ptr")
    hBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hScrDC, "Int", w, "Int", h, "Ptr")
    DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
    DllCall("BitBlt",
        "Ptr", hMemDC, "Int", 0,  "Int", 0,  "Int", w, "Int", h,
        "Ptr", hScrDC, "Int", x1, "Int", y1, "UInt", 0x00CC0020)  ; SRCCOPY

    ; ── Copy HBITMAP ke clipboard sebagai CF_BITMAP ───────
    DllCall("OpenClipboard",  "Ptr", 0)
    DllCall("EmptyClipboard")
    ; CF_BITMAP = 2
    ; SetClipboardData butuh HBITMAP yang sudah di-"detach" dari DC
    ; Buat salinan bitmap dulu supaya aman setelah DeleteDC
    hBitmapClip := DllCall("CopyImage", "Ptr", hBitmap, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
    DllCall("SetClipboardData", "UInt", 2, "Ptr", hBitmapClip)
    DllCall("CloseClipboard")

    ; ── Cleanup ───────────────────────────────────────────
    DllCall("DeleteObject", "Ptr", hBitmap)
    DllCall("DeleteDC",     "Ptr", hMemDC)
    DllCall("ReleaseDC",    "Ptr", 0, "Ptr", hScrDC)

    Log("📷 Screenshot tersimpan ke clipboard (" w "×" h "px)")
}
