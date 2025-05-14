local math_floor = math.floor
local math_abs = math.abs
local vtx_get_vertex = vtx_get_vertex

local currentX = 0
local vertices0 = vtx_get_from_name("castle_inside_dl_Map_mesh_layer_1_vtx_0")
local function scroll_castle_inside_dl_Map_mesh_layer_1_vtx_0()
    local count = 72
    local width = 64 * 0x20
    local deltaX = math_floor(0.4 * 0x20) % width

    if math_abs(currentX) > width then
        deltaX = deltaX - math_floor(math_abs(currentX) / width) * width * (deltaX >= 0 and 1 or -1)
    end

    for i = 0, count - 1 do
        local v = vtx_get_vertex(vertices0, i)
        v.tu = v.tu + deltaX
    end

    currentX = currentX + deltaX
end

local currentY1 = 0
local vertices1 = vtx_get_from_name("castle_inside_dl_Map_mesh_layer_5_vtx_0")
local function scroll_castle_inside_dl_Map_mesh_layer_5_vtx_0()
    local count = 464
    local height = 64 * 0x20
    local deltaY = math_floor(0.35 * 0x20) % height

    if math_abs(currentY1) > height then
        deltaY = deltaY - math_floor(math_abs(currentY1) / height) * height * (deltaY >= 0 and 1 or -1)
    end

    for i = 0, count - 1 do
        local v = vtx_get_vertex(vertices1, i)
        v.tv = v.tv + deltaY
    end

    currentY1 = currentY1 + deltaY
end

local currentY2 = 0
local vertices2 = vtx_get_from_name("castle_inside_dl_Map_mesh_layer_5_vtx_1")
local function scroll_castle_inside_dl_Map_mesh_layer_5_vtx_1()
    local count = 72
    local height = 64 * 0x20
    local deltaY = math_floor(0.35 * 0x20) % height

    if math_abs(currentY2) > height then
        deltaY = deltaY - math_floor(math_abs(currentY2) / height) * height * (deltaY >= 0 and 1 or -1)
    end

    for i = 0, count - 1 do
        local v = vtx_get_vertex(vertices2, i)
        v.tv = v.tv + deltaY
    end

    currentY2 = currentY2 + deltaY
end

local currentX_pipe = 0
local verticesPipe = vtx_get_from_name("level_pipe_Level_Pipe_Visual_mesh_layer_1_vtx_1")
local function scroll_level_pipe_Level_Pipe_Visual_mesh_layer_1_vtx_1()
    local count = 256
    local width = 128 * 0x20
    local deltaX = math_floor(0.2 * 0x20) % width

    if math_abs(currentX_pipe) > width then
        deltaX = deltaX - math_floor(math_abs(currentX_pipe) / width) * width * (deltaX >= 0 and 1 or -1)
    end

    for i = 0, count - 1 do
        local v = vtx_get_vertex(verticesPipe, i)
        v.tu = v.tu + deltaX
    end

    currentX_pipe = currentX_pipe + deltaX
end

local function scroll_all()
    scroll_level_pipe_Level_Pipe_Visual_mesh_layer_1_vtx_1();
    if gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE then
        scroll_castle_inside_dl_Map_mesh_layer_1_vtx_0();
        scroll_castle_inside_dl_Map_mesh_layer_5_vtx_0();
        scroll_castle_inside_dl_Map_mesh_layer_5_vtx_1();
    end
end

hook_event(HOOK_UPDATE, scroll_all)
