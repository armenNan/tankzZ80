.include "../includes/globalSyms.h.s"

drawStart_menu::
   ld c, #20
   ld b, #25
   ld de, #20
   ld hl, #_spr_Menu_000
   call cpct_etm_setDrawTilemap4x8_ag_asm

   ld hl, #CPCT_VMEM_START_ASM
   ld de, #_start_00
   ;ld de, #_win_00
   call cpct_etm_drawTilemap4x8_ag_asm
start_press0:

   call  cpct_scanKeyboard_asm
   ld    hl, #Key_Space
   call  cpct_isKeyPressed_asm
   jr    z, start_press0
ret

drawLose_menu::
   ld c, #20
   ld b, #25
   ld de, #20
   ld hl, #_spr_Menu_000
   call cpct_etm_setDrawTilemap4x8_ag_asm

   ld hl, #CPCT_VMEM_START_ASM
   ld de, #_lose_00
   call cpct_etm_drawTilemap4x8_ag_asm
start_press1:

   call  cpct_scanKeyboard_asm
   ld    hl, #Key_Space
   call  cpct_isKeyPressed_asm
   jr    z, start_press1
   call cpct_waitVSYNC_asm
   call renderSys_remove_all_entities
   ld a, #1
   ld (REBOOT), a
   ld hl, #0x0000
   ld (score), hl
   call _main
ret

drawWin_menu::
   ld c, #20
   ld b, #25
   ld de, #20
   ld hl, #_spr_Menu_000
   call cpct_etm_setDrawTilemap4x8_ag_asm

   ld hl, #CPCT_VMEM_START_ASM
   ld de, #_win_00
   call cpct_etm_drawTilemap4x8_ag_asm
start_press2:

   call  cpct_scanKeyboard_asm
   ld    hl, #Key_Space
   call  cpct_isKeyPressed_asm
   jr    z, start_press2
   call cpct_waitVSYNC_asm
   call renderSys_remove_all_entities
   ld a, #1
   ld (REBOOT), a
   ld a, #100
   ld (win), a
   ld hl, #0x0000
   ld (score), hl
   call _main
ret