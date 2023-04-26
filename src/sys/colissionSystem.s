.module colission

.include "../includes/globalSyms.h.s"

;;  INPUT => IX tengo el entity array
;;  DESTROYS => AF | BC | DE | HL | IX | IY
colissionSystem_update::

    ld  a, (numEntities)
    cp  #1
    ret z ;Si solo tengo una entidad valida no hay colisiones que comprobar

    ld	hl, (lastElemPtr)
    ld bc, #entitySize
    ld de, #-entitySize

    ;; Posiciono IY apuntando a la misma entidad que IX
    ld__a_ixh
    ld__iyh_a

    ld__a_ixl
    ld__iyl_a

    ;Posiciono HL en el ultimo elemento valido
    add hl, de

    jr nextIY

nextEntPair:
    add ix, bc

    ;; Compruebo que no se ha llegado al final con IX
checkIXEnd:
    ld__a_ixl
	sub	l
	jr	nz, checkIXEnd_end

	ld__a_ixh
	sub h
	jr	z, nextEntPair_end
checkIXEnd_end:
    ld__a_ixh
    ld__iyh_a

    ld__a_ixl
    ld__iyl_a

nextIY:
    add iy, bc ;Actualizo IY para que apunte a la siguiente entidad

    push bc
    push hl
    call colissionSystem_checkColission
    pop hl
    pop bc

    ;; Compruebo que no se ha llegado al final con IY
    ld__a_iyl
	sub	l
	jr	nz, nextIY

	ld__a_iyh
	sub h
	jr	nz, nextIY
nextIY_end:
    jr nextEntPair
nextEntPair_end:
    ret

colissionSystem_checkColission:

    ;Primero compruebo Y, puesto que es mas probable que colisionen en este eje
    ; Y1 + Alto1 - Y2 < 0 => no colisionan
    ld  a, e_y(ix)
    add e_h(ix)
    sub e_y(iy)
    jp  c, noColission

    ;; Y2 + Alto2 - Y1 < 0 => no colisionan
    ld  a, e_y(iy)
    add e_h(iy)
    sub e_y(ix)
    jp  c, noColission

    ;; X1 + Ancho1 - X2 < 0 => no colisionan
    ld  a, e_x(ix)
    add e_w(ix)
    sub e_x(iy)
    jp  c, noColission

    ;; X2 + Ancho2 - X1 < 0 => no colisionan
    ld  a, e_x(iy)
    add e_w(iy)
    sub e_x(ix)
    jp  c, noColission

colission:
    ld  b, e_type(iy)
    ld  a, e_type(ix)
    
    cp #eTypeCanon
    jr z, ifCanonType

    cp #eTypeTank
    jr z, ifTankType
    
    cp #eTypeCanonShot
    jr z, ifCanonShotType

    jr noColission

;; Suponiendo que la primera entidad es un cañon...
ifCanonType:
    ; Si es una bala de cañon, no colisionar
    ld a, b
    cp #eTypeCanonShot
    jr z, noColission

    ; Si es un tanque, eliminar el tanque y restar vida al cañon
    push ix
    ld__a_iyh
    ld__ixh_a

    ld__a_iyl
    ld__ixl_a
    call entityMg_set4destruction
    pop ix
    call entityMg_Dec_HP

    jr noColission

ifTankType:
    ; Eliminar tanque al contacto con la bala, en contacto con otros tanques igualar la velocidad
    ld a, b
    
    ;Voy a suponer que solo tengo un cañon y siempre va a ser la primera entidad, por ello no contemplo la posibilidad de que sea de tipo eTypeCanon
    
    cp #eTypeTank
    jr nz, tankToTank_end
tankToTank:
    ld  c, e_vx(iy)
    ld e_vx(ix), c

tankToTank_end:
    cp #eTypeCanonShot
    jr nz, noColission

    push ix
    ld__a_iyh
    ld__ixh_a

    ld__a_iyl
    ld__ixl_a
    call entityMg_set4destruction ; Elimino la bala
    pop ix

    call entityMg_set4destruction ; Elimino el tanque
    
    ;;Aumento el score
    ld hl, (score)
    ld bc,  #60 ;Deberia ser #CHANGE_BOSS_SCORE
    add hl, bc
    ld (score), hl

    jr noColission

ifCanonShotType:
    ; Solo voy a colisionar contra los tanques
    ld a, b
    cp #eTypeTank
    jr nz, noColission

    ; Marco para eliminar el tanque
    push ix
    ld__a_iyh
    ld__ixh_a

    ld__a_iyl
    ld__ixl_a
    call entityMg_set4destruction
    pop ix

    ; Marco para eliminar la bala
    call entityMg_set4destruction

    ;;Aumento el score
    ld hl, (score)
    ld bc,  #60 ;Deberia ser #CHANGE_BOSS_SCORE
    add hl, bc
    ld (score), hl

noColission:
    ret

