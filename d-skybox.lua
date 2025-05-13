-- From Flipflopbell :pray:

SKYBOX_BOB = smlua_model_util_get_id("sky_bob_geo")

-- Behavior
local l = gLakituState

function bhv_skybox_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.header.gfx.skipInViewCheck = true
    obj_scale(o, 10.0)
end

function bhv_skybox_loop(o)
    o.oPosX = l.pos.x
    o.oPosY = l.pos.y
    o.oPosZ = l.pos.z
end

id_bhv3DSkybox = hook_behavior(nil, OBJ_LIST_LEVEL, false, bhv_skybox_init, bhv_skybox_loop)

local skyboxLUT = {
    { level = LEVEL_BOB, areas = { 1, 3 }, box = SKYBOX_BOB },
}

function SpawnSkybox()
    local SkyObj = cur_obj_nearest_object_with_behavior(get_behavior_from_id(id_bhv3DSkybox))
    local np = gNetworkPlayers[0]
    for i = 1, #skyboxLUT do
        if skyboxLUT[i].level == np.currLevelNum then
            for j = 1, #skyboxLUT[i].areas do
                if skyboxLUT[i].areas[j] == np.currAreaIndex then
                    if not SkyObj then
                        spawn_non_sync_object(id_bhv3DSkybox, skyboxLUT[i].box, l.pos.x, l.pos.y, l.pos.z, nil)
                        break
                    end
                end
            end
        end
    end
end

hook_event(HOOK_ON_WARP, SpawnSkybox)
