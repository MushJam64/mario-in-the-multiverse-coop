MODEL_LEVEL_PIPE = smlua_model_util_get_id("level_pipe_geo")

---@param o Object
function level_pipe_init(o)
    --todo port: add pipe 'cutscene' and
    -- queued_pipe_cutscene = FALSE;
    o.oUnk94 = random_u16();
 --   if (gNetworkPlayers[0].currLevelNum ~= LEVEL_CASTLE) then
        o.oOpacity = 250;
        --return;
   -- end

    --o.oOpacity = 0;

    --[[
    if (gSaveBuffer.files[gCurrSaveFileNum - 1][0].levels_unlocked & (1 << o->oBehParams2ndByte)) {
        o->oOpacity = 250.0f;
    }
    ]]

    o.oCollisionDistance = 2000
end

---@param o Object
function level_pipe_loop(o)
    load_object_collision_model()

    o.oUnk94 = o.oUnk94 + 1
end
