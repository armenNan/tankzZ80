.module generator

;;;
;;; GENERATOR SYSTEM
;;;

.include "../includes/globalSyms.h.s"

tankRespawnTime: .db 0
RESPAWN_TIME = 12
RESPAWN_TIME_LVL2 = 8


generatorSys_generate_tank::

    ld a, (tankRespawnTime)             ; Cargo en A el tiempo de respawneo
    cp #0
    jp nz, generatorSys_generate_tank_end
    
    ld a, (change_to_boss)
    cp #0
    jr z, shot_boss
        ld hl, #tankTemplate
        jr end_type_1
    shot_boss:        
        ;ld ix, #BossTemplate
        ;call renderSys_Boss
        
        ld hl, #eTypeShotBoss
    end_type_1:
    call entityMg_create

    ;;Accedemos a la entidad que acabamos de crear
    ld	ix,	(lastElemPtr)
	ld	bc, #-entitySize
	add	ix, bc

    ld a, (change_to_boss)
    cp #0
    jr z, shot_boss_type
        ld e_type(ix), #eTypeTank
        jr end_type_2
    shot_boss_type:
        ld e_type(ix), #eTypeShot
    end_type_2:


rerollRandomVel:
    ;; Cambiar dificultad cuando se haya conseguido determinada puntuacion
    ld hl, (score)
    ld bc,  #-1780 ;Deberia ser #CHANGE_LEVEL2_SCORE
    add hl, bc
    jr c, updateLVL2 

    ;; Voy a cambiar la velocidad en x para que sea aleatoria (entre -1 y -2)
	call cpct_getRandom_mxor_u8_asm ; Destroys AF, BC, DE, HL
	ld	a, l
	and #0x01 
    inc a ;; Obtengo un 0 o un 1, le sumo uno y ya tengo una velocidad entre 1 y 2
	;cp #0
	;jr	z, rerollRandomVel ; No quiero una velocidad nula en ningun caso
	neg 				   ; La velocidad debe ser negativa

    jr updateLVL2_end
updateLVL2:
    ld a, #0x02
    neg
updateLVL2_end:
	ld	e_vx(ix), a

    call entityMg_getPossibleYs_IY

    ;; Obtengo un numero entre el 0 y el 7 (posibles vias por las que pueden ir tanques)
rerollRandomYs:
    call cpct_getRandom_xsp40_u8_asm
	and #0x07
    cp #0
	jr	z, rerollRandomYs
iterateYs:
    ;; Establece una Y distinta para cada entidad segun el array de coordenadas Y disponibles
    cp #0
    jr z, iterateIY_end
	inc iy
	dec a

    jr iterateYs
iterateIY_end:
	ld c, (iy)
    ld a, (change_to_boss)
    cp #0
    jr z, shot_y
	    ld  e_y(ix), c
        jr end_y
    shot_y:
        ld a, #2
        add a, c
        ld  e_y(ix), a
    end_y:

    ;; Cambiar dificultad cuando se haya conseguido determinada puntuacion
    ld hl, (score)
    ld bc,  #-780 ;Deberia ser #CHANGE_LEVEL_SCORE
    add hl, bc
    jr c, updateLVL 

    ld  a, #RESPAWN_TIME
    ld  (tankRespawnTime), a
    jr updateLVL_end

updateLVL:
    ld  a, #RESPAWN_TIME_LVL2
    ld  (tankRespawnTime), a
updateLVL_end:
   
generatorSys_generate_tank_end:
    ld  a, (tankRespawnTime)
    dec a
    ld  (tankRespawnTime), a
    ret

;DefineEntity canonTemplate, eTypeCanon, 0, 50, 0, 0, SPR_CANON_W, SPR_CANON_H, _spr_Canon
generatorSys_generate_canon::

    ld hl, #canonTemplate
    call entityMg_create

    ;;Accedemos a la entidad que acabamos de crear
    ld	ix,	(lastElemPtr)
    ld	bc, #-entitySize
    add	ix, bc

    ld e_type(ix), #eTypeCanon

    ret

;; Aqui doy por supuesto que mi primera entidad va a ser el cañon
;; DESTROYS: HL | BC | IX | IY | AF
generatorSys_generate_canonShot::

    ld hl, #canonShotTemplate
    call entityMg_create

    ;;Accedemos a la entidad que acabamos de crear
    ld	ix,	(lastElemPtr)
    ld	bc, #-entitySize
    add	ix, bc

    ld e_type(ix), #eTypeCanonShot

    ld iy, #entityArray
    
    ;Asigno a la bala la x del cañon
    ld  a, e_x(iy)
    add #(SPR_CANON_W - 4)
    ld  e_x(ix), a

    ;Asigno la y
    ld  a, e_y(iy)
    add #(SPR_CANON_H - 11)
    ld  e_y(ix), a

    



    ret