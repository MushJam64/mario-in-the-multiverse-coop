-- Custom Huds --

--[[
extern const u8 title_card_data[];
void render_mitm_hub_hud(void) {
    local gMarioState = gMarioStates[0]
    u8 *texture = segmented_to_virtual(&title_card_placeholder_title_card_rgba16);
    u8 star_flags = 0;
    s16 i;

    char sprintf_buffer[50];

    if (!_60fps_midframe) {
        if (hub_level_index > -1) {
            hub_titlecard_alpha = approach_f32_asymptotic(hub_titlecard_alpha,255.0f,0.1f);
        } else {
            hub_titlecard_alpha = approach_f32_asymptotic(hub_titlecard_alpha,0.0f,0.15f);
        }
    }
    hub_titlecard_alpha = lerp_menu(hub_titlecard_alpha,LMENU_TITLE_CARD);

    if ((hub_level_index != hub_dma_index)&&(hub_level_index > -1)) {
        hub_dma_index = hub_level_index;

        void * rom_location = (hub_dma_index*65536) + ((uintptr_t)title_card_data) ;

        dma_read(texture,rom_location,rom_location+65536);
        }

    if (hub_dma_index > -1) {
        create_dl_ortho_matrix();

        gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);

        create_dl_translation_matrix(MENU_MTX_PUSH, 32, 215, 0);
        gDPSetRenderMode(gDisplayListHead++, G_RM_AA_XLU_SURF, G_RM_AA_XLU_SURF2);
        gSPDisplayList(gDisplayListHead++, title_card_TitleCardMesh_mesh);
        gSPPopMatrix(gDisplayListHead++, G_MTX_MODELVIEW);

        create_dl_translation_matrix(MENU_MTX_PUSH, 160, 45, 0);
        gSPDisplayList(gDisplayListHead++, round_box_roundbox_mesh);
        gSPPopMatrix(gDisplayListHead++, G_MTX_MODELVIEW);

        gSPDisplayList(gDisplayListHead++, dl_ia_text_begin);
        gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);

        sprintf(sprintf_buffer,"By: %s", mitm_levels[hub_dma_index].author_abridged);
        print_generic_string_ascii(110,56, sprintf_buffer);

        s16 line_2_y = 40;
        s16 line_3_y = 25;
        if (dream_comet_unlocked()) {
            line_2_y = 43;
            line_3_y = 31;
        }

        if (mitm_levels[hub_dma_index].star_requirement <= gMarioState.numStars) {
            //Display Collected Stars
            gDPSetEnvColor(gDisplayListHead++, 255, 255, 0, (u8)hub_titlecard_alpha);
            if (dream_comet_enabled) {
                gDPSetEnvColor(gDisplayListHead++, 255, 0, 255, (u8)hub_titlecard_alpha);
            }
            update_hub_star_string(hub_dma_index);
            print_generic_string(110,line_2_y,hub_star_string);
        } else {
            //Not Enough Stars to Enter
            gDPSetEnvColor(gDisplayListHead++, 255, 0, 0, (u8)hub_titlecard_alpha);
            int_to_str(mitm_levels[hub_dma_index].star_requirement, &pipe_string_not_enough[10]);
            print_generic_string(110,line_2_y,pipe_string_not_enough);
        }

        gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);
        print_generic_string(113,line_3_y,pipe_string_enter);
        gDPSetEnvColor(gDisplayListHead++, 0, 0, 255, (u8)hub_titlecard_alpha);
        print_generic_string(110,line_3_y,pipe_string_a);
        gDPSetEnvColor(gDisplayListHead++, 0, 150, 0, (u8)hub_titlecard_alpha);
        print_generic_string(109,line_3_y,pipe_string_b);

        if (dream_comet_unlocked()) {
            gDPSetEnvColor(gDisplayListHead++, 255, 0, 255, (u8)hub_titlecard_alpha);
            if (dream_comet_enabled) {
                gDPSetEnvColor(gDisplayListHead++, 255, 255, 0, (u8)hub_titlecard_alpha);
            }
            print_generic_string(120,18,pipe_string_z);

            gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);
            if (dream_comet_enabled) {
                print_generic_string_ascii(120,18,"  :Standard");
            } else {
                print_generic_string_ascii(120,18,"  :Dream");
            }
        }

        gSPDisplayList(gDisplayListHead++, dl_ia_text_end);
    }

    if (!_60fps_midframe) {
        hub_level_index = -1;
    }
}

]]

-- Anchors Enum --
ANCHOR_LEFT = 0
ANCHOR_RIGHT = 1
ANCHOR_TOP = 0
ANCHOR_BOTTOM = 1


--- @param message string
--- @param x number
--- @param y number
--- @param scale number
--- @param xAnchor integer|nil
--- @param yAnchor integer|nil
--- Prints DJUI HUD text onto the screen
function djui_hud_print_text_anchored(message, x, y, scale, xAnchor, yAnchor)
    xAnchor = xAnchor or 0
    yAnchor = yAnchor or 0

    local screen = {
        w = djui_hud_get_screen_width(),
        h = djui_hud_get_screen_height()
    }

    local finalX = xAnchor ~= 0 and screen.w - x or x
    local finalY = yAnchor ~= 0 and screen.h - y or y
    djui_hud_print_text(message, finalX, finalY, scale)
end

local function get_middle_x_pos(str, scale)
    return djui_hud_get_screen_width() * 0.5 - djui_hud_measure_text(str) * scale * 0.5
end

local function render_mitm_return_to_hub_hud()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_color(255, 255, 255, 255)
    local gMarioState = gMarioStates[0]

    if (gMarioState.action == ACT_ENTER_HUB_PIPE) then
        hub_titlecard_alpha = approach_f32_asymptotic(hub_titlecard_alpha, 255.0, 0.1)
        hub_returnback_box_alpha = approach_f32_asymptotic(hub_returnback_box_alpha, 150.0, 0.1)
    else
        hub_titlecard_alpha = approach_f32_asymptotic(hub_titlecard_alpha, 0.0, 0.15)
        hub_returnback_box_alpha = approach_f32_asymptotic(hub_returnback_box_alpha, 0.0, 0.15)
    end
    if (hub_titlecard_alpha > 1.0) then
        --create_dl_ortho_matrix();

        --gSPDisplayList(gDisplayListHead++, dl_ia_text_begin);

        --create_dl_translation_matrix(MENU_MTX_PUSH, 160, 45, 0);
        --gSPDisplayList(gDisplayListHead++, round_box_roundbox_mesh); -- Custom model for a rounded corners rect
        djui_hud_set_color(0, 0, 0, hub_returnback_box_alpha)
        djui_hud_render_rect(get_middle_x_pos("", 7) - 70, 33 + 123, 7*20, 7*7)
        --gSPPopMatrix(gDisplayListHead++, G_MTX_MODELVIEW);

        --gSPDisplayList(gDisplayListHead++, dl_ia_text_begin);
        djui_hud_set_color(255, 255, 255, hub_titlecard_alpha)
        local scale = 0.6
        djui_hud_print_text_anchored("Return To Hub?", get_middle_x_pos("Return To Hub?", scale), 49 + 35, scale, ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_print_text_anchored(pipe_string_enter, get_middle_x_pos(pipe_string_enter, scale), 33 + 35, scale, ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_set_color(0, 0, 255, hub_titlecard_alpha)
        djui_hud_print_text_anchored(pipe_string_a, get_middle_x_pos(pipe_string_a, scale) - 53, 33 + 35, scale, ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_set_color(0, 150, 0, hub_titlecard_alpha)
        djui_hud_print_text_anchored(pipe_string_b, get_middle_x_pos(pipe_string_b, scale) - 24, 33 + 35, scale, ANCHOR_LEFT, ANCHOR_BOTTOM)

        -- gSPDisplayList(gDisplayListHead++, dl_ia_text_end);
    end
end

local function all_huds()
    if (gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE) then
       -- render_mitm_hub_hud();
     else 
        render_mitm_return_to_hub_hud();
    end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, all_huds)
