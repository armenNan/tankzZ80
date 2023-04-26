.module main


.area _DATA
.area _CODE

.include "includes/globalSyms.h.s"

; No funciona (?)
.macro SysUpdate sysname
   call  entityMg_getEntityArray_IX ;Tengo el array de entidades en IX
   call  entityMg_getNumEntities_A  ;Tengo el numero de entidades en A
   call  'sysname'_update
.endm

change_to_boss:: .db 10
win:: .db 0
score:: .dw 0x0000
CHANGE_LVL_SCORE = 160
REBOOT:: .db 0

_main::
   ld a, #100
   ld (win), a
   call cpct_disableFirmware_asm  
   ;call drawStart 
   call renderSys_init

   ld a, (REBOOT)
   cp #0
   jr nz, loop
   call generatorSys_generate_canon

loop:
   call  generatorSys_generate_tank

   ;; Voy a suponer que mi primera entidad en el array de entidades siempre es el cañon
   call  entityMg_getEntityArray_IX ;Tengo el array de entidades en IX
   call  entityMg_getNumEntities_A  ;Tengo el numero de entidades en A
   call  movementSys_checkInput
   
   call  entityMg_getEntityArray_IX
   call  physicsSys_update

   call  entityMg_getEntityArray_IX
   call  renderSys_update   
   
   call  entityMg_getEntityArray_IX
   call  entityMg_update
   
   call  entityMg_getEntityArray_IX
   call  colissionSystem_update

   call  entityMg_Update_HP ;; Esto deberia poderse hacer de otra forma (?)

   call  entityMg_Check_lose


   ld hl, (score)
   ld bc,  #-3380 
   add hl, bc
   jr nc, winLabel_end
winLabel:
   call drawWin_menu
winLabel_end: 

   
   .rept 8
      halt
      call cpct_waitVSYNC_asm
   .endm



   jr loop
