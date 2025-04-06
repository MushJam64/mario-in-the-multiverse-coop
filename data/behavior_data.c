const BehaviorScript bhvLevelPipe[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    LOAD_COLLISION_DATA(level_pipe_collision),
    OR_INT(oFlags, (OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)),
    SET_FLOAT(oDrawingDistance, 20000),
    CALL_NATIVE(level_pipe_init),
    BEGIN_LOOP(),
        CALL_NATIVE(level_pipe_loop),
    END_LOOP(),
};