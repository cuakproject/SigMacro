; ============================================================
;  shared/Constants.ahk — Named constants untuk semua koordinat & timing
;  Semua hardcoded coords dipindah ke sini. Edit di satu tempat.
; ============================================================

global COORD := Map(
    ; ── BACKUP CODES ──────────────────────────────────────────
    "bc_code1_x",       1677,
    "bc_code1_y",       1008,
    "bc_code2_x",       1607,
    "bc_code2_y",       1007,

    ; ── LOGIN FIELDS ──────────────────────────────────────────
    "login_focus_x",    1689,
    "login_focus_y",    377,
    "login_user_x",     1407,
    "login_user_y",     343,
    "login_pass_x",     1434,
    "login_pass_y",     411,
    "login_pass2_x",    1441,
    "login_pass2_y",    403,
    "login_pass3_x",    1490,
    "login_pass3_y",    412,
    "login_submit1_x",  1425,
    "login_submit1_y",  718,
    "login_submit2_x",  1433,
    "login_submit2_y",  709,

    ; ── CLIPBOARD / WIN+V ─────────────────────────────────────
    "winv_focus_x",     1720,
    "winv_focus_y",     376,

    ; ── 2FA / BC FLOW ─────────────────────────────────────────
    "bc_input_focus_x", 1437,
    "bc_input_focus_y", 579,
    "bc_input_x",       1458,
    "bc_input_y",       470,
    "bc_random1_x",     1380,
    "bc_random1_y",     675,
    "bc_random2_x",     1318,
    "bc_random2_y",     762,

    ; ── BC AUTHEN FLOW ────────────────────────────────────────
    "authen_alt_x",     1436,
    "authen_alt_y",     508,
    "authen_bc_opt_x",  1399,
    "authen_bc_opt_y",  472,

    ; ── BC WITH INCOMPAT FLOW ─────────────────────────────────
    "incompat_focus_x", 1455,
    "incompat_focus_y", 505,
    "incompat_bc_x",    1433,
    "incompat_bc_y",    470,

    ; ── PASSWORD LABEL OFFSET ─────────────────────────────────
    "pwd_label_offset_x", 100,
    "pwd_label_offset_y", 10,
    "pwd_scroll1_x",    1814,
    "pwd_scroll1_y",    803,

    ; ── WEBSITE LOGIN (BROWSER CLICKS) ────────────────────────
    "web_tab1_x",       356,
    "web_tab1_y",       327,
    "web_tab2_x",       575,
    "web_tab2_y",       329,
    "web_tab3_x",       647,
    "web_tab3_y",       384,

    ; ── TELEGRAM FLOW ─────────────────────────────────────────
    "tele_click1_x",    671,
    "tele_click1_y",    358,
    "tele_click2_x",    556,
    "tele_click2_y",    323,

    ; ── IMAGE SEARCH REGION (monitor 2) ───────────────────────
    "region_x1",        953,
    "region_y1",        0,
    "region_x2",        1927,
    "region_y2",        638
)

; Shorthand helper: ambil coord pair sebagai Array [x, y]
GetCoord(name) {
    return [COORD[name "_x"], COORD[name "_y"]]
}
