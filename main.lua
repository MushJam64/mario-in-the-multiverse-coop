-- name: Mario In The Multiverse
-- description: this is, elon musk
-- incompatible: romhack

smlua_audio_utils_replace_sequence(0x25, 42, 80, "25_custom_peanut_plains")

function geo_update_mverse_pipe()
    local objectGraphnode = cur_obj_nearest_object_with_behavior(get_behavior_from_id(bhvLevelPipe))
    if objectGraphnode then
        local timer = objectGraphnode.oUnk94
        local grade = (objectGraphnode.oOpacity / 255.0);
        local r = 120 + sins(timer * 0x300 + 0x0000) * 55.0 * grade;
        local g = 120 + sins(timer * 0x300 + 0x5555) * 55.0 * grade;
        local b = 120 + sins(timer * 0x300 + 0xAAAA) * 55.0 * grade;

        local rgb = { r = r, g = g, b = b }

        for jP = 0, MAX_PLAYERS - 1 do
            network_player_set_override_palette_color(gNetworkPlayers[network_local_index_from_global(jP)], EMBLEM, rgb)
        end
    end
end

hook_event(HOOK_UPDATE, geo_update_mverse_pipe)
