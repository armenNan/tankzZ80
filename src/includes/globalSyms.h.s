.include "cpctelera.h.s"
.globl cpct_disableFirmware_asm
.globl cpct_waitVSYNC_asm

.globl cpct_getScreenPtr_asm
.globl cpct_setVideoMode_asm
.globl cpct_setPALColour_asm
.globl cpct_drawSprite_asm
.globl cpct_setPalette_asm
.globl cpct_drawSolidBox_asm
.globl cpct_etm_setDrawTilemap4x8_ag_asm
.globl cpct_etm_drawTilemap4x8_ag_asm

.globl cpct_getRandom_mxor_u8_asm
.globl cpct_getRandom_xsp40_u8_asm

.globl cpct_isKeyPressed_asm
.globl cpct_scanKeyboard_asm
.globl cpct_isAnyKeyPressed_f_asm

.globl _main_palette
.globl change_to_boss
;;
;; ENTITIES SYMBOLS
;;
 ;ENTITY MANAGER FUNCTIONS
  .globl entityMg_create
  .globl entityMg_getEntityArray_IX
  .globl entityMg_getNumEntities_A
  .globl entityMg_getPossibleYs_IY
  .globl entityMg_forAll
  .globl entityMg_destroy
  .globl entityMg_update
  .globl entityMg_set4destruction
  .globl entityMg_Update_HP
  .globl entityMg_Dec_HP
  .globl entityMg_Check_lose
 ;

;;
;; MENU SYMBOLS
;;
 ;MENU MANAGER FUNCTIONS
  .globl drawStart_menu
  .globl drawLose_menu
  .globl drawWin_menu
  .globl _spr_Menu_000
  .globl _start_00
  .globl _lose_00
  .globl _win_00
  .globl _main
  .globl  score
  .globl  REBOOT
  .globl  win
 ;
 ;ENTITY MANAGER PROPERTIES
  maxEntities = 20 
  entitySize = 9
  .globl possibleYs
  .globl lastElemPtr
  .globl entityArray
  .globl numEntities

  ;HP PUBLIC
  .globl _sp_HP1_0
  .globl _sp_HP1_1
  .globl _sp_HP1_2
  .globl _sp_HP1_3
  .globl  SpritesHP
  HP_X_Y      = 5
  SP_HP_H     = 14 
  SP_HP_W     = 27 
 ;
 ;ENTITY PROPERTIES  
  e_type   = 0
  e_x      = 1
  e_y      = 2
  e_vx     = 3
  e_vy     = 4
  e_w      = 5
  e_h      = 6
  e_sprite_l = 7
  e_sprite_h = 8
 ;

 ;ENTITY MACROS
  .macro DefineEntity _name, _type, _x, _y, _vx, _vy, _w, _h, _sprite
  _name: 
    .db    _type      ;; type
    .db    _x, _y     ;; X, Y
    .db   _vx, _vy    ;; VX, VY
    .db    _w, _h     ;; W, H
    .dw   _sprite     ;; sprite
  .endm
  
  .macro DefineEntityDefault _name, _suf
    DefineEntity _name'_suf, eTypeInvalid, 0, 0, 0, 0, 0, 0, 0xCAF0
  .endm
  
  .macro DefineNEntities _name, _n
    _c = 0
    .rept _n
        DefineEntityDefault _name, \_c
        _c = _c + 1
    .endm
  .endm
 ;

 ;ENTITY TYPES
  eTypeAliveBit = 7
  eTypeRenderBit = 6
  eTypePhysicsBit = 5
  eTypeInputBit = 4

  eTypeAlive 	 = (1 << eTypeAliveBit)
  eTypeRender = (1 << eTypeRenderBit)
  eTypePhysics = (1 << eTypePhysicsBit)
  eTypeControllable = (1 << eTypeInputBit)
  

  eTypeInvalid    = 0x00 
  eTypeDead       = 0x01
  eTypeCanonShot  = 0x02
  eTypeShot       = 0x04
  eTypeDefault = eTypeAlive | eTypeRender | eTypePhysics
  eTypeTank = eTypeDefault
  eTypeCanon = eTypeAlive | eTypeRender | eTypePhysics | eTypeControllable
  eTypeBoss = 0xFF
 ;

;;
;; PHYSICS SYMBOLS
;;
 ;PHYSICS FUNCTIONS
   .globl  physicsSys_update
 ;


;;
;; RENDER SYMBOLS
;;
 ;RENDER FUNCTIONS
   .globl  renderSys_update
   .globl  renderSys_init
   .globl  renderSys_oneEntity_erase
   .globl  renderSys_remove_all_entities
   .globl  renderSys_Boss
 ;

;;
;; GENERATOR SYMBOLS
;;
 ;GENERATOR FUNCTIONS
  .globl generatorSys_generate_tank
  .globl generatorSys_generate_canon
  .globl generatorSys_generate_canonShot
 ;

;;
;; MOVEMENT SYMBOLS
;;
 ; MOVEMENT FUNCTIONS
  .globl movementSys_checkInput
  ;.globl movementSys_waitKey
 ;

;;
;; COLISSION SYMBOLS
;;
 ;COLISSION FUNCTIONS
  .globl colissionSystem_update
 ;

;;
;;Shoot Boss SYMBOLS
;;
 ;
  .globl _spr_Boss_Shot
  .globl eTypeShotBoss
  SPR_BOSS_SHOT_W  = 5
  SPR_BOSS_SHOT_H  = 6
 ;

;;
;;Boss SYMBOLS
;;
 ;
  .globl _spr_Boss
  .globl BossTemplate
  SPR_BOSS_W   = 15
  SPR_BOSS_H   = 154
 ;

;;
;; TANKS SYMBOLS
;;

 ;TANKS PUBLIC
  .globl _spr_Tank_1
  .globl tankTemplate

 ;

 ;TANKS PROPERTIES
  SPR_TANK_1_W    = 10
  SPR_TANK_1_H    = 14
  TANKS_GAP       = 6
  TANKS_LANE_SIZE = 28 ;SPR_TANK_1_H + TANKS_GAP
  FIRST_AVALIABLE_Y = TANKS_LANE_SIZE+4
 ;

;;
;;CANON SYMBOLS
;;
 ;
  .globl _spr_Canon
  .globl _spr_Canon_Shot
  .globl canonTemplate
  .globl canonShotTemplate
  SPR_CANON_W       = 12
  SPR_CANON_H       = 16
  SPR_CANON_SHOT_W  = 3
  SPR_CANON_SHOT_H  = 6
 ;

.globl _spr_Block_0
.globl _level00

.macro BRK
   .db 0xED, 0xFF
.endm
