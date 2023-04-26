.module render
;;;
;;; RENDER SYSTEM
;;;

.include "../includes/globalSyms.h.s"

renderSys_init::

    ld c, #0
    call cpct_setVideoMode_asm

    ld hl, #_main_palette
    ld de, #16
    call cpct_setPalette_asm

    cpctm_setBorder_asm HW_BLACK

    ld l, #0
    ld h, #HW_BLACK
    call cpct_setPALColour_asm
    call drawStart_menu
    call renderSys_drawStats
    
    ret


renderSys_drawStats:
    ld c, #20
    ld b, #25
    ld de, #20
    ld hl, #_spr_Block_0
    call cpct_etm_setDrawTilemap4x8_ag_asm

    ld hl, #CPCT_VMEM_START_ASM
    ld de, #_level00
    call cpct_etm_drawTilemap4x8_ag_asm
ret

;;
;; Input: IX puntero a la entidad que queremos pintar
;; Destroys: BC | DE | HL | A
renderSys_oneEntity:
    
    ld	a, e_type(ix) 		
    cp #eTypeInvalid
    jr z, renderSys_oneEntity_end  	

    cp #eTypeBoss
    jr nz, checkIfBoss_end
checkIfBoss:
   ld a, (change_to_boss)
   cp #0
   jr nz, renderSys_oneEntity_end
checkIfBoss_end:

    cp #eTypeDead
    jr z, renderSys_oneEntity_erase	

    ld de, #CPCT_VMEM_START_ASM
    ld    c, e_x(ix)                    ;; C = Entity X
    ld    b, e_y(ix)                    ;; B = Entity Y
    call cpct_getScreenPtr_asm		      ;; Get pointer to screen
    
    ex  de, hl                          ;; DE = Puntero a memoria
    ld h, e_sprite_h(ix)
    ld l, e_sprite_l(ix)
    ld b, e_h(ix) ;alto
    ld c, e_w(ix) ;ancho

    call cpct_drawSprite_asm
    jr renderSys_oneEntity_end

renderSys_oneEntity_erase::
    ld de, #CPCT_VMEM_START_ASM
    ld    c, e_x(ix)                    ;; C = Entity X
    ld    b, e_y(ix)                    ;; B = Entity Y
    call cpct_getScreenPtr_asm		      ;; Get pointer to screen

    ex de, hl 
    ld a, #0
    ld  b, e_h(ix)  ;; alto
    ld  c, e_w(ix)  ;; Ancho
    call cpct_drawSolidBox_asm

renderSys_oneEntity_end:
    ret

renderSys_remove_all_entities::
    call entityMg_getEntityArray_IX
    call entityMg_getNumEntities_A
    ld (c_e), a
    loopRAE:

        
        ;;Coger direccion con x e y
        ld    de, #0xC000
        ld    c, e_x(ix)  ;; columnas [0-79]           
        ld    b, e_y(ix)  ;; filas    [0-199]    
        call cpct_getScreenPtr_asm

        ;;Borramos las entidades en su posicion anterior
        ex   de, hl;; copiamos hl en de
        xor a
        ld b, e_h(ix)
        ld c, e_w(ix)
        call cpct_drawSolidBox_asm


        c_e = .+1  ;; el punto es la posicion de memoria donde es genera esto (ha esto se le suma 1, con lo cual se referira a la direccion de memoria donde esta #0, que se cambia arriba)
        ld a, #1
        dec a
        ret z
        
        ld (c_e), a
        ld bc, #entitySize
        add ix, bc
        jr loopRAE

ret

renderSys_Boss::
    ld de, #CPCT_VMEM_START_ASM
    ld    c, e_x(ix)                    ;; C = Entity Y
    ld    b, e_y(ix)                    ;; B = Entity X
    call cpct_getScreenPtr_asm		      ;; Get pointer to screen

    ex  de, hl                          ;; DE = Puntero a memoria
    ld h, e_sprite_h(ix)
    ld l, e_sprite_l(ix)
    ld b, e_h(ix) ;alto
    ld c, e_w(ix) ;ancho

    call cpct_drawSprite_asm
ret



;;
;; INPUT: IX: la direccion de la entidad que quiero renderizar
;; Destroys: HL
renderSys_update::

    ld  hl, #renderSys_oneEntity
    call entityMg_forAll
    ret

        

