local function update_coin_attach(o)
    o.oFlags = o.oFlags | OBJ_FLAG_ATTACHABLE_BY_ROPE
    o.hookRender = 1
end

local function for_each_object_with_behavior(behavior, func) --* function by Isaac
    local o = obj_get_first_with_behavior_id(behavior)
    if o == nil then return end
    while o ~= nil do
        func(o)
        o = obj_get_next_with_same_behavior_id(o)
    end
end

local function upd_spawned()
    for_each_object_with_behavior(id_bhvYellowCoin, function(o)
        if o.oBobombExpBubGfxExpRateX == 1 then
            o.oHealth = o.oHealth + 1
            o.header.gfx.node.flags = o.header.gfx.node.flags & (~GRAPH_RENDER_INVISIBLE)
            --djui_chat_message_create("s")

            if o.oHealth > 30 then
                if o.oHealth % 2 == 0 then
                    o.header.gfx.node.flags = o.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
                end
                if o.oHealth > 50 then
                    obj_mark_for_deletion(o)
                end
            end
        end
    end)
end

hook_event(HOOK_UPDATE, upd_spawned)
hook_behavior(id_bhvBlueCoinJumping, OBJ_LIST_LEVEL, false, update_coin_attach, nil)

--we cant add new o fields that are objs for oRopeObject, so here ill use oHiddenBlueCoinSwitch
local function on_objects(o)
    if ((o.oFlags & OBJ_FLAG_ATTACHABLE_BY_ROPE ~= 0) and ((o.oBehParams >> 8) & 0xff) == BP3_ATTACH_ROPE) then
        if (not o.oHiddenBlueCoinSwitch) then
            o.oHiddenBlueCoinSwitch = spawn_object_relative(0, 0, 50, 0, o, MODEL_ATTACHED_ROPE, bhvGAttachedRope)
            o.oHiddenBlueCoinSwitch.parentObj = o
        end
        o.oTimer = 0
    end

    if (((o.oFlags & OBJ_FLAG_ATTACHABLE_BY_ROPE ~= 0) and ((o.oBehParams >> 8) & 0xff) == BP3_ATTACH_ROPE)) then
        if (not o.oHiddenBlueCoinSwitch) then
            o.oHiddenBlueCoinSwitch = spawn_object_relative(0, 0, 50, 0, o, MODEL_ATTACHED_ROPE, bhvGAttachedRope)
            o.oHiddenBlueCoinSwitch.parentObj = o
        end
        o.oPosX = o.oHiddenBlueCoinSwitch.oPosX
        o.oPosY = o.oHiddenBlueCoinSwitch.oPosY - 50
        o.oPosZ = o.oHiddenBlueCoinSwitch.oPosZ
        o.oForwardVel = 0
        o.oVelY = 0
    end
end

hook_event(HOOK_ON_OBJECT_RENDER, on_objects)
