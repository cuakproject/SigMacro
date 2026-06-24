; ============================================================
;  shared/Update.ahk — Auto-update checker
;  Taruh file version.txt di GitHub repo lo (isi: 2.1.0)
; ============================================================

global CURRENT_VERSION := "2.1.0"
global VERSION_URL     := "https://raw.githubusercontent.com/cuakproject/sigmacro/main/version.txt"
global RELEASE_URL     := "https://github.com/cuakproject/sigmacro/releases/latest"

CheckForUpdate(silent := false) {
    Log("[Update] Mengecek versi terbaru...")
    verFile := A_Temp "\sigmacro_ver.txt"
    try {
        if FileExist(verFile)
            FileDelete(verFile)
        Download(VERSION_URL, verFile)
        remoteVer := Trim(FileRead(verFile))
        if (remoteVer = "")
            throw Error("Version file kosong")

        if (CompareVersion(remoteVer, CURRENT_VERSION) > 0) {
            Log("[Update] Update tersedia: v" remoteVer " (sekarang v" CURRENT_VERSION ")")
            res := MsgBox(
                "Update tersedia!`n`nVersi sekarang : v" CURRENT_VERSION
                "`nVersi baru     : v" remoteVer "`n`nDownload sekarang?",
                "Sigmacro Update",
                4
            )
            if (res = "Yes")
                Run(RELEASE_URL)
        } else {
            Log("[Update] Sudah versi terbaru (v" CURRENT_VERSION ")")
            if !silent
                MsgBox("Sudah versi terbaru: v" CURRENT_VERSION, "Update", 64)
        }
    } catch as e {
        Log("[Update] Gagal cek update: " e.Message)
        if !silent
            MsgBox("Gagal cek update.`n" e.Message, "Update Error", 16)
    }
}

; Bandingkan "2.1.0" vs "2.0.3" — return 1 kalau a > b
CompareVersion(a, b) {
    pa := StrSplit(Trim(a), ".")
    pb := StrSplit(Trim(b), ".")
    Loop 3 {
        saVal := (pa.Length >= A_Index) ? pa[A_Index] : "0"
        sbVal := (pb.Length >= A_Index) ? pb[A_Index] : "0"
        va := IsNumber(saVal) ? Number(saVal) : 0
        vb := IsNumber(sbVal) ? Number(sbVal) : 0
        if (va > vb) {
            return 1
        }
        if (va < vb) {
            return -1
        }
    }
    return 0
}
