.module physics

;;;
;;; PHYSICS SYSTEM
;;;

.include "../includes/globalSyms.h.s"


;;
;; Input: IX puntero a la entidad que queremos mover
;; Destroys: A
physicsSys_updateOneEntity:

    ld  a, e_type(ix)
    cp #eTypeCanon
    jr z, physicsSys_updateOneEntity_end

    cp #eTypeBoss
    jr z, physicsSys_updateOneEntity_end

    cp #eTypeCanonShot
    jr z, physicsSys_updateCanonShot
    
    ld  a, e_x(ix)
    add e_vx(ix)
    cp e_x(ix)              ;C is set if borrow (X-anterior > X-actual); otherwise, it is reset
    jr  nc, markToDestroy   
    
    ld  e_x(ix), a
    jr physicsSys_updateOneEntity_end          
markToDestroy:
    ld a, e_type(ix)
    cp #eTypeTank
    jr nz, whenTankDestroyed_end
    call entityMg_Dec_HP
whenTankDestroyed_end:
    call entityMg_set4destruction
    jr physicsSys_updateOneEntity_end
physicsSys_updateCanonShot:
    ld  a, e_x(ix)

    push af
    call renderSys_oneEntity_erase
    pop af

    add e_vx(ix)
    cp #(79 - SPR_CANON_SHOT_W)             
    jr  nc, markToDestroy
    ld  e_x(ix), a

physicsSys_updateOneEntity_end:
    ret

    

;;
;; INPUT: IX la direccion de la entidad que quiero modificar (?)
;; Destroys: HL
physicsSys_update::

    ld  hl, #physicsSys_updateOneEntity
    call entityMg_forAll
    ret











