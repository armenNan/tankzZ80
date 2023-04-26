## 16 colours palette
PALETTE= 1 0 2 3 6 9 11 12 13 15 16 18 20 24 25 26

## Default values
#$(eval $(call IMG2SP, SET_MODE        , 0                  ))  { 0, 1, 2 }
#$(eval $(call IMG2SP, SET_MASK        , none               ))  { interlaced, none }
#$(eval $(call IMG2SP, SET_FOLDER      , src/               ))
#$(eval $(call IMG2SP, SET_EXTRAPAR    ,                    ))
#$(eval $(call IMG2SP, SET_IMG_FORMAT  , sprites            ))	{ sprites, zgtiles, screen }
#$(eval $(call IMG2SP, SET_OUTPUT      , c                  ))  { bin, c }
#$(eval $(call IMG2SP, SET_PALETTE_FW  , $(PALETTE)         ))
#$(eval $(call IMG2SP, CONVERT_PALETTE , $(PALETTE), g_palette ))
#$(eval $(call IMG2SP, CONVERT         , img.png , w, h, array, palette, tileset))

# PALETTE={0 1 3 4 7 9 10 12 13 16 19 20 21 24 25 26}
#$(eval $(call IMG2SPRITES,img/example.png,0,pre,24,12,$(PALETTE),mask,src/,hwpalette))

$(eval $(call IMG2SP, SET_MODE, 0))
$(eval $(call IMG2SP, SET_FOLDER, src/sprites/ ))
$(eval $(call IMG2SP, SET_OUTPUT, c ))
$(eval $(call IMG2SP, SET_PALETTE_FW, $(PALETTE)))
$(eval $(call IMG2SP, CONVERT_PALETTE, $(PALETTE), main_palette))
$(eval $(call IMG2SP, CONVERT, assets/Tank_1.png, 0, 0, spr_Tank_1))
$(eval $(call IMG2SP, CONVERT, assets/Hero_Canon_1.png, 0, 0, spr_Canon))
$(eval $(call IMG2SP, CONVERT, assets/Shot_Canon_1.png, 0, 0, spr_Canon_Shot))

$(eval $(call IMG2SP, CONVERT, assets/Boss.png, 0, 0, spr_Boss))
$(eval $(call IMG2SP, CONVERT, assets/Shot_Boss_1.png, 0, 0, spr_Boss_Shot))

$(eval $(call IMG2SP, CONVERT, assets/PH_1.png , 54, 14, sp_HP1))


$(eval $(call IMG2SP, SET_IMG_FORMAT  , zgtiles))
$(eval $(call IMG2SP, CONVERT, assets/mapa/Blocks.png, 8, 8, spr_Block))
$(eval $(call IMG2SP, CONVERT, assets/menu/menu.png, 8, 8, spr_Menu))
