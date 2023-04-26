.module movement

.include "../includes/globalSyms.h.s"

SHIFT_PRESSED = 1
SHIFT_NOT_PRESSED = 0

shootCooling: .db 0
SHOOT_COOLDOWN = 2
;;
;; MOVEMENT SYSTEM
;;

movementSys_checkInput::

	call cpct_scanKeyboard_asm
	
;    ld hl, #Key_Shift 					
;	call cpct_isKeyPressed_asm  ;Z = 1 (Key NOT pressed) / 0 (Key pressed)												
;	jr z, shift_not_pressed

;    ld b, #SHIFT_PRESSED
;    jr shift_not_pressed_end
;shift_not_pressed:
;    ld b, #SHIFT_NOT_PRESSED
;shift_not_pressed_end:
    ;; Compruebo si la tecla 'ARRIBA' esta pulsada
	ld hl, #Key_W 					
	call cpct_isKeyPressed_asm  ;Z = 1 (Key NOT pressed) / 0 (Key pressed)												
	jr z, up_not_pressed 					

    call movementSys_moveUp 				

up_not_pressed:

	;; Compruebo si la tecla 'ABAJO' esta pulsada
	ld hl, #Key_S 							
	call cpct_isKeyPressed_asm    			 									
	jr z, down_not_pressed 					
				
	call movementSys_moveDown 			

down_not_pressed:

	;; Compruebo si la tecla de disparo esta pulsada
	ld hl, #Key_D 						
	call cpct_isKeyPressed_asm 				 									
	jr z, shootKey_not_pressed 				
	
;    ld a, (shootCooling) 
;    cp #0
;    jr nz, allowShoot_end
;allowShoot:
    call movementSys_shoot
;    ld a, #SHOOT_COOLDOWN
;    ld (shootCooling), a		
;allowShoot_end:	
;    ld a, (shootCooling)
;    dec a
;    ld (shootCooling), a
shootKey_not_pressed:
    ret


;movementSys_waitKey::
;    call cpct_scanKeyboard_asm 				
;key_not_pressed:
;    call cpct_isAnyKeyPressed_f_asm   ;that true is not 1, but any non-0 number.  Return value is placed in registers A and L (same value for both) 	
;    cp #0 								
;    jr z, key_not_pressed
;    
;    ret

;; INPUT => IX, entidad a mover
movementSys_moveUp:
    ld a, e_type(ix)
    and #eTypeControllable 
    jp z, movementSys_moveUp_end

    ld a, e_y(ix)

    ;; En b tengo un 1 si se ha pulsado shift, en tal caso quiero moverme rapido
;    dec b
;    jr z, moveUPFast
;    jr moveUPFast_else
;moveUPFast:
;    sub #16
;    jr moveUPFast_end
;moveUPFast_else:
    sub #8
;moveUPFast_end:
    cp #FIRST_AVALIABLE_Y
    jp c, movementSys_moveUp_end

    push af

    call renderSys_oneEntity_erase

    pop af
    
    ld e_y(ix), a

movementSys_moveUp_end:
    ret

;; INPUT => IX, entidad a mover
movementSys_moveDown:
    ld a, e_type(ix)
    and #eTypeControllable 
    jp z, movementSys_moveDown_end

    ld a, e_y(ix)
    add #8
    cp #(199 - SPR_CANON_H)
    jp nc, movementSys_moveDown_end

    push af

    call renderSys_oneEntity_erase

    pop af
    
    ld e_y(ix), a

movementSys_moveDown_end:
    ret

movementSys_shoot:
    ld a, e_type(ix)
    and #eTypeControllable 
    jp z, movementSys_shoot_end

    push ix
    push af
    call generatorSys_generate_canonShot
    pop af
    pop ix

movementSys_shoot_end:
    ret