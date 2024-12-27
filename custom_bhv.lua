MODEL_LEVEL_PIPE = smlua_model_util_get_id("level_pipe_geo")

local function OR_INT(flags, setto) flags.oFlags = setto end
local function LOAD_COLLISION_DATA(o, col) o.collisionData = smlua_collision_util_get(col) end

--[[

const BehaviorScript bhvLevelPipe[] = {
    BEGIN(OBJ_LIST_SURFACE),
    LOAD_COLLISION_DATA(level_pipe_collision),
    OR_INT(oFlags, (OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)),
    SET_FLOAT(oDrawingDistance, 20000),
    CALL_NATIVE(level_pipe_init),
    BEGIN_LOOP(),
        CALL_NATIVE(level_pipe_loop),
    END_LOOP(),
};


]]

---@param o Object
local function level_pipe_init(o)
    OR_INT(o, (OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE))
    LOAD_COLLISION_DATA(o, "level_pipe_collision")
    o.oDrawingDistance = 20000
    o.oCollisionDistance = 2000

    o.oUnk94 = random_u16();

    if (gNetworkPlayers[0].currLevelNum ~= LEVEL_CASTLE) then
        o.oOpacity = 250;
        --return;
    end
end

---@param o Object
local function level_pipe_loop(o)
    load_object_collision_model()

    o.oUnk94 = o.oUnk94 + 1
end

bhvLevelPipe = hook_behavior(nil, OBJ_LIST_SURFACE, true, level_pipe_init, level_pipe_loop, nil)
