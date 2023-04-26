.module entityManager

;;;
;;; ENTITY MANAGER
;;;

.include "../includes/globalSyms.h.s"

;; .db => define byte || .dw => define word
numEntities:: .db 0
lastElemPtr:: .dw entityArray

; Defino maxEntities del tipo default 
entityArray::
DefineNEntities entityArray, maxEntities

;entityArray:: 
;	.ds maxEntities * entitySize
possibleYs:: 
    ;.db  3 * TANKS_LANE_SIZE, 5 * TANKS_LANE_SIZE, 2* TANKS_LANE_SIZE, 4 * TANKS_LANE_SIZE, FIRST_AVALIABLE_Y, 7 * TANKS_LANE_SIZE, 6 * TANKS_LANE_SIZE, 8 * TANKS_LANE_SIZE
	.db  0, 30, 52, 74, 96, 118, 140, 162, 184

SpritesHP:: 
    .dw  0xFF, _sp_HP1_3, _sp_HP1_2, _sp_HP1_1, _sp_HP1_0

HP: 	.db 4

;			     |NAME|     |TYPE|      |X|  |Y| |VX||HP||W||H| |SPRITE|
;Template de un tanque
DefineEntity tankTemplate	,eTypeDefault , 73, 28, -1, 0, SPR_TANK_1_W, SPR_TANK_1_H, _spr_Tank_1
DefineEntity eTypeShotBoss	,eTypeDefault 	, 62, 28, -1, 0, SPR_BOSS_SHOT_W, SPR_BOSS_SHOT_H, _spr_Boss_Shot
DefineEntity BossTemplate	,eTypeBoss 	, 65, 24, 0, 50, SPR_BOSS_W, SPR_BOSS_H, _spr_Boss

DefineEntity canonTemplate, eTypeCanon, 0, 80, 0, 0, SPR_CANON_W, SPR_CANON_H, _spr_Canon
DefineEntity canonShotTemplate, eTypeCanonShot, 0, 0, 5, 0, SPR_CANON_SHOT_W, SPR_CANON_SHOT_H, _spr_Canon_Shot

;; 
;; INPUT: HL puntero a los datos de inicializacion de la entidad, 
;; DESTROYS: HL | A | BC | DE
entityMg_create::
	
	ld a, (numEntities)
	ld b, a
	ld a, #maxEntities
	cp b
	ret c ; Nos devolvemos si hay carry, es decir, si el numero maximo de entidades permitido < numero actual de entidades
	ret z ; Tambien si numero max de entidades = numero actual
	    
    ld  de, (lastElemPtr)	; Direccion destino
	ld  bc, #entitySize		; Cuantos bytes voy a pasar de HL a DE
		
	;; Repeats LDI (LD (DE),(HL), then increments DE, HL, and decrements BC) until BC=0
	ldir

	;; Incremento el numero de entidades en uno 
	ld	a, (numEntities)
	inc	a
	ld	(numEntities), a

	;; Actualizo el puntero al ultimo elemento
	ld	hl,	(lastElemPtr)
	ld	bc, #entitySize
	add	hl, bc
	ld	(lastElemPtr), hl

    ret


;;
;; INPUT: IX puntero a los datos que hay que marcar para destruir
;;
entityMg_set4destruction::
	ld e_type(ix), #eTypeDead
	ret

;;
;; INPUT: IX puntero a los datos que hay que destruir
;;
entityMg_destroy::
	ld a, e_type(ix)
	cp #eTypeBoss
	jr nz, endKLK
klk:	
	BRK
endKLK:

	;Muevo el puntero que apunta a la ultima entidad para que apunte a la penultima entidad
	ld	hl, (lastElemPtr)
	ld	bc, #-entitySize
	add hl, bc
	ld	(lastElemPtr), hl

	;Decremento el numero de entidades
	ld	a, (numEntities)
	dec a
	ld	(numEntities), a

	;Compruebo si estoy en la ultima entidad, en tal caso no hace falta copiar
	ld__a_ixl
	sub	l
	jr	nz, copy_lastEntity

	ld__a_ixh
	sub h
	jr	z, noCopy_lastEntity

copy_lastEntity:
	ld__e_ixl
	ld__d_ixh
	ld	bc, #entitySize
	ldir
noCopy_lastEntity:
	ld	hl, (lastElemPtr)
	ld	(hl), #eTypeInvalid

	ret

;;
;;
;;
entityMg_update::
	ld ix, #entityArray
	jr	nextElem
deleteElem:
	call entityMg_destroy

nextElem:
	ld	a, e_type(ix)
	cp	#eTypeBoss
	jr	z, validElem
	
	ld	a, e_type(ix)
	cp #eTypeInvalid
	ret z ; Solo se sale cuando el tipo es invalido

	ld	a, e_type(ix)
	cp #eTypeDead
	jr	z, deleteElem
validElem:
	ld	bc, #entitySize
	add ix, bc
	jr nextElem

;;
;; INPUT: HL puntero a la direccion de memoria donde esta la funcion physicsSys_updateOneEntity
;; Destroys: AF | BC | DE | HL | IX | IY
entityMg_forAll::

	ld	ix, #entityArray  ; Cargo en 'ix' la posicion de la primera entidad 
	ld	iy, (lastElemPtr) ; Cargo en 'iy' la posicion de la ultima entidad
	ld	de, #entitySize	  ; Cargo en 'de' el tamaño de la entidad

entitiesLoop:

	ld	a, e_type(ix) 		; Cargo en 'a' el tipo de la entidad
	cp #eTypeInvalid  		; Z is set if result is 0; otherwise, it is reset
	jr	z, entitiesLoop_end  ;(if entity->type == invalid) termino el bucle

	ld	bc, #entitiesLoop_nextEntity
	push hl
	push bc ; Al usar ret (ret pone en el pc lo que hay en la cima de la pila)	
	jp (hl) ; Llama a la función correspondiente y prosigue en 'entitiesLoop_nextEntity'

entitiesLoop_nextEntity:
	pop hl 				;HL tambien ha sido por la función, por lo tanto ahora lo recupero de la pila
	ld	de, #entitySize ;He destruido el DE, por lo que tengo que repetir esta operacion
	;BRK
	add	ix, de

	;Compruebo que no he llegado a la ultima entidad
	ld__a_iyl	;ld a, iyl
	cp__ixl		;cp 	ixl
	jp	nz, entitiesLoop ;if (iyL - ixL != 0) GOTO next entity

	ld__a_iyh	;ld a, iyh
	cp__ixh		;cp	ixh 
	jp	nz, entitiesLoop ;if (iyH - ixH != 0) GOTO next entity

entitiesLoop_end:	
	ret


entityMg_Dec_HP:
	;call print
	ld a, (HP)
	cp #0
	jr z, end_dec
		dec a
		ld (HP), a
	end_dec:
ret

entityMg_Update_HP::
	ld iy, #SpritesHP
	ld a, (HP)
	Find_sprite:
		cp #0
		jr z, end_Find
		inc iy
		inc iy
		dec a
		jr Find_sprite
	end_Find:
	ld    de, #CPCT_VMEM_START_ASM      ;;Comienzo memoria de video
    ld    c, #HP_X_Y                    
    ld    b, #HP_X_Y                    
    call cpct_getScreenPtr_asm		    ;; Get pointer to screen

	ld l, (iy)
	ld h, 1(iy)
	ld  b,  #SP_HP_H                     ;; alto
    ld  c,  #SP_HP_W                     ;; Ancho
    call cpct_drawSprite_asm
ret

entityMg_Check_lose::
	ld a, (HP)
	cp #0
	jr z, Go_lose_menu
		jr es_vivo
	Go_lose_menu:
		ld a, #4
		ld (HP), a
		ld a, #0
		ld (score), a
		call drawLose_menu
	es_vivo:
ret

entityMg_getEntityArray_IX::
	ld	ix, #entityArray
	ret

entityMg_getNumEntities_A::
	ld	a, (numEntities)
	ret

entityMg_getPossibleYs_IY::
	ld iy, #possibleYs
	ret
