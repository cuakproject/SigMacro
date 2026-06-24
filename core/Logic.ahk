; ============================================================
;  core/Logic.ahk — Semua aksi utama
;  Semua koordinat baca dari COORD map (shared/Constants.ahk)
;  Semua timing baca dari CFG map (shared/Config.ahk)
; ============================================================

CopyBackupCodes() {
    global COORD, CFG

    ; ── Copy BC Code 1 ──────────────────────────────────────
    A_Clipboard := ""
    DirectDoubleClick(COORD["bc_code1_x"], COORD["bc_code1_y"])
    Sleep(400)
    Send("^c")
    ClipWait(2)
    bc1 := A_Clipboard
    Sleep(300)

    ; ── Copy BC Code 2 ──────────────────────────────────────
    A_Clipboard := ""
    DirectDoubleClick(COORD["bc_code2_x"], COORD["bc_code2_y"])
    Sleep(400)
    Send("^c")
    ClipWait(2)
    bc2 := A_Clipboard
    Sleep(300)

    ; ── Copy BC Code 3 ──────────────────────────────────────
    A_Clipboard := ""
    DirectDoubleClick(COORD["bc_code3_x"], COORD["bc_code3_y"])
    Sleep(400)
    Send("^c")
    ClipWait(2)
    bc3 := A_Clipboard
    Sleep(300)
}

FillBackupCodeOnly() {
    global COORD, CFG
    HumanClick(COORD["winv_focus_x"],     COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["bc_input_focus_x"], COORD["bc_input_focus_y"])
    Delay()
    HumanClick(COORD["bc_input_x"],       COORD["bc_input_y"])
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    if (RandInt(1, 2) = 1)
        DirectClick(COORD["bc_random1_x"], COORD["bc_random1_y"])
    else
        DirectClick(COORD["bc_random2_x"], COORD["bc_random2_y"])
    Sleep(CFG["winv_delay"])
    Send("{Enter}")
    Log("🔄 Backup code diisi")
}

AmbilPasswordDanPaste() {
    global COORD, CFG
    DirectClick(COORD["pwd_scroll1_x"], COORD["pwd_scroll1_y"])
    Sleep(200)
    DirectClick(COORD["pwd_scroll1_x"], COORD["pwd_scroll1_y"])
    Sleep(300)

    if !WaitForPasswordLabel(&lx, &ly, 5000) {
        Log("❌ Label password tidak ditemukan")
        return false
    }

    DirectClick(1626, ly + 9)
    Delay()
    HumanClick(COORD["winv_focus_x"],  COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["login_pass2_x"], COORD["login_pass2_y"])
    Delay()
    HumanClick(COORD["login_pass3_x"], COORD["login_pass3_y"])
    Delay()
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 4)
    Sleep(150)
    Send("^v")
    Delay()
    Send("{Enter}")
    Log("✅ Password dipaste")
    return true
}

ProsesBackupCode(maxRetry := 0) {
    global CFG
    if (maxRetry = 0)
        maxRetry := CFG["bc_max_retry"]
    loop maxRetry {
        FillBackupCodeOnly()
        if !WaitForIncompatible(3000) {
            Log("✅ Selesai, tidak ada incompatible")
            break
        }
        Log("⚠️ Incompatible, retry " A_Index "/" maxRetry)
        if !AmbilPasswordDanPaste() {
            Log("❌ Gagal ambil password")
            break
        }
        if !WaitForTwoStepPage() {
            Log("❌ 2FA tidak muncul")
            break
        }
        Delay()
    }
}

BCAuthen() {
    global COORD, CFG
    CopyBackupCodes()
    HumanClick(COORD["authen_alt_x"],   COORD["authen_alt_y"])
    Delay()
    HumanClick(COORD["authen_bc_opt_x"], COORD["authen_bc_opt_y"])
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    if (RandInt(1, 2) = 1)
        DirectClick(COORD["bc_random1_x"], COORD["bc_random1_y"])
    else
        DirectClick(COORD["bc_random2_x"], COORD["bc_random2_y"])
    Sleep(CFG["winv_delay"])
    Send("{Enter}")
    Log("🔄 Backup code diisi via Authen")
    Sleep(CFG["incompat_wait"])
    if CheckIncompatible() {
        Log("⚠️ Incompatible terdeteksi")
        if AmbilPasswordDanPaste() {
            if WaitForTwoStepPage() {
                Delay()
                ProsesBackupCode()
            } else
                Log("❌ 2FA tidak terdeteksi")
        } else
            Log("❌ Gagal ambil password")
    } else
        Log("✅ Selesai")
}

DoLoginClipboard() {
    global COORD, CFG
    HumanClick(COORD["login_focus_x"], COORD["login_focus_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(350, 450)
    HumanClick(COORD["login_user_x"],  COORD["login_user_y"])
    RandSleep(150, 200)
    HumanDoubleClick(COORD["login_user_x"], COORD["login_user_y"], 2)
    Sleep(150)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit1_x"], COORD["login_submit1_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(100, 150)
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(150)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit2_x"], COORD["login_submit2_y"])
    RandSleep(CFG["submit_delay"], CFG["submit_delay"] + 100)
    Send("{Enter}")
    Log("🚀 Login clipboard dikirim")
    CopyBackupCodes()
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("❌ 2FA tidak terdeteksi")
}

DoLoginWebsite() {
    global COORD, CFG
    DirectClick(COORD["web_tab1_x"], COORD["web_tab1_y"])
    Sleep(350)
    DirectClick(COORD["web_tab2_x"], COORD["web_tab2_y"])
    Sleep(350)
    DirectClick(COORD["web_tab3_x"], COORD["web_tab3_y"])
    Sleep(350)
    HumanClick(COORD["login_focus_x"], COORD["login_focus_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(350, 450)
    HumanClick(COORD["login_user_x"],  COORD["login_user_y"])
    RandSleep(150, 200)
    HumanDoubleClick(COORD["login_user_x"], COORD["login_user_y"], 4)
    Sleep(150)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit1_x"], COORD["login_submit1_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(100, 150)
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 4)
    Sleep(150)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit2_x"], COORD["login_submit2_y"])
    RandSleep(CFG["submit_delay"], CFG["submit_delay"] + 100)
    Send("{Enter}")
    Log("🚀 Login website dikirim")
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("❌ 2FA tidak terdeteksi")
}

PastePwClipboard() {
    global COORD, CFG
    DirectClick(578, 333)
    Sleep(200)
    HumanClick(COORD["winv_focus_x"],  COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["login_pass2_x"], COORD["login_pass2_y"])
    Delay()
    HumanClick(COORD["login_pass3_x"], COORD["login_pass3_y"])
    Delay()
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 4)
    Sleep(150)
    Send("^v")
    Delay()
    Send("{Enter}")
    Log("🚀 Paste PW selesai")
    CopyBackupCodes()
    if !WaitForTwoStepPage() {
        Log("❌ 2FA tidak terdeteksi")
        return
    }
    Delay()
    ProsesBackupCode()
}


PastePwTelegram() {
    global COORD, CFG
    DirectClick(COORD["tele_click1_x"], COORD["tele_click1_y"])
    Sleep(200)
    DirectClick(COORD["tele_click2_x"], COORD["tele_click2_y"])
    Delay()
    HumanClick(COORD["winv_focus_x"],  COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["login_pass2_x"], COORD["login_pass2_y"])
    Delay()
    HumanClick(COORD["login_pass3_x"], COORD["login_pass3_y"])
    Delay()
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 4)
    Sleep(150)
    Send("^v")
    Delay()
    Send("{Enter}")
    Log("🚀 Paste PW Telegram selesai")
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("❌ 2FA tidak terdeteksi")
}

PwdThenBC() {
    if AmbilPasswordDanPaste() {
        CopyBackupCodes()
        if WaitForTwoStepPage() {
            Delay()
            ProsesBackupCode()
        } else
            Log("❌ 2FA tidak muncul")
    }
}

BCWithIncompat() {
    global COORD, CFG
    CopyBackupCodes()
    HumanClick(COORD["winv_focus_x"],     COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["incompat_focus_x"], COORD["incompat_focus_y"])
    Delay()
    HumanClick(COORD["incompat_bc_x"],    COORD["incompat_bc_y"])
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    if (RandInt(1, 2) = 1)
        DirectClick(COORD["bc_random1_x"], COORD["bc_random1_y"])
    else
        DirectClick(COORD["bc_random2_x"], COORD["bc_random2_y"])
    Sleep(CFG["winv_delay"])
    Send("{Enter}")
    if !WaitForIncompatible(3000) {
        Log("✅ Selesai, tidak ada incompatible")
        return
    }
    Log("⚠️ Incompatible terdeteksi")
    if !AmbilPasswordDanPaste() {
        Log("❌ Gagal ambil password")
        return
    }
    CopyBackupCodes()
    if !WaitForTwoStepPage() {
        Log("❌ 2FA tidak terdeteksi")
        return
    }
    Delay()
    ProsesBackupCode()
}

DoProsesBC1() {
    CopyBackupCodes()
    ProsesBackupCode()
}