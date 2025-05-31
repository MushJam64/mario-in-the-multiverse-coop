-- Custom Huds --

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

function get_middle_x_pos(str, scale)
    return djui_hud_get_screen_width() * 0.5 - djui_hud_measure_text(str) * scale * 0.5
end

local lerp_menu_stack = { 0 };
function lerp_menu(value, stack_index)
    -- if (!_60fps_midframe) {
    lerp_menu_stack[stack_index] = value;
    -- } else {
    -- lerp_menu_stack[stack_index] = approach_pos_lerp(lerp_menu_stack[stack_index],value);
    -- }
    return lerp_menu_stack[stack_index];
end

local function render_mitm_hub_hud()
    local gMarioState = gMarioStates[0]
    local texture

    if (hub_level_index > -1) then
        hub_titlecard_alpha = approach_f32_asymptotic(hub_titlecard_alpha, 255.0, 0.1);
        hub_returnback_box_alpha = approach_f32_asymptotic(hub_returnback_box_alpha, 150.0, 0.1)
    else
        hub_titlecard_alpha = approach_f32_asymptotic(hub_titlecard_alpha, 0.0, 0.15);
        hub_returnback_box_alpha = approach_f32_asymptotic(hub_returnback_box_alpha, 0.0, 0.15)
    end

    hub_titlecard_alpha = lerp_menu(hub_titlecard_alpha, LMENU_TITLE_CARD);

    if ((hub_level_index ~= hub_dma_index) and (hub_level_index > -1)) then
        hub_dma_index = hub_level_index;

        --void * rom_location = (hub_dma_index*65536) + ((uintptr_t)title_card_data) ;

        --dma_read(texture, rom_location, rom_location + 65536);
        --texture = title_card_data[hub_level_index]
    end

    if (hub_dma_index > -1) then
        --  create_dl_ortho_matrix();

        --[[gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);

        create_dl_translation_matrix(MENU_MTX_PUSH, 32, 215, 0);
        gDPSetRenderMode(gDisplayListHead++, G_RM_AA_XLU_SURF, G_RM_AA_XLU_SURF2);
        gSPDisplayList(gDisplayListHead++, title_card_TitleCardMesh_mesh);
        gSPPopMatrix(gDisplayListHead++, G_MTX_MODELVIEW);

        create_dl_translation_matrix(MENU_MTX_PUSH, 160, 45, 0);
        gSPDisplayList(gDisplayListHead++, round_box_roundbox_mesh);
        gSPPopMatrix(gDisplayListHead++, G_MTX_MODELVIEW);

        gSPDisplayList(gDisplayListHead++, dl_ia_text_begin);
        gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);
        ]]

        --sprintf(sprintf_buffer,"By: %s", mitm_levels[hub_dma_index].author_abridged);
        --print_generic_string_ascii(110,56, sprintf_buffer); -- down below
        texture = title_card_data[hub_level_index]

        local line_2_y = 40;
        local line_3_y = 25;
        if (dream_comet_unlocked()) then
            line_2_y = 43;
            line_3_y = 31;
        end

        if (mitm_levels[hub_dma_index].star_requirement <= gMarioState.numStars) then
            --Display Collected Stars
            -- gDPSetEnvColor(gDisplayListHead++, 255, 255, 0, (u8)hub_titlecard_alpha);
            if (dream_comet_enabled) then
                --     gDPSetEnvColor(gDisplayListHead++, 255, 0, 255, (u8)hub_titlecard_alpha);
            end
            -- update_hub_star_string(hub_dma_index);
            --print_generic_string(110,line_2_y,hub_star_string); -- down below
        else
            --Not Enough Stars to Enter
            --  gDPSetEnvColor(gDisplayListHead++, 255, 0, 0, (u8)hub_titlecard_alpha);
            --  int_to_str(mitm_levels[hub_dma_index].star_requirement, &pipe_string_not_enough[10]);
            -- print_generic_string(110,line_2_y,pipe_string_not_enough);
        end

        --[[gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);
        print_generic_string(113,line_3_y,pipe_string_enter);
        gDPSetEnvColor(gDisplayListHead++, 0, 0, 255, (u8)hub_titlecard_alpha);
        print_generic_string(110,line_3_y,pipe_string_a);
        gDPSetEnvColor(gDisplayListHead++, 0, 150, 0, (u8)hub_titlecard_alpha);
        print_generic_string(109,line_3_y,pipe_string_b);]]

        djui_hud_set_color(0, 0, 0, hub_returnback_box_alpha)
        djui_hud_render_rect(get_middle_x_pos("", 7) - 70, 33 + 123, 7 * 20, 7 * 7)
        djui_hud_set_color(255, 255, 255, hub_titlecard_alpha)
        local scale = 0.6
        local authorname = "By: " .. mitm_levels[hub_dma_index].author_abridged
        djui_hud_print_text_anchored(authorname, get_middle_x_pos(authorname, scale), 49 + 35, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)
        --others
        local yoff = 20
        djui_hud_print_text_anchored(pipe_string_enter, get_middle_x_pos(pipe_string_enter, scale), 33 + yoff, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_set_color(0, 0, 255, hub_titlecard_alpha)
        djui_hud_print_text_anchored(pipe_string_a, get_middle_x_pos(pipe_string_a, scale) - 53, 33 + yoff, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_set_color(0, 150, 0, hub_titlecard_alpha)
        djui_hud_print_text_anchored(pipe_string_b, get_middle_x_pos(pipe_string_b, scale) - 24, 33 + yoff, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)
        yoff = 35
        -- update_hub_star_string(hub_dma_index);
        local star_flags = save_file_get_star_flags(get_current_save_file_num() - 1,
            (mitm_levels[hub_dma_index].course - 1));
        local star_count = mitm_levels[hub_dma_index].star_count;

        if (dream_comet_enabled and mitm_levels[hub_dma_index].dream_data) then
            star_flags = get_dream_star_flags(hub_dma_index);
            star_count = mitm_levels[hub_dma_index].dream_data.dream_star_ct;
        end
        local xposmul = 11
        local xposoffset = 95
        if (mitm_levels[hub_dma_index].star_requirement <= gMarioState.numStars) then
            for ih = 0, star_count do
                hub_star_string[ih] = ""; -- star
                if (star_flags & (1 << ih) ~= 0) then
                    djui_hud_set_color(255, 255, 0, hub_titlecard_alpha)
                    djui_hud_print_text_anchored(hub_star_string[ih],
                        get_middle_x_pos(pipe_string_b, scale) + xposoffset - 24 - (ih * xposmul),
                        33 + yoff,
                        scale,
                        ANCHOR_LEFT, ANCHOR_BOTTOM)
                else -- no star
                    djui_hud_set_color(130, 130, 130, hub_titlecard_alpha)
                    djui_hud_print_text_anchored(hub_star_string[ih],
                        get_middle_x_pos(pipe_string_b, scale) + xposoffset - 24 - (ih * xposmul),
                        33 + yoff,
                        scale,
                        ANCHOR_LEFT, ANCHOR_BOTTOM)
                end
            end
        else
            djui_hud_set_color(255, 0, 0, hub_titlecard_alpha)
            djui_hud_print_text_anchored(TEXT_PIPE_NOT_ENOUGH .. mitm_levels[hub_dma_index].star_requirement,
                get_middle_x_pos(TEXT_PIPE_NOT_ENOUGH, scale), 33 + yoff, scale,
                ANCHOR_LEFT, ANCHOR_BOTTOM)
        end
        if texture then
            djui_hud_set_color(255, 255, 255, hub_titlecard_alpha)
            djui_hud_render_texture(texture, get_middle_x_pos("", 1) - 125, 33 + yoff - 52, 1, 1)
        end

        if (dream_comet_unlocked()) then
            --  gDPSetEnvColor(gDisplayListHead++, 255, 0, 255, (u8)hub_titlecard_alpha);
            if (dream_comet_enabled) then
                --     gDPSetEnvColor(gDisplayListHead++, 255, 255, 0, (u8)hub_titlecard_alpha);
            end
            --  print_generic_string(120,18,pipe_string_z);

            -- gDPSetEnvColor(gDisplayListHead++, 255, 255, 255, (u8)hub_titlecard_alpha);
            if (dream_comet_enabled) then
                -- print_generic_string_ascii(120,18,"  :Standard");
            else
                --  print_generic_string_ascii(120,18,"  :Dream");
            end
        end

        --gSPDisplayList(gDisplayListHead++, dl_ia_text_end);
    end

    --if (not _60fps_midframe) then
    hub_level_index = -1;
    -- end
end


local function render_mitm_return_to_hub_hud()
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
        djui_hud_render_rect(get_middle_x_pos("", 7) - 70, 33 + 123, 7 * 20, 7 * 7)
        --gSPPopMatrix(gDisplayListHead++, G_MTX_MODELVIEW);

        --gSPDisplayList(gDisplayListHead++, dl_ia_text_begin);
        djui_hud_set_color(255, 255, 255, hub_titlecard_alpha)
        local scale = 0.6
        djui_hud_print_text_anchored("Return To Hub?", get_middle_x_pos("Return To Hub?", scale), 49 + 35, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_print_text_anchored(pipe_string_enter, get_middle_x_pos(pipe_string_enter, scale), 33 + 35, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_set_color(0, 0, 255, hub_titlecard_alpha)
        djui_hud_print_text_anchored(pipe_string_a, get_middle_x_pos(pipe_string_a, scale) - 53, 33 + 35, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)
        djui_hud_set_color(0, 150, 0, hub_titlecard_alpha)
        djui_hud_print_text_anchored(pipe_string_b, get_middle_x_pos(pipe_string_b, scale) - 24, 33 + 35, scale,
            ANCHOR_LEFT, ANCHOR_BOTTOM)

        -- gSPDisplayList(gDisplayListHead++, dl_ia_text_end);
    end
end

local lerp_ability_icons = false

local function render_ability_icon(x, y, alpha, index)
    if index == ABILITY_NONE then return end

    if index == ABILITY_UTIL_MILK and milk_drunk then
        index = 21
    end

    --[[if ability_is_cooling_down(index) then
        alpha = 100 + math.sin(get_global_timer() * 0x600) * 30
    end

    gDPSetEnvColor(gDisplayListHead, 255, 255, 255, alpha)]]

    djui_hud_set_color(255, 255, 255, alpha)
    --if ability_images[index] then
    djui_hud_render_texture(ability_images[index][1], x + 8, y - 50, 0.8, 0.8)
    --end

    local new_y = y
    --[[if lerp_ability_icons and index ~= ABILITY_LOCK_IMAGE_INDEX then
        new_y = lerp_menu_lotolerance(y, LMENU_ABILITY_HUD + index)
    end

    create_dl_translation_matrix(MENU_MTX_PUSH, x, new_y, 0)

    gDPPipeSync(gDisplayListHead)
    gDPSetTextureFilter(gDisplayListHead, G_TF_POINT)
    gDPSetTextureImage(gDisplayListHead, G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ability_images[index])
    gDPSetTile(gDisplayListHead, G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0,
               G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0)
    gDPLoadBlock(gDisplayListHead, 7, 0, 0, 1023, 256)

    gSPDisplayList(gDisplayListHead, ability_ability_mesh)

    gDPSetTextureFilter(gDisplayListHead, G_TF_BILERP)
    gSPPopMatrix(gDisplayListHead, G_MTX_MODELVIEW)]]
end


local function render_ability_dpad(x, y, alpha)
    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture(TEX_DPAD, x, y, 0.08, 0.08)

    -- Render the lock icon if the D-pad is locked
    if ability_dpad_locked then
        render_ability_icon(x, y, alpha, ABILITY_LOCK_IMAGE_INDEX)
    end

    -- Render ability icons at their directional positions
    render_ability_icon(x, (y + 30 - ability_y_offset[0]), alpha, ability_slot[0])
    render_ability_icon(x + 30, (y + 55 - ability_y_offset[1]), alpha, ability_slot[1])
    render_ability_icon(x, (y + 85 - ability_y_offset[2]), alpha, ability_slot[2])
    render_ability_icon(x - 30, (y + 55 - ability_y_offset[3]), alpha, ability_slot[3])

    -- Animate ability icon bounce
    for i = 0, 3 do
        if ability_y_offset[i] > 0 then
            --if not _60fps_midframe then
            ability_y_offset[i] = ability_y_offset[i] + ability_gravity[i]
            ability_gravity[i] = ability_gravity[i] - 1
            -- end
        end

        if ability_y_offset[i] <= 0 then
            ability_gravity[i] = 0
            ability_y_offset[i] = 0
        end
    end
end

local ability_get_timer = 0

local function render_ability_get_hud()
    if ability_util.display then
        ability_get_alpha = approach_f32_asymptotic(ability_get_alpha, 255.0, 0.1)
        ability_get_box_alpha = approach_f32_asymptotic(ability_get_box_alpha, 170.0, 0.1)
    end
    if ability_get_timer > 160 then
        ability_get_alpha = approach_f32_asymptotic(ability_get_alpha, 0.0, 0.1)
        ability_get_box_alpha = approach_f32_asymptotic(ability_get_box_alpha, 0.0, 0.1)
    end

    if math.floor(ability_get_alpha) == 0 then
        ability_get_timer = 0
    end

    if ability_get_alpha > 0.1 then
        ability_get_timer = ability_get_timer + 1
        djui_hud_set_color(0, 0, 0, ability_get_box_alpha)
        djui_hud_render_rect(get_middle_x_pos(" ", 3.5) - 136, 33 + 123, 7 * 43, 7 * 8)
        djui_hud_set_color(255, 255, 255, ability_get_alpha)
        --[[gDPSetEnvColor(gDisplayListHead, 255, 255, 255, math.floor(ability_get_alpha))
        create_dl_translation_matrix(MENU_MTX_PUSH, 160, 120, 0)
        gDPSetRenderMode(gDisplayListHead, G_RM_AA_XLU_SURF, G_RM_AA_XLU_SURF2)
        gSPDisplayList(gDisplayListHead, desconly_onlybox_mesh)
        gSPPopMatrix(gDisplayListHead, G_MTX_MODELVIEW)

        gSPDisplayList(gDisplayListHead, dl_ia_text_begin)
        gDPSetEnvColor(gDisplayListHead, 255, 255, 255, math.floor(ability_get_alpha))
        print_generic_string(43, 58, ability_string(gMarioStates[0].usedObj.oBehParams2ndByte))
        gSPDisplayList(gDisplayListHead, dl_ia_text_end)]]
        local scale = 0.6
        if ability_util.str then
            for id = 1, #ability_util.str do
                local cStr = ability_util.str[id]
                djui_hud_print_text_anchored(cStr, get_middle_x_pos(" ", 3.5) - 136 + 5,
                    49 + 35 - (id * 14) + 10,
                    scale,
                    ANCHOR_LEFT, ANCHOR_BOTTOM)
            end
        end
        if ability_get_alpha < 0 then
            ability_get_alpha = 0
        end
        if math.ceil(ability_get_alpha) == 255 then
            ability_util.display = false
        end
    end
end
local hud_alpha = 0
local function render_hud()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_color(255, 255, 255, 255)
    if (gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE) then
        render_mitm_hub_hud();
    else
        render_mitm_return_to_hub_hud();
    end
    if isPaused then
        hud_alpha = approach_f32_asymptotic(hud_alpha, 0.0, 0.2)
    else
        hud_alpha = approach_f32_asymptotic(hud_alpha, 255.0, 0.2)
    end
    render_ability_dpad(60, 265 - 240, hud_alpha);
    render_ability_get_hud()

    -- Hud bar
    djui_hud_set_font(FONT_HUD)
    djui_hud_set_color(255, 255, 255, hud_alpha)
    local sw = djui_hud_get_screen_width()
    djui_hud_render_texture(TEX_HUDBAR, sw - 190, 265 - 255, 0.18, 0.18)
    djui_hud_render_texture(gTextures.coin, sw - 165, 265 - 255 + 4, 1, 1)
    djui_hud_print_text(string.format("%03d", hud_get_value(HUD_DISPLAY_COINS)), sw - 165 + 20, 265 - 255 + 4, 1)

    djui_hud_render_texture(gTextures.star, sw - 165 + 20 + 25 + 25, 265 - 255 + 4, 1, 1)
    djui_hud_print_text(string.format("%03d", hud_get_value(HUD_DISPLAY_STARS)), sw - 165 + 20 + 25 + 20 + 25,
    265 - 255 + 4,
        1)

    hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~HUD_DISPLAY_FLAG_LIVES)
    hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~HUD_DISPLAY_FLAG_STAR_COUNT)
    hud_set_value(HUD_DISPLAY_FLAGS, hud_get_value(HUD_DISPLAY_FLAGS) & ~HUD_DISPLAY_FLAG_COIN_COUNT)
    djui_hud_reset_color()
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, render_hud)
