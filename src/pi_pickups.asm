;----------------------------------------------------------;
;                       Game Pickups                       ;
;----------------------------------------------------------;
    MODULE pi

PI_SPR_DIAMOND          = 39
PI_SPR_JAR              = 40
PI_SPR_STRAWBERRY       = 41
PI_SPR_GRENADE          = 42
PI_SPR_LIVE             = 43
PI_SPR_GUN              = 44

deployOrderPos          = 0
deployOrder
    DB PI_SPR_DIAMOND, PI_SPR_DIAMOND, PI_SPR_GUN, PI_SPR_STRAWBERRY, PI_SPR_JAR, PI_SPR_DIAMOND, PI_SPR_JAR, PI_SPR_STRAWBERRY, PI_SPR_GUN
    DB PI_SPR_GRENADE, PI_SPR_GRENADE, PI_SPR_JAR, PI_SPR_GRENADE, PI_SPR_DIAMOND, PI_SPR_GUN, PI_SPR_GUN, PI_SPR_JAR, PI_SPR_STRAWBERRY
    DB PI_SPR_DIAMOND, PI_SPR_LIVE
DEPLOY_ORDER_SIZE       = 20

PI_SPR_MIN              = PI_SPR_DIAMOND
PI_SPR_MAX              = PI_SPR_GUN

deployed                BYTE 0                  ; Currently deployed pickup (#PI_SPR_XXX), 0 for none.
deployCnt               BYTE 0

lifeDeployed            BYTE 0
LIVE_DEPLOYED_YES       = 1
LIVE_DEPLOYED_NO        = 1

;----------------------------------------------------------;
;                    ResetPickups                          ;
;----------------------------------------------------------;
ResetPickups

    XOR A
    LD (deployed), A
    LD (lifeDeployed), A
    LD (deployCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  PickupTriggerCounter                    ;
;----------------------------------------------------------;
PickupTriggerCounter

    ; Do not deploy next if there is one out there.
    LD A, (deployed)
    CP 0
    RET NZ

    ; ##########################################
    ; Check deploy counter, deploy next only in case of overflow.
    LD A, (deployCnt)
    INC A
    LD (deployCnt), A

    RET NZ                                      ; Return there is not overflow $FF -> $00


   ; nextreg 2,8

    ; Do not deploy live if it has already been deployed in this round.
    LD A, (lifeDeployed)
    CP LIVE_DEPLOYED_YES
    RET Z


    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE 