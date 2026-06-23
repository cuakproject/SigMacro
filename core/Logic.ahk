; ============================================================
;  core/Logic.ahk — Semua aksi utama
;  Semua koordinat baca dari COORD map (shared/Constants.ahk)
;  Semua timing baca dari CFG map (shared/Config.ahk)
; ============================================================

CopyBackupCodes() {
    global COORD, CFG
    DirectDoubleClick(COORD["bc_code1_x"], COORD["bc_code1_y"])
    Sleep(350)
    Send("^c")
    Sleep(350)
    DirectDoubleClick(COORD["bc_code2_x"], COORD["bc_code2_y"])
    Sleep(350)
    Send("^c")
    Sleep(350)
    Log("✓ Backup codes disalin")
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
    Log("→ Backup code diisi")
}

AmbilPasswordDanPaste() {
    global COORD, CFG
    DirectClick(COORD["pwd_scroll1_x"], COORD["pwd_scroll1_y"])
    Sleep(200)
    DirectClick(COORD["pwd_scroll1_x"], COORD["pwd_scroll1_y"])
    Sleep(300)
    if !FindPasswordLabel(&lx, &ly) {
        Log("✗ Label password tidak ditemukan")
        return false
    }
    HumanClick(lx + COORD["pwd_label_offset_x"], ly + COORD["pwd_label_offset_y"])
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
    Log("✓ Password dipaste")
    return true
}

ProsesBackupCode(maxRetry := 0) {
    global CFG
    if (maxRetry = 0)
        maxRetry := CFG["bc_max_retry"]
    loop maxRetry {
        FillBackupCodeOnly()
        Sleep(CFG["incompat_wait"])
        if !CheckIncompatible() {
            Log("✓ Tidak ada incompatible, selesai")
            break
        }
        Log("⚠ Incompatible, retry " A_Index "/" maxRetry)
        if !AmbilPasswordDanPaste() {
            Log("✗ Gagal ambil password")
            break
        }
        if !WaitForTwoStepPage() {
            Log("✗ 2FA tidak muncul")
            break
        }
        Delay()
    }
}

BCAuthen() {
    global COORD, CFG
    CopyBackupCodes()
    Log("→ Klik use another verification method")
    HumanClick(COORD["authen_alt_x"],   COORD["authen_alt_y"])
    Delay()
    Log("→ Klik opsi backup code")
    HumanClick(COORD["authen_bc_opt_x"], COORD["authen_bc_opt_y"])
    Delay()
    Log("→ Paste backup code")
    Send("#v")
    Sleep(CFG["winv_delay"])
    if (RandInt(1, 2) = 1)
        DirectClick(COORD["bc_random1_x"], COORD["bc_random1_y"])
    else
        DirectClick(COORD["bc_random2_x"], COORD["bc_random2_y"])
    Sleep(CFG["winv_delay"])
    Send("{Enter}")
    Log("→ Backup code diisi via Authen")
    Sleep(CFG["incompat_wait"])
    if CheckIncompatible() {
        Log("⚠ Incompatible terdeteksi, ambil password...")
        if AmbilPasswordDanPaste() {
            if WaitForTwoStepPage() {
                Delay()
                ProsesBackupCode()
            } else
                Log("✗ Halaman 2FA tidak terdeteksi")
        } else
            Log("✗ Gagal ambil password")
    } else
        Log("✓ Tidak ada incompatible, selesai")
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
    Log("→ Login clipboard dikirim")
    CopyBackupCodes()
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("✗ Halaman 2FA tidak terdeteksi")
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
    Log("→ Login website dikirim")
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("✗ Halaman 2FA tidak terdeteksi")
}

PastePwClipboard() {
    global COORD, CFG
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
    Log("→ Paste PW clipboard selesai")
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
    Log("→ Paste PW Telegram selesai")
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("✗ Halaman 2FA tidak terdeteksi")
}

PwdThenBC() {
    if AmbilPasswordDanPaste() {
        CopyBackupCodes()
        if WaitForTwoStepPage() {
            Delay()
            ProsesBackupCode()
        } else
            Log("✗ 2FA tidak muncul")
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
    Sleep(CFG["incompat_wait"])
    if CheckIncompatible() {
        if AmbilPasswordDanPaste() {
            if WaitForTwoStepPage() {
                Delay()
                ProsesBackupCode()
            }
        }
    }
}

DoProsesBC1() {
    CopyBackupCodes()
    ProsesBackupCode()
}
