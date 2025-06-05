local function update_coin_attach(o)
   o.oFlags = o.oFlags | OBJ_FLAG_ATTACHABLE_BY_ROPE o.hookRender = 1
end

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