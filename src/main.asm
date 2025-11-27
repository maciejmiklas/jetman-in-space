;----------------------------------------------------------;
;                         Main File                        ;
;----------------------------------------------------------;
STACK_SIZE              = 50

    DEVICE ZXSPECTRUMNEXT                       ; Allow the Next paging and instructions.
    ORG _RAM_SLOT4_STA_H8000 + STACK_SIZE       ; Stack starts at 8000.

start
    DI                                          ; Disable Interrupts, use wait_for_scanline instead.
    NEXTREG _GL_REG_TURBO_H07, %00000011        ; Switch to 28MHz.

    CALL dbs.SetupAyFxsBank
    CALL af.SetupAyFx

    CALL gc.SetupSystem
    CALL gc.LoadLevel1
    ;CALL gc.LoadMainMenu

    ; ##########################################
    ; Music
    CALL dbs.SetupMusicBank
    LD A, aml.MUSIC_MAIN_MENU
    CALL aml.LoadSong

;----------------------------------------------------------;
;                      Main Loop                           ;
;----------------------------------------------------------;
mainLoop

    IFDEF PERFORMANCE_BORDER
        LD  A, _COL_GREEN_D4
        OUT (_BORDER_IO_HFE), A
    ENDIF

    CALL sc.WaitForScanline

    IFDEF PERFORMANCE_BORDER
        LD  A, _COL_RED_D2
        OUT (_BORDER_IO_HFE), A
    ENDIF   

    CALL ml.MainLoop

    JR mainLoop

;----------------------------------------------------------;
;                       Includes                           ;
;----------------------------------------------------------;
    INCLUDE "_constants.asm"

    INCLUDE "gid_game_input_data.asm"
    INCLUDE "gi_game_input.asm"
    INCLUDE "tx_text.asm"
    INCLUDE "ti_tiles.asm"
    INCLUDE "ut_util.asm"
    INCLUDE "mld_main_loop_data.asm"
    INCLUDE "ml_main_loop.asm"

    INCLUDE "gc_game_cmd.asm"

    INCLUDE "er_error.asm"
    INCLUDE "fi_file_io.asm"
    INCLUDE "dbs_bank_setup.asm"
    INCLUDE "ll_level_loader.asm"
    INCLUDE "st_stars.asm"
    INCLUDE "bm_bitmap.asm"
    INCLUDE "bp_bitmap_palette.asm"
    INCLUDE "btd_tod_palette.asm"
    INCLUDE "gb_game_bar.asm"
    INCLUDE "sc_screen.asm"
    INCLUDE "sr_simple_sprite.asm"
    INCLUDE "sp_sprite.asm"
    INCLUDE "jt_jet_state.asm"
    INCLUDE "jpo_jet_position.asm"
    INCLUDE "jco_jet_collision.asm"
    INCLUDE "js_jet_sprite.asm"
    INCLUDE "pl_platform.asm"
    INCLUDE "bg_background.asm"
    INCLUDE "jm_jet_move.asm"
    INCLUDE "jw_jet_weapon.asm"
    INCLUDE "ro_rocket.asm"
    INCLUDE "rof_rocket_fly.asm"
    INCLUDE "ros_rocket_stars.asm"
    INCLUDE "td_times_of_day.asm"
    INCLUDE "jo_jetpack_overheat.asm"
    INCLUDE "li_level_intro.asm"
    INCLUDE "ki_keyboard_input.asm"
    INCLUDE "ms_main_state.asm"
    INCLUDE "mma_menu_main.asm"
    INCLUDE "mmn_menu_manual.asm"
    INCLUDE "mml_menu_level.asm"
    INCLUDE "mms_menu_score.asm"
    INCLUDE "sc_score.asm"
    INCLUDE "pi_pickups.asm"
    INCLUDE "jl_jetman_lives.asm"
    INCLUDE "go_game_over.asm"
    INCLUDE "gr_grenade.asm"
    INCLUDE "lu_level_unlock.asm"

    ; Imports below use ORG and dedicated memory bank!

    ; ################ BANK 28 ################
    ; Before using it call #dbs.SetupArrays1Bank
    MMU _RAM_SLOT7, dbs.ARR1_BANK_S7_D28
    ORG _RAM_SLOT7_STA_HE000
    INCLUDE "db1_data_arrays1.asm"
    ASSERT $$ == dbs.ARR1_BANK_S7_D28

    ; ################ BANK 29 ################
    ; Before using it call #dbs.SetupArrays2Bank
    MMU _RAM_SLOT7, dbs.ARR2_BANK_S7_D29
    ORG _RAM_SLOT7_STA_HE000
    INCLUDE "db2_data_arrays2.asm"
    ASSERT $$ == dbs.ARR2_BANK_S7_D29

    ; ################ BANK 30 ################
    ; TO USE THIS MODULE: CALL dbs.SetupFollowingEnemyBank
    MMU _RAM_SLOT6, dbs.F_ENEMY_BANK_S6_B30
    ORG _RAM_SLOT6_STA_HC000
    INCLUDE "fe_following_enemy.asm"
    INCLUDE "fed_following_enemy_data.asm"

    ; ################ BANK 31 ################
    ; TO USE THIS MODULE: CALL dbs.SetupPatternEnemyBank
    MMU _RAM_SLOT6, dbs.P_ENEMY_BANK_S6_B31
    ORG _RAM_SLOT6_STA_HC000
    INCLUDE "ena_enemy_data.asm"
    INCLUDE "enf_enemy_formation.asm"
    INCLUDE "enp_enemy_pattern.asm"
    INCLUDE "ens_enemy_single.asm"
    INCLUDE "enu_enemy_fuel_thief.asm"
    ASSERT $$ == dbs.P_ENEMY_BANK_S6_B31

    ; ################ BANK 32 #################
    ; TO USE THIS MODULE: CALL dbs.SetupAyFxsBank
    MMU _RAM_SLOT6, dbs.AY_FX_S6_D32
    ORG _RAM_SLOT6_STA_HC000
    INCLUDE "af_audio_fx.asm"
    ASSERT $$ == dbs.AY_FX_S6_D32

    ; ################ BANK  33 ################
    ; TO USE THIS MODULE: CALL dbs.SetupMusicBank
    MMU _RAM_SLOT6, dbs.AY_MCODE_S6_D33
    ORG _RAM_SLOT6_STA_HC000
    INCLUDE "am_audio_music.asm"
    INCLUDE "aml_audio_music_loader.asm"
    ASSERT $$ == dbs.AY_MCODE_S6_D33

    ; ################ BANK  34 ################
    ; TO USE THIS MODULE: CALL dbs.SetupTileAnimationBank
    MMU _RAM_SLOT6, dbs.TILE_ANIMATION_D34
    ORG _RAM_SLOT6_STA_HC000
    INCLUDE "ta_tile_animation.asm"
    INCLUDE "tad_tile_animation_data.asm"
    ASSERT $$ == dbs.TILE_ANIMATION_D34

    ; ################ BANK  35 ################
    ; TO USE THIS MODULE: CALL dbs.SetupStorageBank
    MMU _RAM_SLOT6, dbs.STORAGE_S6_D35
    ORG _RAM_SLOT6_STA_HC000
    INCLUDE "so_storage.asm"
    ASSERT $$ == dbs.STORAGE_S6_D35

;----------------------------------------------------------;
;                      sjasmplus                           ;
;----------------------------------------------------------;
; https://z00m128.github.io/sjasmplus/documentation.html

    CSPECTMAP "jetman.map"                      ; Generate a map file for use with Cspect.

    ; This sets the name of the project, the start address, and the initial stack pointer.
    SAVENEX OPEN "jetman.nex", start, _RAM_SLOT4_STA_H8000

    ; This asserts the minimum core version.
    SAVENEX CORE 3,0,0

    ; SAVENEX CFG <border 0..7>[,<fileHandle 0/1/$4000+>[,<PreserveNextRegs 0/1>[,<2MbRamReq 0/1>]]].
    SAVENEX CFG 0,0,0,0

    ; Generate the Nex file automatically based on which pages you use.
    SAVENEX AUTO
    SAVENEX CLOSE